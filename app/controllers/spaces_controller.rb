class SpacesController < ApplicationController
  def new
    @nest = Nest.find(params[:nest])
    if ( @nest )
      @space = Space.new(class_name: params[:class])
    end
  end
  def create
    @nest = Nest.find(params[:nest])
    if ( @nest )
      space = params.require(:space).
        permit(:title, :title_id, :description, :icon_image,
               :publication_level, :preparation_level,
               :entry_edit_level, :entry_publication_level, :entry_comment_level,
               :class_name, :notice_level)

      space.delete(:icon_image)
      @space = Space.new(space)
      @space.creater_id = current_user.id
      @space.nest = @nest
      @attach = _create_icon(@space,
                             params[:space][:icon_image],
                             params[:icon_x],
                             params[:icon_y],
                             params[:icon_width],
                             params[:icon_height]
                             )
      if @attach
        @space.icon_image_id = @attach.id
      end
      @space.save
      @space.watch = current_user
      redirect_to edit_space_path(@space)
    end
  end
  def edit
    @space = Space.find(params[:id])
    @nest = @space.nest
    if ( !@space.released? )
      flash[:danger] = t('spaces.not_released')
    end
  end
  def update
    @space = Space.find(params[:id])
    space = params.require(:space).
      permit(:title, :title_id, :description, :icon_image,
             :publication_level, :preparation_level,
             :entry_edit_level, :entry_publication_level, :entry_comment_level,
             :notice_level)
    space.delete(:icon_image)

    @space.attributes = space
    if ( params[:space][:icon_deleted] &&
         params[:space][:icon_deleted] == "true")
      @space.icon_image_id = nil
    end
    p @attach = _create_icon(@space,
                             params[:space][:icon_image],
                             params[:icon_x],
                             params[:icon_y],
                             params[:icon_width],
                             params[:icon_height]
                             )
    if @attach
      @space.icon_image_id = @attach.id
    end
    @space.save

    redirect_to edit_space_path(@space)
  end
  def show
    @space = Space.find(params[:id])
  end
  def index
    @nest = Nest.find(params[:nest])
    if ( @nest.visible?(current_user) )
      type = params[:type]
      if ( type )
        if ( @nest.admin?(current_user) )
          spaces = @nest.spaces
        elsif ( @nest.member?(current_user) )
          spaces = @nest.spaces.where(publication_level: ..Space::PublicationLevel::MEMBERS_ONLY).where(class_name: params[:type])
        elsif ( current_user )
          spaces = @nest.spaces.where(publication_level: ..Space::PublicationLevel::OPEN).where(class_name: params[:type])
        else
          spaces = @nest.spaces.where(publication_level: Space::PublicationLevel::OPEN_GLOBAL).where(class_name: params[:type])
        end
        if ( @nest.admin?(current_user) )
          @spaces = spaces.order("title ASC")
        else
          @spaces = spaces.where("released_at IS NOT NULL AND released_at < now()").order("title ASC")
        end
      else
        @spaces = []
        Space::ClassName::CLASSES.each do | klass |
          if ( @nest.admin?(current_user) )
            spaces = @nest.spaces.where(class_name: klass[1])
          elsif ( @nest.member?(current_user) )
            spaces = @nest.spaces.where(publication_level: 0..Space::PublicationLevel::MEMBERS_ONLY).where(class_name: klass[1])
          elsif ( current_user )
            spaces = @nest.spaces.where(publication_level: 0..Space::PublicationLevel::OPEN).where(class_name: klass[1])
          else
            spaces = @nest.spaces.where(publication_level: Space::PublicationLevel::OPEN_GLOBAL).where(class_name: klass[1])
          end
          if ( spaces.count > 0 )
            if ( @nest.admin?(current_user) )
              @spaces << {
                'class': klass[0],
                spaces: spaces.order("title ASC")
              }
            else
              @spaces << {
                'class': klass[0],
                spaces: spaces.where("released_at IS NOT NULL AND released_at < now()").order("title ASC")
              }
            end
          end
        end
      end
    else
      redirect_to_404
    end
  end
  def release
    @space = Space.find(params[:id])
    @space.released_at = Time.now
    @space.save
    flash[:success] = t('spaces.released')
    redirect_to edit_space_path(@space)
  end
  def unrelease
    @space = Space.find(params[:id])
    @space.released_at = nil
    @space.save
    flash[:danger] = t('spaces.not_released')
    redirect_to edit_space_path(@space)
  end

  def manage_members
    @space = Space.find(params[:id])
    @nest = @space.nest
    if ( current_user.use_admin? )
      render
    else
      redirect_to_404
    end
  end
  def manage_members_op
    p params
    @space = Space.find(params[:id])
    @user = User.find(params[:user])
    @space_member = SpaceMember.where(space: @space,
                                      user: @user).first
    if ( params[:admin] )
      if ( params[:admin]  == "true" )
        if ( !@space_member )
          @space_member = SpaceMember.create(space: @space,
                                             user: @user,
                                             admin: true)
        else
          @space_member.admin = true
          @space_member.save
        end
      else
        if ( @space_member )
          @space_member.destroy
        end
      end
    end
    if ( params[:member] )
      if ( params[:member]  == "true" )
        if ( !@space_member )
          @space_member = SpaceMember.create(space: @space,
                                             user: @user,
                                             admin: false)
        end
      else
        if ( @space_member )
          @space_member.destroy
        end
      end
    end
  end

  def destroy
    @space = Space.find(params[:id])
    @nest = @space.nest
    @space.destroy
    redirect_to spaces_path(nest: @nest)
  end
end
