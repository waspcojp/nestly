class EntryRepliesMailbox < ApplicationMailbox
  def process
    dump
    @entry = nil
    mail.to.each do | to |
      if ( to.match(/^entry-(.+)@(.+)/) )
        @entry = Entry.where(localpart: $1).first
        break
      end
    end
    if ( @entry )
      @user = nil
      mail.from.each do | from |
        address = UserMailAddress.where(mail_address: from).first
        if ( address )
          @user = address.user
          break
        else
          if ( @invite = @entry.space.nest.invited?(from) )
            @user = @invite.create_user(true)
            break
          end
        end
      end

      if ( ( @user ) &&
           ( @entry.commentable?(@user) ))
        no = nil
        if ( mail.subject.match(/\[(.*?)\]/) )
          id = $1
        end

        parts = parse_mail

        @entry.watch = @user
        @comment = @entry.add_comment(@user,
                                      body: clean_body(parts[0][:body]))
        @comment.save
        parts.shift
        parts.each do | part |
          upload_attach(@comment, @user, part)
        end

      else
        if ( @user )
          print "** This user is not commentable #{@user.default_display_name}\n"
        else
          print "** This user is not found\n"
        end
      end
    else
      print "** This entry can not found #{localpart}\n"
    end
  end
private
  def dump
    print "entry ----------------------------------\n"
    print "Return-Path: ", mail.return_path, "\n"
    print "From: ", mail.from, "\n"
    print "To: ", mail.to, "\n"
    print "Subject: ", mail.subject, "\n"
    print "Date: ", mail.date, "\n"
    print "Message-ID: ", mail.message_id, "\n"
    p mail.body
    print "--------------\n"
    print "--------------\n"
    p mail
    print "----------------------------------------\n"
  end
end
