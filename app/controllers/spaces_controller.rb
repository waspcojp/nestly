class SpacesController < ApplicationController
  def new
    @nest = Nest.find(params[:nest])
    if ( @nest )
      @space = Space.new
    end
  end
  def create
    @nest = Nest.find(params[:nest])
    if ( @nest )
      space = params.require(:space).
        permit(:title, :title_id, :description, :icon_image, :publication_level, :preparation_level, :class_name)

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
      redirect_to edit_space_path(@space)
    end
  end
  def edit
    @space = Space.find(params[:id])
    @nest = @space.nest
  end
  def update
    @space = Space.find(params[:id])
    space = params.require(:space).
      permit(:title, :title_id, :description, :icon_image, :publication_level, :preparation_level)
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
        @spaces = spaces.order("title ASC")
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
            @spaces << {
              'class': klass[0],
              spaces: spaces.order("title ASC")
            }
          end
        end
      end
    else
      redirect_to_404
    end
  end
  def destroy
    @space = Space.find(params[:id])
    @nest = @space.nest
    @space.destroy
    redirect_to spaces_path(nest: @nest)
  end
end
