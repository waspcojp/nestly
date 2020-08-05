class EntryRepliesMailbox < ApplicationMailbox
  def process
    dump
    @user = nil
    mail.from.each do | from |
      address = UserMailAddress.where(mail_address: from).first
      if ( address )
        @user = address.user
        break
      end
    end
    if ( @user )
      @entry = nil
      mail.to.each do | to |
        if ( to.match(/^entry-(.+)@(.+)/) )
          @entry = Entry.where(localpart: $1).first
          break;
        end
      end
      if (( @entry ) &&
          ( @entry.commentable?(@user) ))
        no = nil
        if ( mail.subject.match(/\[(.*?)\]/) )
          id = $1
        end
        p id
        

        @entry.watch = @user
        @comment = @entry.add_comment(@user, body: clean_body(mail.body.to_s))
        @comment.save
      else
        #
        # send entry not found error
        #
      end
    else
      #
      # send user not found error
      #
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
    print mail.body, "\n"
    print "--------------\n"
    print "--------------\n"
    p mail
    print "----------------------------------------\n"
  end
end
