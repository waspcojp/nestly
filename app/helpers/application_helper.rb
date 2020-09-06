module ApplicationHelper
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
