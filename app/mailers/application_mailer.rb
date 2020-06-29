class ApplicationMailer < ActionMailer::Base
  default from: Settings.mail.from_address
  layout 'mailer'
end
