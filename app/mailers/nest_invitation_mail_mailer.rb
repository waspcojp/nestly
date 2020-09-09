class NestInvitationMailMailer < ApplicationMailer
  def nest_invitation_mail
    @invite = params[:invite]
    mail(from: "#{t('mail_from.nest_invitation_mail')} <no-reply@#{Settings.mail[:domain_part]}>",
         to: @invite.to_mail,
         subject: t('nests.invitation_mail_subject')
         )
  end
end
