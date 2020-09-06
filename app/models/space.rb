class Space < ApplicationRecord
  belongs_to :nest
  belongs_to :creater, class_name: "User"
  has_many :entries
  has_many :members, class_name: "SpaceMember"
  has_many :watches, dependent: :destroy, as: :target

  include LoggingHistory
  after_create :log_create
  after_update :log_update
  after_destroy :log_destroy
  before_save :create_ids

  module PublicationLevel
    include ControlLevel
    def self.types(user)
      if (( user ) &&
          ( user.expire_use_admin ) &&
          ( user.expire_use_admin > Time.now ))
        TYPES
      else
        TYPES
      end
    end
  end
  module NoticeLevel
    include NoticeLevelHelper
    def self.types(user)
      if (( user ) &&
          ( user.expire_use_admin ) &&
          ( user.expire_use_admin > Time.now ))
        TYPES + [
                 [ I18n.t("spaces.member_only"), PRIVATE_MEMBER_ONLY ]
                ]
      else
        types = []
        TYPES.each do | type |
          if ( type[1] != PRIVATE_MEMBER_ONLY )
            types << type
          end
        end
        types
      end
    end
  end
  module PreparationLevel
    include PreparationLevelHelper
  end
  module ClassName
    CLASSES = [
               [ I18n.t('space_class.board'), "Board"],
               [ I18n.t('space_class.information'), "Information"]
              ]
  end

  def watch(user)
    ret = self.watches.where(user: user).first
  end
  def watch=(user, active = true)
    @watch = self.watches.where(user: user).first
    if ( !@watch )
      @watch = Watch.new(target: self,
                         user: user)
    end
    @watch.active = active
    @watch.save
  end
  def admin?(user, deep = true)
    if ( self.creater == user )
      true
    else
      if ( self.nest.admin?(user) )
        true
      else
        if ( deep )
          member = self.members.where(target: user).first
          if (( member ) &&
              ( member.admin ))
            true
          else
            false
          end
        end
      end
    end
  end
  def member?(target)
    self.members.where(target: target).first ? true : false
  end
  def readable?(user)
    if ( self.admin?(user) )
      true
    else
      if ( self.released? )
        case self.publication_level
        when  PublicationLevel::OPEN_GLOBAL
          true
        when  PublicationLevel::OPEN
          user ? true : false
        when  PublicationLevel::MEMBERS_ONLY
          self.nest.member?(user) ? true : false
        when  PublicationLevel::BOARDS_ONLY
          self.nest.admin?(user) ? true : false
        when PublicationLevel::PRIVATE_MEMBER_ONLY
          self.members.where(user: user).first ? true : false
        end
      else
        false
      end
    end
  end
  def preparable?(user)
    if ( self.creater == user )
      true
    else
      case self.preparation_level
      when  PreparationLevel::MEMBERS_ONLY
        self.nest.member?(user) ? true : false
      when  PreparationLevel::BOARDS_ONLY
        self.nest.admin?(user) ? true : false
      end
    end
  end
  def send_message_callback(history)
    case ( history.operation )
    when 'update'
      if (( self.released_at ) &&
          ( self.released_at < Time.now ) &&
          ( self.previous_changes[:released_at] ))
        case (self.notice_level)
        when NoticeLevel::DEFAULT
          self.nest.members.each do | member |
            if ( self.readable?(member.user) )
              send_notice(member.user, history)
            else
              ;
            end
          end
        when NoticeLevel::ALL_MEMBERS
          self.nest.members.each do | member |
            send_notice(member.user, history)
          end
        when NoticeLevel::INCLUDE_INVITED
          self.nest.members.each do | member |
            send_notice(member.user, history)
          end
          self.nest.invites.each do | invite |
            send_notice(nil, history, invite)
          end
        else
        end
      end
    end
  end
  def text(length = -1, width = 560, height=315)
    description.gsub(/\r\n/,'').gsub(/\r/,'').gsub(/\n/,'')[0..length].to_html(width, height)
  end
private
  def send_notice(user, history, invite = nil)
    if ( user )
      @watch = Watch.where(user: user,
                           target: self).first
      if ( !@watch )
        @watch = Watch.create(user: user,
                              target: self)
      end
      @notice = Notice.create(user: user,
                              history: history,
                              watch: @watch)
      NoticeMailer.with(notice: @notice).space_create_mail.deliver_now
    else
      invite.save
      NoticeMailer.with(notice: nil,
                        space: self,
                        invite: invite).space_create_mail.deliver_now
    end
  end
  def create_ids
    if (( !self.title_id ) ||
        ( self.title_id == '' ))
      self.title_id = SecureRandom.uuid.gsub('-','')[0..7]
    end
    if self.localpart.nil?
      self.localpart = SecureRandom.uuid.gsub('-','')
    end
  end
end
