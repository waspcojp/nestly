class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere
  routing /comment-(.+)@(.*)nestly.net/i => :comment_replies
  routing /entry-(.+)@(.*)nestly.net/i => :entry_replies
  routing /space-(.+)@(.*)nestly.net/i => :space_replies
private
  def clean_body(text)
    body = ""
    com = []
    text.force_encoding('utf-8').split(/\r\n/).each do | line |
      break if ( line == "-- " )
      if ( line =~ /^>/ )
        com << line
      else
        if ( com.size > 2 )
          com = []
        end
        if ( com.size > 0 )
          body << com.join("\r\n")
        end
        body << line + "\r\n"
      end
    end
    body
  end
  def upload_attach(obj, user, part)
    if ( part[:filename] )
      @attach_file = AttachFile.new
      @attach_file.body = part[:body]
      @attach_file.name = part[:filename]
      @attach_file.content_type = part[:mime]
      @attach_file.owner = user
      @attach_file.file = obj
      @attach_file.save
    end
  end
  def parse_mail
    parts = []
    if ( !mail.multipart? )
      parts << {
        body: mail.body.decoded,
        mime: "text/plain"
      }
    else
      mail.body.parts.each do | part |
        if ( part.multipart? )
          part.parts.each do | p_part |
            parts << {
              body: p_part.body.decoded,
              filename: p_part.filename,
              mime: p_part.mime_type
            }
          end
        else
          parts << {
            body: part.body.decoded,
            filename: part.filename,
            mime: part.mime_type
          }
        end
      end
    end
=begin
    parts.each do | part |
      print "Mime-Type: ", part[:mime], "\n"
      print "Filename: ", part[:filename], "\n"
      if ( part[:mime] =~ /^text/ )
        print part[:body]
      else
        print "bin\n"
      end
    end
=end
    parts
  end
end
