class AuthenticationMailMailer < ApplicationMailer
  def authentication_mail
    @user_mail_address = params[:user_mail_address]
    mail(to: @user_mail_address.mail_address,
         subject: t('users.mail_authentication_subject')
         )
  end
end
