class IconsController < ApplicationController
  def create
    id, code = _upload
    render json: { id: id, code: code }
  end
  def profile_upload
    id, code = _upload
    if ( code == 0 )
      current_user.profile_image_id = id
      current_user.save
    end
    render json: { id: id, code: code }
  end
  def channel_icon_upload
    @channel = Channel.find(params[:id])
    if ( @channel.owner == current_user )
      id, code = _upload
      if ( code == 0 )
        @channel.icon_image_id = id
        @channel.save
      end
    else
      code = -10
      id = nil
    end
    render json: { id: id, code: code }
  end
  def set_profile
    code = 0
    if ( current_user )
      @icon = Icon.find(params[:id])
      if (( @icon ) &&
          ( @icon.owner_id = current_user.id ))
        current_user.profile_image_id = @icon.id
        current_user.save
      else
        code = -10
      end
    else
      code = -10
    end
    render json: { code: code }
  end
  def download
    @icon = Icon.find(params[:id])
    if ( !@icon )
      @icon = Icon.new
    end
    disposition = params[:disposition] ? params[:disposition] : 'inline'

    case params[:type]
    when "header"
      icon = @icon.size_45
    when "list"
      icon = @icon.size_140
    when "side"
      icon = @icon.size_192
    else
      icon = @icon.size_140
    end
    send_data(icon, {
                filename: @icon.name.gsub(/\.svg/, "\.png"),
                type: "image/png", #@icon.content_type,
                disposition: disposition })
  end
  def edit_icon
    @icon = Icon.find(params[:id])
    if ( !@icon )
      @icon = Icon.new
    end
    disposition = params[:disposition] ? params[:disposition] : 'inline'
    send_data(@icon.body, {
                filename: @icon.name,
                type: @icon.content_type,
                disposition: disposition })
  end
  def get_icon
    if (( params[:id] ) &&
        ( params[:id] != '' ))
      @icon = Icon.find(params[:id])
      if ( !@icon )
        @icon = Icon.new
      end
      disposition = params[:disposition] ? params[:disposition] : 'inline'
      filename = @icon.name
      case params[:type]
      when "header"
        body = @icon.size_45
        type = "image/png"
      when "list"
        body = @icon.size_140
        type = "image/png"
      when "side"
        body = @icon.size_192
        type = "image/png"
      else
        body = @icon.body
        type = @icon.content_type
      end
    else
      case params[:type]
      when "header"
        filename = 'piroron_45.png'
      when "list"
        filename = 'piroron_140.png'
      when "side"
        filename = 'piroron_192.png'
      else
        filename = 'piroron_192.png'
        type = "image/png"
      end
      type = "image/png"
      disposition = params[:disposition] ? params[:disposition] : 'inline'
      body = File.open("./public/images/#{filename}").read
    end
    send_data(body, {
                filename: filename,
                type: type,
                disposition: disposition })
  end
  def edit_icon_info
    if (params[:id])
      icon = Icon.find(params[:id])
      if icon
        render json: {
          code: 0,
          x: icon.x,
          y: icon.y,
          width: icon.width,
          height: icon.height
        }
      else
        render json: { code: -1 }
      end
    else
      render json: { code: -1 }
    end
  end
private
  def _upload
    p params
    code = 0
    if ( current_user )
      @icon = Icon.new
      @icon.body = params[:icons][:body].read
      @icon.name = params[:icons][:body].original_filename
      @icon.content_type = params[:icons][:body].content_type
      @icon.owner_id = current_user.id
      @icon.save
      id = @icon.id
    else
      code = -10
      id = nil
    end
    return id, code
  end
end
