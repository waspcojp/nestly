class NoticeMailer < ApplicationMailer
  def space_create_mail
    if ( !params[:mail] )
      @notice = params[:notice]
      @space = @notice.watch.target
      @notice.user.user_mail_addresses.each do | mail_address |
        if ( mail_address.notice )
          p mail(to: mail_address.mail_address,
                 from: "space-#{@space.localpart}@#{Settings.mail[:domain_part]}",
                 subject: 'new space created')
        end
      end
    else
      p mail(to: params[:mail],
             from: "space-#{@space.localpart}@#{Settings.mail[:domain_part]}",
             subject: 'new space created')
    end
  end
  def entry_create_mail
    if ( !params[:mail] )
      @notice = params[:notice]
      @entry = @notice.watch.target
      @notice.user.user_mail_addresses.each do | mail_address |
        if ( mail_address.notice )
          p mail(to: mail_address.mail_address,
                 from: "entry-#{@entry.localpart}@#{Settings.mail[:domain_part]}",
                 subject: "[#{@entry.space.title_id}] #{@entry.title}")
        end
      end
    else
      p mail(to: params[:mail],
             from: "entry-#{@entry.localpart}@#{Settings.mail[:domain_part]}",
             subject: "[#{@entry.space.title_id}] #{@entry.title}")
    end
  end
  def comment_create_mail
    @notice = params[:notice]
    @comment = params[:comment]
    @entry = @notice.watch.target
    @notice.user.user_mail_addresses.each do | mail_address |
      if ( mail_address.notice )
        p mail(to: mail_address.mail_address,
               from: "comment-#{@entry.localpart}@#{Settings.mail[:domain_part]}",
               subject: "[#{@entry.space.title_id}:#{@entry.comment_count}] #{@entry.title}")
      end
    end
  end
end
