class EntriesController < ApplicationController
  def index
    if ( params[:space] )
      @space = Space.find(params[:space])
      if ( @space.admin?(current_user) )
        @entries = @space.entries.order("updated_at DESC")
      else
        @entries = @space.entries.where("released_at IS NOT NULL AND released_at < now()").order("updated_at DESC")
      end
      @nest = @space.nest
    elsif ( params[:nest] )
      @nest = Nest.find(params[:nest])
      if ( @nest.admin?(current_user) )
        entries = Entry.where(space_id: Space.where(nest_id: @nest.id))
      elsif ( @nest.member?(current_user) )
        entries = Entry.where(space_id: Space.where(nest_id: @nest.id,
                                                     publication_level: 0..Space::PublicationLevel::MEMBERS_ONLY))
      elsif ( current_user )
        entries = Entry.where(space_id: Space.where(nest_id: @nest.id,
                                                     publication_level: 0..Space::PublicationLevel::OPEN))
      else
        entries = Entry.where(space_id: Space.where(nest_id: @nest.id,
                                                     publication_level: Space::PublicationLevel::OPEN_GLOBAL))
      end
      case ( params[:order] )
      when 'update', 'update_desc'
        entries = entries.order("updated_at DESC")
      when 'update_asc'
        entries = entries.order("updated_at ASC")
      else
        entries = entries.order("title ASC")
      end
      if ( @nest.admin?(current_user) )
        @entries = entries
      else
        @entries = entries.where("released_at IS NOT NULL AND released_at < now()")
      end
    end
  end
  def new
    @space = Space.find(params[:space])
    @entries = @space.entries.order("updated_at DESC")
    @nest = @space.nest
    if ( @space )
      @entry = Entry.new()
    end
  end
  def create
    @space = Space.find(params[:space])
    if ( @space )
      entry = params.require(:entry).
        permit(:title, :body, :edit_level, :body_type)

      @entry = Entry.new(entry)
      @entry.author = current_user
      @entry.space = @space
      if ( @entry.save )
        params[:entry].each do | key, attach |
          if ( key =~ /^attach_file_/ )
            upload_attach_file(attach, @entry)
          end
        end

        flash[:success] = t('entries.created')
        redirect_to edit_entry_path(@entry)
      else
        redirect_to new_entry_path(space: @space)
      end
    end
  end
  def show
    @entry = Entry.find(params[:id])
    @space = @entry.space
    @nest = @space.nest
    @comment = Comment.new
  end
  def edit
    @entry = Entry.find(params[:id])
    @space = @entry.space
    @nest = @space.nest
    if ( !@entry.released? )
      flash[:danger] = t('entries.not_released')
    end
  end
  def update
    @entry = Entry.find(params[:id])
    entry = params.require(:entry).
      permit(:title, :body)

    @entry.attributes = entry
    @entry.save
    History.log(:update, @entry)
    params[:entry].each do | key, attach |
      if ( key =~ /^attach_file_/ )
        upload_attach_file(attach, @entry)
      end
    end

    redirect_to edit_entry_path(@entry)
  end
  def release
    @entry = Entry.find(params[:id])
    @entry.released_at = Time.now
    @entry.save
    flash[:success] = t('entries.released')
    redirect_to edit_entry_path(@entry)
  end
  def unrelease
    @entry = Entry.find(params[:id])
    @entry.released_at = nil
    @entry.save
    flash[:danger] = t('entries.not_released')
    redirect_to edit_entry_path(@entry)
  end
  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy

    redirect_to entries_path(space: @entry.space)
  end
end
