# -*- coding: utf-8 -*-
class Nest < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :design, class_name: "NestTop"
  has_many :members, class_name: "NestMember"
  has_many :spaces, class_name: "Space"
  has_many :invites, class_name: "Invite"

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
  def member_name(user)
    member = self.member?(user)
    if ( member)
      member.display_name
    else
      ""
    end
  end
  def owner_name
    member_name(self.owner)
  end
  #
  # エントリやスペースの可視性はそれぞれで管理されているのでここではあまりうるさく言わない
  #
  def visible?(user)
    if ( self.owner_id == user.id )
      true
    else
      if ( self.join_method == JoinMethod::FREE_JOIN )
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
        else
          false
        end
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
=begin
  def invites(user = nil)
    if ( user )
      Invite.where(nest: self,
                   inviter: user).where("( expired_at IS NULL ) or ( expired_at > now() )")
    else
      Invite.where(nest: self).where("( expired_at IS NULL ) or ( expired_at > now() )")
    end
  end
=end
  def invited?(mail)
    Invite.where(nest: self,
                 to_mail: mail).first
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
    if ( user.instance_of? User )
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
    else
      nil
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
      if ( user )
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
      if ( user.id == 1 )
        ret = true
      else
        ret = false
      end
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

