class NoticeMailer < ApplicationMailer
  def space_create_mail
    if ( !params[:invite] )
      @notice = params[:notice]
      @space = @notice.watch.target
      @invite = nil
      @notice.user.user_mail_addresses.each do | mail_address |
        if ( mail_address.notice )
          mail(to: mail_address.mail_address,
               from: "space-#{@space.localpart}@#{Settings.mail[:domain_part]}",
               subject: t('spaces.created')
               )
        end
      end
    else
      @space = params[:space]
      @invite = params[:invite]
      p mail(to: @invite.to_mail,
             from: "space-#{@space.localpart}@#{Settings.mail[:domain_part]}",
             subject: t('spaces.created')
             )
    end
  end
  def entry_create_mail
    if ( !params[:invite] )
      @notice = params[:notice]
      @entry = @notice.watch.target
      @invite = nil
      @notice.user.user_mail_addresses.each do | mail_address |
        if ( mail_address.notice )
          mail(to: mail_address.mail_address,
               from: "entry-#{@entry.localpart}@#{Settings.mail[:domain_part]}",
               subject: "[#{@entry.space.title_id}] #{@entry.title}")
        end
      end
    else
      @entry = params[:entry]
      @invite = params[:invite]
      p mail(to: @invite.to_mail,
             from: "entry-#{@entry.localpart}@#{Settings.mail[:domain_part]}",
             subject: "[#{@entry.space.title_id}] #{@entry.title}")
    end
  end
  def comment_create_mail
    if ( !params[:invite] )
      @notice = params[:notice]
      @comment = params[:comment]
      @entry = @comment.entry
      @notice.user.user_mail_addresses.each do | mail_address |
        if ( mail_address.notice )
          mail(to: mail_address.mail_address,
               from: "comment-#{@entry.localpart}@#{Settings.mail[:domain_part]}",
               subject: "[#{@entry.space.title_id}:#{@entry.comment_count}] #{@entry.title}")
        end
      end
    else
      @comment = params[:comment]
      @entry = @comment.entry
      @invite = params[:invite]
      p mail(to: @invite.to_mail,
             from: "comment-#{@entry.localpart}@#{Settings.mail[:domain_part]}",
             subject: "[#{@entry.space.title_id}:#{@entry.comment_count}] #{@entry.title}")
    end
  end
  def user_create_mail
    @user = params[:user]
    @invite = params[:invite]
    @user.user_mail_addresses.each do | mail_address |
      p mail(to: mail_address.mail_address,
             from: "Nestly <no-reply@#{Settings.mail[:domain_part]}>",
             subject: t('users.created'))
    end
  end
end
