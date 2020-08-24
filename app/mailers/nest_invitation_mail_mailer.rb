class NestInvitationMailMailer < ApplicationMailer
  def nest_invitation_mail
    @invite = params[:invite]
    mail(to: @invite.to_mail,
         subject: t('nests.invitation_mail_subject')
         )
  end
end
