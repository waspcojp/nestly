class Comment < ApplicationRecord
  belongs_to :entry
  belongs_to :author, class_name: "User"
  belongs_to :deleted_by, class_name: "User", optional: true
  has_many :attach_files, as: :file
  include LoggingHistory
  after_create :log_create
  after_update :log_update
  after_destroy :log_destroy

  def author_name
    member = self.entry.space.nest.member?(self.author)
    if ( member)
      member.display_name
    else
      ""
    end
  end
  def deletable?(user)
    if ( self.author == user )
      true
    else
      self.entry.space.nest.admin?(user)
    end
  end
  def send_message_callback(history)
    self.entry.watches.each do | watch |
      if ( watch.active )
        case ( history.operation )
        when 'create'
          if ( self.entry.readable?(watch.user) )
            @notice = Notice.create(user: watch.user,
                                    history: history,
                                    watch: watch)
            NoticeMailer.with(notice: @notice,
                              comment: self).comment_create_mail.deliver_now
          else
            ;
          end
        end
      end
    end
  end
end
