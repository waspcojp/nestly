class SpaceRepliesMailbox < ApplicationMailbox
  def process
    dump
    @space = nil
    mail.to.each do | to |
      if ( to.match(/^space-(.+)@(.+)/) )
        @space = Space.where(localpart: $1).first
        break
      end
    end
    if ( @space )
      @user = nil
      mail.from.each do | from |
        address = UserMailAddress.where(mail_address: from).first
        if ( address )
          @user = address.user
          break
        else
          if ( @invite = @space.nest.invited?(from) )
            @user = @invite.create_user(true)
            break
          end
        end
      end
      if (( @user ) &&
          ( @space.preparable?(@user) ))
        parts = parse_mail

        @space.watch = @user
        @entry = Entry.new(
                           title: mail.subject,
                           body: clean_body(parts[0][:body]),
                           body_type: Entry::BodyType::TEXT,
                           released_at: Time.now,
                           author: @user,
                           space: @space)
        @entry.save
        parts.shift
        parts.each do | part |
          upload_attach(@entry, @user, part)
        end

      else
        if ( @user )
          print "** This user is not commentable #{@user.default_display_name}\n"
        else
          print "** This user is not found\n"
        end
      end
    else
      print "** This space can not found #{localpart}\n"
    end
  end
private
  def dump
    print "space ----------------------------------\n"
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
