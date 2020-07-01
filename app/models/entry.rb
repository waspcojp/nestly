class Entry < ApplicationRecord
  belongs_to :space
  belongs_to :author, class_name: "User"

  has_many :attach_files, as: :file
  has_many :watches, dependent: :destroy, as: :target
  has_many :comments
  include LoggingHistory
  after_create :log_create
  after_destroy :log_destroy
  before_save :create_ids

  module PublicationLevel
    include ControlLevel
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
      case self.comment_level
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
    if ( self.author == user )
      true
    else
      case self.publication_level
      when  PublicationLevel::OPEN_GLOBAL
        true
      when  PublicationLevel::OPEN
        user ? true : false
      when  PublicationLevel::MEMBERS_ONLY
        self.space.nest.member?(user) ? true : false
      when  PublicationLevel::BOARDS_ONLY
        self.space.nest.admin?(user) ? true : false
      end
    end
  end
  def editable?(user)
    if ( self.author == user )
      true
    else
      case self.edit_level
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
    self.space.watches.each do | watch |
      if ( watch.active )
        case ( history.operation )
        when 'create'
          if ( self.readable?(watch.user) )
            @watch = Watch.create(user: watch.user,
                                  target: self)
            @notice = Notice.create(user: watch.user,
                                    history: history,
                                    watch: @watch)
            NoticeMailer.with(notice: @notice).entry_create_mail.deliver_now
          else
            ;
          end
        end
      end
    end
  end
private
  def create_ids
    if self.localpart.nil?
      self.localpart = SecureRandom.uuid.gsub('-','')
    end
  end
end
