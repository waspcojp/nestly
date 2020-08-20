class ApplicationMailer < ActionMailer::Base
  default 'Content-Transfer-Encoding' => '7bit'
  default from: Settings.mail.from_address
  layout 'mailer'
end
