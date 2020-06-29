class ApplicationController < ActionController::Base
  include Pundit
  before_action :require_login

  protect_from_forgery with: :exception

  def from_smartphone?
    request.from_smartphone?
  end
  def forbidden
    render :status => :forbidden, :text => "forbidden"
  end

  def internal_server_error
    render :status => 500, template: 'errors/error_500'
  end

  def render_404
    render :status => 404, template: 'errors/error_404'
  end
  def redirect_to_404
    redirect_to "/404.html"
  end

protected

  def not_authenticated
    redirect_to "/login"
  end
  def _create_icon(obj, image, x, y, width, height)
    if ( icon = image )
      @icon = Icon.new
      @icon.name = icon.original_filename
      @icon.content_type = icon.content_type
      @icon.owner_id = current_user.id
      image = icon.read
      original_image = Magick::Image.from_blob(image).first
      icon_image = original_image.dup
    else
      if obj.icon_image_id
        @icon = Icon.find(obj.icon_image_id)
        image = @icon.body
        original_image = Magick::Image.from_blob(image).first
        icon_image = original_image.dup
      else
        return nil
      end
    end
    if ( x && y && width && height )
      x = x.to_i
      y = y.to_i
      width = width.to_i
      height = height.to_i

      icon_image.auto_orient!
      if x >= 0 && y >= 0
        icon_image.crop!(x, y, width, height)
      end

      icon_image_192 = _resize_icon(icon_image.dup, original_image, 192, 192)
      icon_image_192.format = "png"
      icon_image_140 = _resize_icon(icon_image.dup, original_image, 140, 140)

      icon_image_45 = _resize_icon(icon_image.dup, original_image, 45, 45)

      @icon.body = image
      @icon.size_140 = icon_image_140.to_blob
      @icon.size_45 = icon_image_45.to_blob
      @icon.size_192 = icon_image_192.to_blob
      @icon.x = x
      @icon.y = y
      @icon.width = width
      @icon.height = height
      @icon.save
      return @icon
    end
  end
  def _resize_icon(image, original_image, width, height)
    image_width = (image.columns < original_image.columns) ? width : width * original_image.columns / image.columns
    image_height = (image.rows < original_image.rows ) ? height : height * original_image.rows / image.rows
    image.resize_to_fit!(image_width, image_height)
    image.format = 'png'
    icon = Magick::Image.new(width, height){ self.background_color = '#ffffff' }
    icon.format = 'png'
    icon.composite!(image, Magick::CenterGravity, Magick::OverCompositeOp)

    return icon
  end
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
private
  def upload_attach_file(attach_file, obj)
    code = 0
    if ( current_user )
      @attach_file = AttachFile.new
      @attach_file.body = attach_file.read
      @attach_file.name = attach_file.original_filename
      @attach_file.content_type = attach_file.content_type
      @attach_file.owner = current_user
      @attach_file.file_id = obj.id
      @attach_file.file_type = obj.class

      @attach_file.save
      id = @attach_file.id
      content_type = @attach_file.content_type
    else
      code = -10
      id = nil
      content_type = nil
    end
    return id, content_type, code
  end
end
