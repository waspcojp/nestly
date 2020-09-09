class Comment < ApplicationRecord
  belongs_to :entry
  belongs_to :parent, class_name: "Comment", optional: true
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
      I18n.t("users.withdrawal_member")
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
            NoticeMailer.with(notice: nil,
                              comment: self,
                              invite: invite).comment_create_mail.deliver_now
            ;
          end
        end
      end
    end
  end
  def send_message_callback(history)
    case ( history.operation )
    when "create"
      case (self.entry.space.notice_level)
      when Entry::NoticeLevel::DEFAULT
        self.entry.watches.each do | watch |
          if ( watch.active )
            if ( self.entry.readable?(watch.user) )
              send_notice(watch.user, history)
            end
          end
        end
      when Entry::NoticeLevel::ALL_MEMBERS
        self.entry.space.nest.members.each do | member |
          send_notice(member.user, history)
        end
      when Entry::NoticeLevel::INCLUDE_INVITED
        self.entry.space.nest.members.each do | member |
          send_notice(member.user, history)
        end
        self.entry.space.nest.invites.each do | invite |
          if ( UserMailAddress.where(mail_address: invite.to_mail).size == 0 )
            send_notice(nil, history, invite)
          end
        end
      else
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
      NoticeMailer.with(notice: @notice,
                        comment: self).comment_create_mail.deliver_now
    else
      invite.save
      NoticeMailer.with(notice: nil,
                        comment: self,
                        invite: invite).comment_create_mail.deliver_now
    end
  end
end
