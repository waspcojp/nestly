class Invite < ApplicationRecord
  belongs_to :nest
  belongs_to :inviter, class_name: "User"
  before_create :set_invitation_token
  before_save :set_expire

  def create_user(nest = nil)
    user_mail = UserMailAddress.where(mail_address: self.to_mail).first
    if ( !user_mail )
      user = User.new(user_name: self.to_mail,
                      default_display_name: self.to_mail)
      user.save(validate: false)
      user.append_mail(self.to_mail)
      p NoticeMailer.with(user: user,
                          invite: self).user_create_mail.deliver_now
      if ( nest )
        nest.join(user)
      end
      if (( self.nest ) &&
          ( self.nest != nest ))
        self.nest.join(user)
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
