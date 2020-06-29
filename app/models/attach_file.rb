class AttachFile < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :file, polymorphic: true
  before_save :make_thumb

  WIDTH = 200
  HEIGHT = 200

  def make_thumb
    if ( self.content_type =~ /^image/ )
      thumb_base = Magick::Image.from_blob(self.body).shift
      if ( ( thumb_base.columns < WIDTH ) ||
           ( thumb_base.rows < HEIGHT ) )
        self._thumb = _cover_white(thumb_base, WIDTH, HEIGHT).to_blob
      else
        self._thumb = _shrink_to_fill(thumb_base, WIDTH, HEIGHT).to_blob
      end
    else
      self._thumb = nil
    end
  end
  def thumb
    if ( self.content_type =~ /^image/ )
      self._thumb
    else
      fn = self.content_type.split('/').join('-')
      begin
        File.open("./public/images/content_types/#{fn}.png").read
      rescue
        File.open("./public/images/content_types/unknown.png").read
      end
    end
  end
  def readable?(user)
  end
private
  def _shrink_to_fill(image, width, height)
    image.resize_to_fill!(width, height)
    p image
  end
  def _cover_white(image, width, height)
    new_width = (image.columns < width) ? image.columns : width
    new_height = (image.rows < height) ? image.rows : height
    
    image.resize_to_fit!(new_width, new_height)
    image_out = Magick::Image.new(width, height)
    image_out.background_color = '#ffffff'
    image_out.format = 'png'
    image_out.composite!(image, Magick::CenterGravity, Magick::OverCompositeOp)
    image_out
  end
end
