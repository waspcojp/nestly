class NestInvitationMailMailer < ApplicationMailer
  def nest_invitation_mail
    @invite = params[:invite]
    p mail(to: @invite.to_mail, subject: 'nest invitation')
  end
end
