class Invite < ApplicationRecord
  belongs_to :nest
  belongs_to :inviter, class_name: "User"
  before_create :set_invitation_token
  before_save :set_expire

private
  def set_expire
    p self.expired_at = Time.now + eval(Settings.invitation[:expire])
  end
  def set_invitation_token
    self.invitation_token = SecureRandom.uuid
  end
end
