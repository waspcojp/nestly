class Nest < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :design, class_name: "NestTop"
  has_many :members, class_name: "NestMember"
  has_many :spaces, class_name: "Space"

  module PublicationLevel
    include ControlLevel
  end
  module PreparationLevel
    include PreparationLevelHelper
  end

  module JoinMethod
    FREE_JOIN = 0
    MODERATED_BY_MEMBER = 1
    MODERATED_BY_BOARD = 2
    MODERATED_BY_OWNER = 3
    INVITE_BY_MEMBER = 11
    INVITE_BY_BOARD = 12
    INVITE_BY_OWNER = 13
    INVITE_BY_URL = 14
    PRIVATE = 99

    TYPES = [
             [ I18n.t("free join"), FREE_JOIN ],
             # [ "moderated by member", MODERATED_BY_MEMBER ],
             # [ "moderated by board", MODERATED_BY_BOARD ],
             # [ "moderated by owner", MODERATED_BY_OWNER ],
             [ I18n.t("invites.by member"), INVITE_BY_MEMBER ],
             [ I18n.t("invites.by board"), INVITE_BY_BOARD ],
             [ I18n.t("invites.by owner"), INVITE_BY_OWNER ],
             [ I18n.t("invites.by URL"), INVITE_BY_URL ],
             [ I18n.t("private"), PRIVATE ]
            ]
  end
  def owner_name
    member = self.member?(self.owner)
    if ( member)
      member.display_name
    else
      ""
    end
  end
  def visible?(user)
    if ( self.owner == user )
      true
    else
      case ( publication_level )
      when PublicationLevel::MEMBERS_ONLY
        member?(user) ? true : false
      when PublicationLevel::PRIVATE
        false
      when PublicationLevel::OPEN
        user ? true : false
      when PublicationLevel::OPEN_GLOBAL
        true
      end
    end
  end
  def joinable?(user)
    if (( self.owner == user ) ||
        ( member?(user) ))
      false
    else
      if ( self.join_method == JoinMethod::FREE_JOIN )
        true
      else
        false
      end
    end
  end
  def invites(user = nil)
    if ( user )
      InviteUser.where(nest: self,
                       inviter: user,
                       expired_at: nil)
    else
      InviteUser.where(nest: self,
                       expired_at: nil)
    end
  end
  def join(user, inviter = nil, name = nil)
    if ( NestMember.where(nest: self,
                          user: user).count == 0 )
      NestMember.create(nest: self,
                        user: user,
                        board: false,
                        inviter: inviter,
                        display_name: name || user.default_display_name)
    else
      nil
    end
  end
  def admin?(user)
    if ( self.owner == user )
      true
    else
      member = member?(user)
      if ( member )
        member.board
      else
        false
      end
    end
  end
  def resign(user)
    if ( member = member?(user) )
      member.destroy
    end
  end
  def resinable?(user)
    (( user ) &&
     ( self.owner != user ) &&
     ( member?(user) )) ? true : false
  end
  def member?(user)
    if ( user )
      if ( user.instance_of? String )
        user_mail_address = UserMailAddress.where(mail_address: user).first
        if ( user_mail_address )
          user = user_mail_address.user
        else
          user = nil
        end
      end
      if ( ( user ) &&
           ( user.instance_of? User ) )
        NestMember.where(user: user,
                         nest: self).first
      else
        nil
      end
    else
      nil
    end
  end
  def invitable?(user)
    if (( user ) &&
        ( user.mail_authorized? ))
      case (self.join_method)
      when JoinMethod::INVITE_BY_OWNER
        if ( self.owner == user )
          ret = true
        end
      when JoinMethod::INVITE_BY_MEMBER
        if ( self.owner == user )
          ret = true
        else
          member = member?(user)
          if ( member )
            ret = true
          end
        end
      when JoinMethod::INVITE_BY_BOARD
        if ( self.owner == user )
          ret = true
        else
          member = member?(user)
          if ( ( member ) &&
               ( member.board ) )
            ret = true
          end
        end
      end
    else
      ret = false
    end
    ret
  end
  def preparable?(user)
    if ( self.owner == user )
      true
    else
      case self.preparation_level
      when  PreparationLevel::MEMBERS_ONLY
        self.member?(user) ? true : false
      when  PreparationLevel::BOARDS_ONLY
        self.admin?(user) ? true : false
      end
    end
  end
  def enrollable?(address)
    (( !member?(address) ) &&
     ( AbuseInvite.where(nest: self,
                         mail_address: address).count == 0 )) ? true : false
  end
  def has_information?
    self.spaces.where(class_name: "Information").count > 0 ? true : false
  end
  def informations
    Entry.where(space_id: Space.where(class_name: "Information",
                                      nest_id: self.id))
  end
end

