class AuthenticationMailMailer < ApplicationMailer
  def authentication_mail
    @user_mail_address = params[:user_mail_address]
    mail(from: "#{t('mail_from.authentication_mail}<no-reply@#{Settings.mail[:domain_part]}>",
         to: @user_mail_address.mail_address,
         subject: t('users.mail_authentication_subject')
         )
  end
end
