class UserMailAddress < ApplicationRecord
  belongs_to :user
  validates :mail_address, uniqueness: true

  def authenticate(at = Time.now)
    self.authorized_at = at
    if ( self.user.user_mail_addresses.size < 2 )
      self.notice = true
    end
    save
  end
end
