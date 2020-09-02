class InvitesController < ApplicationController
  skip_before_action :require_login, only: [:show, :join, :leave, :abuse, :report_abuse]

  def index
  end
  
  def show
    @invite = Invite.where(invitation_token: params[:id]).first
    if ( @invite )
      if ( !current_user )
        render
      else
        if (( current_user.mail_owner?(@invite.to_mail) ) ||
            ( !User.mail_used?(@invite.to_mail) ))
          render
        else
          redirect_to_404
        end
      end
    else
      redirect_to_404
    end
  end
  def expire
    @invite = Invite.where(invitation_token: params[:id]).first
  end
  def join
    @invite = Invite.where(invitation_token: params[:id]).first
    if ( @invite )
      if ( @invite.expired_at < Time.now )
        redirect_to invite_expire_path(@invite.invitation_token)
      elsif ( !current_user )
        if ( !Settings.service[:invite_only] )
          redirect_to new_user_path(token: @invite.invitation_token)
        else
          @user = @invite.create_user
          @invite.destroy
          auto_login(@user)

          redirect_to edit_user_path(@user)
        end
      else
        redirect_to nest_join_path(@invite.nest, token: @invite.invitation_token)
      end
    end
  end
  def leave
    @invite = Invite.where(invitation_token: params[:id]).first
    @invite.destroy
    render :thanks
  end
  def abuse
    @invite = Invite.where(invitation_token: params[:id]).first
  end
  def report_abuse
    @invite = Invite.find(params[:id])
    AbuseInvite.create(inviter: @invite.inviter,
                       nest: @invite.nest,
                       mail_address: @invite.to_mail,
                       mail_sent_at: @invite.mail_sent_at,
                       report: params[:report])
    @invite.destroy
    render :thanks
  end
  def append
    @invite = Invite.where(invitation_token: params[:id]).first
    if ( !current_user )
      @invite.destroy
      redirect_to_404	# no case
    else
      if ( !current_user.mail_owner?(@invite.to_mail) )
        if ( current_user.append_mail(@invite.to_mail) )
          flash[:success] = 'append mail address success'
        else
          flash[:danger] = 'append mail address fail'
        end
      end
      @invite.destroy
      redirect_to nest_path(@invite.nest)
    end
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
    @invite = Invite.find(params[:id])
    @invite.destroy

    recirect_to invite_url
  end
end
