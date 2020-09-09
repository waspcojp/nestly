class Invite < ApplicationRecord
  belongs_to :nest
  belongs_to :inviter, class_name: "User"
  before_create :set_invitation_token
  before_save :set_expire

  def member_name(nest)
    self.to_mail
  end
  def create_user(send_token = false)
    user_mail = UserMailAddress.where(mail_address: self.to_mail).first
    if ( !user_mail )
      p user = User.new(user_name: self.to_mail,
                        default_display_name: self.to_mail)
      user.save(validate: false)
      user.append_mail(self.to_mail)
      NoticeMailer.with(user: user,
                        invite: self,
                        send_token: send_token).user_create_mail.deliver_now
      if ( self.nest )
        self.nest.join(user)
      end
      SpaceMember.where(target: self).each do | space_member |
        space_member.target = user
        space_member.save
      end
      user
    else
      nil
    end
  end
private
  def set_expire
    self.expired_at = Time.now + eval(Settings.invitation[:expire])
  end
  def set_invitation_token
    self.invitation_token = SecureRandom.uuid
  end
end
