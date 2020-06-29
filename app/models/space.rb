class Space < ApplicationRecord
  belongs_to :nest
  belongs_to :creater, class_name: "User"
  has_many :entries
  has_many :watches, dependent: :destroy, as: :target

  include LoggingHistory
  after_create :log_create
  after_update :log_update
  after_destroy :log_destroy

  module PublicationLevel
    include ControlLevel
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
  def admin?(user)
    if ( self.creater == user )
      true
    else
      self.nest.admin?(user)
    end
  end
  def readable?(user)
    if ( self.creater == user )
      true
    else
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
    self.nest.members.each do | member |
      case ( history.operation )
      when 'create'
        if ( self.readable?(member.user) )
          @watch = Watch.create(user: member.user,
                                target: self)
          @notice = Notice.create(user: member.user,
                                  history: history,
                                  watch: @watch)
          NoticeMailer.with(notice: @notice).space_create_mail.deliver_now
        else
          ;
        end
      end
    end
  end
private
end
