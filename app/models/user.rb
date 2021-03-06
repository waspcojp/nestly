class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :user_mail_addresses, dependent: :destroy
  has_many :watches, dependent: :destroy
  has_many :nest_members, dependent: :destroy
  has_many :notices, dependent: :destroy

  validates :user_name, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || ( !crypted_password.nil? && changes["crypted_password"] ) }
  validates :password, confirmation: true, if: -> { new_record? || ( !crypted_password.nil? && changes["crypted_password"] ) }
  validates :password_confirmation, presence: true, if: -> { new_record? || ( !crypted_password.nil? && changes["crypted_password"] ) }
  before_save :set_uuid
  before_destroy :before_destroy                                                    
  after_create :after_create

  def mail_authorized?
    UserMailAddress.where("( user_id = :user_id ) and ( authorized_at is not null )",
                          { user_id: self.id }).count > 0 ? true : false
  end
  def mail_owner?(address)
    UserMailAddress.where(user: self,
                          mail_address: address).first
  end
  def append_mail(mail, auth = Time.now)
    if ( UserMailAddress.where(mail_address: mail).count == 0 )
      user_mail_address = UserMailAddress.create(user: self,
                                                 mail_address:mail)
      user_mail_address.authenticate(auth)
    else
      nil
    end
  end
  def self.mail_used?(address)
    UserMailAddress.where(mail_address: address).count > 0 ? true : false
  end
  def member_name(nest)
    member = NestMember.where(user: self,
                              nest: nest).first
    if ( member )
      member.display_name
    else
      ''
    end
  end
  def use_admin?
    (( self.expire_use_admin ) &&
     ( self.expire_use_admin > Time.now )) ? true : false
  end

  # here is patch for user locking #############################
  def self.authenticate_with_locking(*credentials, &block)
    ret = self.authenticate_without_locking(*credentials, &block)
    if ( ret.locked_at )
      nil
    else
      ret
    end
  end
  class << self
    alias :authenticate_without_locking :authenticate
    alias :authenticate :authenticate_with_locking
  end
  ##############################################################

#  alias authenticate_without_locking authenticate
#  alias authenticate authenticate_with_locking
  alias append_mail_back  append_mail

private
  def set_uuid
    if ( !self.uuid )
      self.uuid = SecureRandom.uuid
    end
  end
  def after_create
    if ( self.id != 1 )
      nest = Nest.find(1)
      nest.join(self)
    end
  end
  def before_destroy
    SpaceMember.where(target: self).each do | space_member |
      space_member.destroy
    end
  end
end
