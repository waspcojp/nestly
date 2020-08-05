class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere
  routing /comment-(.+)@nestly.net/i => :comment_replies
  routing /entry-(.+)@nestly.net/i => :entry_replies
  routing /space-(.+)@nestly.net/i => :space_replies
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
end
