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
  def admin?(target, deep = true)
    if ( target.instance_of? User )
      if ( self.creater == target )
        true
      else
        if ( self.nest.admin?(target) )
          true
        else
          if ( deep )
            member = self.members.where(target: target).first
            if (( member ) &&
                ( member.admin ))
              true
            else
              false
            end
          end
        end
      end
    else
      false
    end
  end
  def member?(target)
    self.members.where(target: target).first ? true : false
  end
  def readable?(target)
    if ( self.admin?(target) )
      true
    else
      if ( self.released? )
        case self.publication_level
        when  PublicationLevel::OPEN_GLOBAL
          true
        when  PublicationLevel::OPEN
          ( target ) && ( target.instance_of? User )? true : false
        when  PublicationLevel::MEMBERS_ONLY
          self.nest.member?(target) ? true : false
        when  PublicationLevel::BOARDS_ONLY
          self.nest.admin?(target) ? true : false
        when PublicationLevel::PRIVATE_MEMBER_ONLY
          self.member?(target)
        end
      else
        false
      end
    end
  end
  def preparable?(user)
    if ( self.admin?(user) )
      true
    else
      if ( self.readable?(user) )
        case self.preparation_level
        when  PreparationLevel::MEMBERS_ONLY
          self.nest.member?(user) ? true : false
        when  PreparationLevel::BOARDS_ONLY
          self.nest.admin?(user) ? true : false
        end
      else
        false
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
          self.watches.each do | watch |
            if ( self.readable?(watch.user) )
              send_notice(watch.user, history)
            end
          end
        when NoticeLevel::ALL_MEMBERS
          self.nest.members.each do | member |
            if ( self.readable?(member.user) )
              send_notice(member.user, history)
            end
          end
        when NoticeLevel::INCLUDE_INVITED
          self.nest.members.each do | member |
            if ( self.readable?(member.user) )
              send_notice(member.user, history)
            end
          end
          self.nest.invites.each do | invite |
            if ( self.readable?(invite) )
              send_notice(invite, history)
            end
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
  def send_notice(target, history)
    if ( target.instance_of? User )
      @watch = Watch.where(user: target,
                           target: self).first
      if ( !@watch )
        @watch = Watch.create(user: target,
                              target: self)
      end
      @notice = Notice.create(user: target,
                              history: history,
                              watch: @watch)
      NoticeMailer.with(notice: @notice).space_create_mail.deliver_now
    else
      target.save
      NoticeMailer.with(notice: nil,
                        space: self,
                        invite: target).space_create_mail.deliver_now
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
