class NoticeMailer < ApplicationMailer
  def space_create_mail
    @notice = params[:notice]
    @notice.user.user_mail_addresses.each do | mail_address |
      if ( mail_address.notice )
        mail(to: mail_address.mail_address, subject: 'new space created')
      end
    end
  end
  def entry_create_mail
    @notice = params[:notice]
    @entry = @notice.watch.target
    @notice.user.user_mail_addresses.each do | mail_address |
      if ( mail_address.notice )
        mail(to: mail_address.mail_address,
             from: "#{@entry.localpart}@#{Settings.mail[:domain_part]}",
             subject: "[#{@entry.title_id}] #{@entry.title}")
      end
    end
  end
  def comment_create_mail
    @notice = params[:notice]
    @comment = params[:comment]
    @entry = @notice.watch.target
    @notice.user.user_mail_addresses.each do | mail_address |
      if ( mail_address.notice )
        mail(to: mail_address.mail_address,
             from: "#{@entry.localpart}@#{Settings.mail[:domain_part]}",
             subject: "[#{@entry.title_id}:#{@entry.comment_count}] #{@entry.title}")
      end
    end
  end
end
