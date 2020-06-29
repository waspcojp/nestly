module ApplicationHelper
  def icon_img_tag (obj, type)
    if obj.icon_image_id 
      "<img id=\"icon-image\" class=\"icon_image\" src=\"/attaches/download?type=#{type}&id=#{obj.icon_image_id.to_i}\" title=\"#{obj.name}\" />".html_safe
    else
      case type
      when "side"
        image_tag "piroron_192.png", class: "icon_image", id: "icon-image", title: obj.name
      when "header"
        image_tag "piroron_45.png", id: "icon-image", title: obj.name
      when "list"
        image_tag "piroron_140.png", id: "icon-image", title: obj.name
      else
        image_tag "piroron_140.png", id: "icon-image", title: obj.name
      end
    end
  end
  def icon_img_url(obj, type)
    if obj.icon_image_id
      attaches_download_url + "&type=#{type}&id=#{obj.icon_image_id.to_i}"
    else
      case type
      when "side"
        image_url "piroron_192.png"
      when "header"
        image_url "piroron_45.png"
      when "list"
        image_url "piroron_140.png"
      else
        image_url "piroron_140.png"
      end
    end
  end
  def publication_control_icon(obj)
    sub_icon = nil
    if obj.publication_control == PublicationLevel::OPEN
      sub_icon = "public_img"
    else
      sub_icon = "private_img"
    end
    sub_icon
  end
  def publication_control_name(obj)
    case obj.publication_control
    when PublicationLevel::OPEN
      return      ""
    when PublicationLevel::PRIVATE
      return "Private"
    else
      return ""
    end
  end
end
