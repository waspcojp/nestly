class UsersController < ApplicationController
  #layout "admin"

  skip_before_action :require_login, only: [:index, :new, :create, :update, :edit, :token_login]

  def new
    if ( !Settings.service[:invite_only] )
      @user = User.new
    else
      redirect_to_404
    end
  end
  def create
    if ( !Settings.service[:invite_only] )
      user = params.require(:user).permit(:user_name, :password, :current_password, :password_confirmation, :default_display_name, :timezone)
      @user = User.new(user)
      if @user.save
        if ( params[:token] )
          user = login(params[:user][:user_name], params[:user][:password], false)
          if ( @invite = Invite.where(invitation_token: params[:token]).first )
            @invite.nest.join(current_user, @invite.inviter)
            if ( !current_user.mail_owner?(@invite.to_mail) )
              current_user.append_mail(@invite.to_mail)
            end
            @invite.destroy

            redirect_to nest_path(@invite.nest), notice: "Signed up!"
          else
            redirect_to login_path, notice: "Signed up!"
          end
        else
          redirect_to login_path, notice: "Signed up!"
        end
      else
        render :new
      end
    else
      redirect_to_404
    end
  end

  def show
    @user = User.find(params[:id])
    render layout: "login"
  end

  def edit
    @user = current_user
  end
  def update
    inputs = params.require(:user).permit(:user_name, :password, :current_password, :password_confirmation, :default_display_name, :timezone)
    @user = current_user
    if (( !@user.crypted_password.present? ) ||
        ( @user.valid_password?(inputs[:current_password]) ))
      @user.password  = inputs[:password]
      @user.password_confirmation = inputs[:password_confirmation]
      if ( @user.valid? )
        @user.default_display_name = inputs[:default_display_name]
        @user.save
        flash[:success] = t('users.password_changed')
        redirect_to edit_user_path(@user)
      else
        flash[:warning] = t('users.password_not_match')
        render :edit, layout: "application"
      end
    else
      flash[:danger] = t('users.password_error')
      render :edit, layout: "application"
    end
  end

  def edit_profile
    @user = current_user
  end
  def update_profile
    p params
    account_update_params = params.require(:user).permit(:icon_image, :default_display_name, :timezone)
    @user = current_user
    @icon = _create_icon(@user,
                         account_update_params[:icon_image],
                         params[:icon_x],
                         params[:icon_y],
                         params[:icon_width],
                         params[:icon_height]
                         )
    if @icon
      @user.icon_image_id = @icon.id
    end
    @user.default_display_name = account_update_params[:default_display_name]
    @user.timezone = account_update_params[:timezone]
    if ( @user.save )
      flash[:success] = t('users.update profile success')
    else
      flash[:danger] = t('users.update profile fail')
    end
    redirect_to edit_profile_path
  end

  def edit_mail
    @user = current_user
    @user_mail_address = UserMailAddress.new
  end
  def append_mail
    user_mail_address = params.require(:user_mail_address).permit(:mail_address)
    @user_mail_address = UserMailAddress.new(user_mail_address)
    @user_mail_address.user = current_user
    if ( @user_mail_address.save )
      flash[:success] = t('users.success_add_mail')
    else
      flash[:danger] = t('users.fail_add_mail')
    end
    redirect_to edit_mail_path
  end
  def delete_mail
    @user_mail_address = UserMailAddress.find(params[:id])
    @user_mail_address.destroy

    redirect_to edit_mail_path
  end
  def send_mail
    @user_mail_address = UserMailAddress.find(params[:id])
    @user_mail_address.authenticate_token = SecureRandom.uuid
    @user_mail_address.mail_sent_at = Time.now
    @user_mail_address.authorized_at = nil
    if ( @user_mail_address.save )
      #AuthenticationMailMailer.with(user_mail_address: @user_mail_address).authentication_mail.deliver_later
      AuthenticationMailMailer.with(user_mail_address: @user_mail_address).authentication_mail.deliver_now
      flash[:success] = t('users.authenticate_mail_sent')
    else
      flash[:danger] = t('users.authenticate_mail_fail')
    end
    redirect_to edit_mail_path
  end
  def auth_mail
    @user_mail_address = UserMailAddress.where(authenticate_token: params[:id]).first
    if ( @user_mail_address )
      @user_mail_address.authenticate
      flash[:success] = t('users.mail_authentication_success')
    else
      flash[:danger] = t('users.mail_authentication_fail')
    end
    redirect_to edit_mail_path
  end
  def notice_mail
    @user_mail_address = UserMailAddress.find(params[:id])
    @user_mail_address.notice = params[:on_off]
    @user_mail_address.save
  end
  def token_login
    @invite = Invite.where(invitation_token: params[:id]).first
    if ( @invite )
      if ( @user_mail_address = UserMailAddress.where(mail_address: @invite.to_mail).first )
        @user = @user_mail_address.user
        @invite.destroy
        auto_login(@user)
        redirect_to edit_user_path(@user)
      else
        redirect_to_404
      end
    else
      redirect_to_404
    end
  end


private
  def _upload
    if ( icon = params[:user][:profile_image] )
      @attach = Attach.new
      @attach.body = icon.read
      @attach.name = icon.original_filename
      @attach.content_type = icon.content_type
      @attach.owner_id = current_user.id
      @attach.save
      current_user.profile_image_id = @attach.id
    end
  end
  def set_layout
    case params[:action]
    when "edit",
         "edit_profile",
         "edit_session",
         "update"
      "setting"
    else
      "not_signed_in"
    end
  end
end
