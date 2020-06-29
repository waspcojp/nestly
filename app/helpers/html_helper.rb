module HtmlHelper
  def icon_img_tag (obj, type, style = {})
    style.reverse_merge!({
                           :id => "icon-image",
                           :class => "icon_image"
                         })
    
    if obj
      if obj.icon_image_id 
        image_tag "/icons/download?type=#{type}&id=#{obj.icon_image_id.to_i}", style
      else
        case type
        when "side"
          image_tag "/images/piroron_192.png", style
        when "header"
          image_tag "/images/piroron_45.png", style
        when "list"
          image_tag "/images/piroron_140.png", style
        else
          image_tag "/images/piroron_140.png", style
        end
      end
    end
  end
  def icon_img_url(obj, type)
    if obj.icon_image_id
      attaches_download_url + "&type=#{type}&id=#{obj.icon_image_id.to_i}"
    else
      case type
      when "side"
        image_url "/images/piroron_192.png"
      when "header"
        image_url "/images/piroron_45.png"
      when "list"
        image_url "/images/piroron_140.png"
      else
        image_url "/images/piroron_140.png"
      end
    end
  end
  def str_to_html(str)
    if ( str )
      str.to_html
    else
      ''
    end
  end
end
class String
  def to_html(width = 560, height=315)
    self.
      gsub(/<(".*?"|'.*?'|[^'"])*?>/, '').
      gsub(/ /,'&nbsp;').
      gsub(/\r\n/,'<br />').
      gsub(/\r/,'<br />').
      gsub(/\n/,'<br />').
      gsub(/(https|http)\:[\w\:\.\/\~\?\=\-]*/) do | match |
      if ( match =~ /(https|http)\:\/\/(www.youtube.com|youtu.be)\/(.*)/ )
        path = $3
        site = $2
        if ( site == 'youtu.be' )
          id = path
        elsif ( path =~ /watch\?v=(.*)/ )
          id = $1
        elsif ( path =~ /embed\/(.*)/ )
          id = $1
        end
        "<iframe width=\"#{width}\" height=\"#{height}\" src=\"https://www.youtube.com/embed/#{id}\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>"
      else
        "<a href=\"#{match}\" target=\"_blank\">#{match}</a>"
      end
    end.html_safe
  end
end
