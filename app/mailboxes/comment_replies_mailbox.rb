class CommentRepliesMailbox < ApplicationMailbox
  def process
    dump
    @entry = nil
    localpart = nil
    mail.to.each do | to |
      if ( to.match(/^comment-(.+)@(.+)/) )
        localpart = $1
        @entry = Entry.where(localpart: localpart).first
        break;
      end
    end
    if ( @entry )
      @user = nil
      mail.from.each do | from |
        address = UserMailAddress.where(mail_address: from).first
        if ( address )
          if ( @entry.space.nest.member?(address.user) )
            @user = address.user
            break
          end
        else
          if ( @invite = @entry.space.nest.invited?(from) )
            p @invite
            @user = @invite.create_user(@entry.space.nest)
            break
          end
        end
      end
      p @user
      if (( @user ) &&
          ( @entry.commentable?(@user) ))
        no = nil
        if ( mail.subject.match(/\[(.*?)(:(.+?)|)\]/) )
          id = $1
          no = $3
        end
        p no
        if ( no )
          parent = @entry.comment(no)
        else
          parent = nil
        end

        @entry.watch = @user
        @comment = @entry.add_comment(@user,
                                      body: clean_body(mail.body.to_s),
                                      parent: parent)
        @comment.save
      else
        print "This user is not commentable #{@user.default_display_name}\n"
      end
    else
      print "This entry can not found #{localpart}\n"
    end
  end
private
  def dump
    print "comment"
    print "Return-Path: ", mail.return_path, "\n"
    print "From: ", mail.from, "\n"
    print "To: ", mail.to, "\n"
    print "Subject: ", mail.subject, "\n"
    print "Date: ", mail.date, "\n"
    print "Message-ID: ", mail.message_id, "\n"
    print mail.body, "\n"
    p mail
  end
end
