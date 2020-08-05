class Space < ApplicationRecord
  belongs_to :nest
  belongs_to :creater, class_name: "User"
  has_many :entries
  has_many :admins, class_name: "SpaceAdmin"
  has_many :watches, dependent: :destroy, as: :target

  include LoggingHistory
  after_create :log_create
  after_update :log_update
  after_destroy :log_destroy
  before_save :create_ids

  module PublicationLevel
    include ControlLevel
  end
  module NoticeLevel
    include NoticeLevelHelper
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
          ( self.admins.where(user: user).first ) ? true : false
        else
          false
        end
      end
    end
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
    when 'create'
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
          send_notice(nil, history, invite.to_mail)
        end
      else
      end
    end
  end
private
  def send_notice(user, history, mail = nil)
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
