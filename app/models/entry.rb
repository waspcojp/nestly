class Entry < ApplicationRecord
  belongs_to :space
  belongs_to :author, class_name: "User"

  has_many :attach_files, as: :file
  has_many :watches, dependent: :destroy, as: :target
  has_many :comments
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
  module EditLevel
    include ControlLevel
  end
  module CommentLevel
    include ControlLevel
  end

  module BodyType
    NONE = 0
    TEXT = 1
    HTML = 2
    MD = 3
    ASCIIDOC = 4
    JSON = 5
    TYPES = [
             # [ "raw", NONE ],
             [ "text", TEXT ],
             [ "HTML", HTML ],
             [ "MarkDown", MD ],
             # [ "json", JSON ]
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
  def add_comment(user, param)
    comment = Comment.new(param)
    comment.author = user
    comment.entry = self
    self.comment_count += 1
    comment.number = self.comment_count
    self.save
    comment
  end
  def comment(no)
    ret = comments.where(number: no).first
    if (( ret ) &&
        ( ret.deleted_at ))
      ret = nil
    end
    ret
  end

  def author_name
    member = self.space.nest.member?(self.author)
    if ( member)
      member.display_name
    else
      ""
    end
  end
  def commentable?(user)
    if ( self.author == user )
      true
    else
      case self.space.entry_comment_level
      when  CommentLevel::OPEN_GLOBAL
        true
      when  CommentLevel::OPEN
        user ? true : false
      when  CommentLevel::MEMBERS_ONLY
        self.space.nest.member?(user) ? true : false
      when  CommentLevel::BOARDS_ONLY
        self.space.nest.admin?(user) ? true : false
      end
    end
  end
  def readable?(user)
    if (( self.author == user ) ||
        ( self.space.admin?(user) ))
      true
    else
      if (( self.released? ) &&
          ( self.space.released? ))
        case self.space.entry_publication_level
        when  PublicationLevel::OPEN_GLOBAL
          true
        when  PublicationLevel::OPEN
          user ? true : false
        when  PublicationLevel::MEMBERS_ONLY
          self.space.nest.member?(user) ? true : false
        when  PublicationLevel::BOARDS_ONLY
          self.space.nest.admin?(user) ? true : false
        end
      else
        false
      end
    end
  end
  def editable?(user)
    if ( self.author == user )
      true
    else
      case self.space.entry_edit_level
      when  EditLevel::OPEN_GLOBAL
        true
      when  EditLevel::OPEN
        user ? true : false
      when  EditLevel::MEMBERS_ONLY
        self.space.nest.member?(user) ? true : false
      when  EditLevel::BOARDS_ONLY
        self.space.nest.admin?(user) ? true : false
      end
    end
  end
  def text(length = -1, width = 560, height=315)
    case body_type
    when BodyType::TEXT
      body.gsub(/\r\n/,'').gsub(/\r/,'').gsub(/\n/,'')[0..length].to_html(width, height)
    when BodyType::HTML
      body.gsub(/\<.*?\>/,'')[0..length]
    when BodyType::MD
      body.gsub(/(^#+|\*\s|\s*)/,'')[0..length]
    end
  end
  def send_message_callback(history)
    case ( history.operation )
    when "update"
      if (( self.released_at ) &&
          ( self.released_at < Time.now ) &&
          ( self.previous_changes[:released_at] ))
        case (self.notice_level)
        when NoticeLevel::DEFAULT
          self.space.watches.each do | watch |
            if ( watch.active )
              if ( self.readable?(watch.user) )
                send_notice(watch.user, history)
              else
                ;
              end
            end
          end
        when NoticeLevel::ALL_MEMBERS
          self.space.nest.members.each do | member |
            send_notice(member.user, history)
          end
        when NoticeLevel::INCLUDE_INVITED
          self.space.nest.members.each do | member |
            send_notice(member.user, history)
          end
          self.space.nest.invites.each do | invite |
            send_notice(nil, history, invite)
          end
        else
        end
      end
    end
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
      NoticeMailer.with(notice: @notice).entry_create_mail.deliver_now
    else
      invite.save
      NoticeMailer.with(notice: nil,
                        entry: self,
                        invite: invite).entry_create_mail.deliver_now
    end
  end
  def create_ids
    if self.localpart.nil?
      self.localpart = SecureRandom.uuid.gsub('-','')
    end
  end
end
