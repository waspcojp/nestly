class CommentRepliesMailbox < ApplicationMailbox
  def process
    #dump
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
            @user = @invite.create_user(true)
            break
          end
        end
      end

      if (( @user ) &&
          ( @entry.commentable?(@user) ))
        no = nil
        if ( mail.subject.match(/\[(.*?)(:(.+?)|)\]/) )
          id = $1
          no = $3
        end
        if ( no )
          parent = @entry.comment(no)
        else
          parent = nil
        end

        parts = parse_mail
          
        @entry.watch = @user
        @comment = @entry.add_comment(@user,
                                      body: clean_body(parts[0][:body]),
                                      parent: parent)
        @comment.save

        parts.shift
        parts.each do | part |
          upload_attach(@comment, @user, part)
        end
      else
        if ( @user )
          print "This user is not commentable #{@user.default_display_name}\n"
        else
          print "This user is not found\n"
        end
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
    if ( !mail.multipart? )
      print mail.body.decoded, "\n"
    else
      mail.body.parts.each do | part |
        print "---------\n"
        print "file-name: ", part.filename, "\n"
        print "mime-type: ", part.mime_type, "\n"
        print "-----\n"
        if ( part.multipart? )
          part.parts.each do | p_part |
            print "file-name: ", p_part.filename, "\n"
            print "mime-type: ", p_part.mime_type, "\n"
            print "---\n"
            print p_part.body.decoded, "\n"
          end
        else
          print part.body.decoded, "\n"
        end
      end
    end
    print "---------\n"
    print "methods", mail.body.parts[1].methods, "\n"
    p mail
  end
end
