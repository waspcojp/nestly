class UsersController < ApplicationController
  #layout "admin"

  skip_before_action :require_login, only: [:index, :new, :create, :update, :edit]

  def new
    if ( !Settings.service[:invite_only] )
      @user = User.new
    else
      redirect_to_404
    end
  end
  def create
    if ( !Settings.service[:invite_only] )
      @user = User.new(strong_params)
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
    inputs = strong_params
    @user = current_user
    if (( !@user.crypted_password.present? ) ||
        ( @user.valid_password?(inputs[:current_password]) ))
      @user.password  = inputs[:password]
      @user.password_confirmation = inputs[:password_confirmation]
      if ( @user.valid? )
        @user.default_display_name = inputs[:default_display_name]
        @user.save
        flash[:success] = 'password changed'
        redirect_to edit_user_path(@user)
      else
        flash[:warning] = 'password not match'
        render :edit, layout: "application"
      end
    else
      flash[:danger] = 'password error'
      render :edit, layout: "application"
    end
  end

  def edit_profile
    @user = current_user
  end
  def update_profile
    p params
    account_update_params = params.require(:user).permit(:icon_image, :default_display_name)
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
    if ( @user.save )
      flash[:success] = 'update profile success'
    else
      flash[:danger] = 'update profile fail'
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
      flash[:success] = 'append mail address success. please authenticate this mail address'
    else
      flash[:danger] = 'append mail address fail'
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
      AuthenticationMailMailer.with(user_mail_address: @user_mail_address).authentication_mail.deliver_later
      #AuthenticationMailMailer.with(user_mail_address: @user_mail_address).authentication_mail.deliver_now
      flash[:success] = 'authenticate mail sent'
    else
      flash[:danger] = 'authenticate mail fail'
    end
    redirect_to edit_mail_path
  end
  def auth_mail
    @user_mail_address = UserMailAddress.where(authenticate_token: params[:id]).first
    if ( @user_mail_address )
      @user_mail_address.authorized_at = Time.now
      @user_mail_address.save
      flash[:success] = 'mail address authentication OK'
    else
      flash[:danger] = 'mail address authentication fail'
    end
    redirect_to edit_mail_path
  end
  def notice_mail
    @user_mail_address = UserMailAddress.find(params[:id])
    @user_mail_address.notice = params[:on_off]
    @user_mail_address.save
  end


private
  def strong_params
    params.require(:user).permit(:user_name, :password, :current_password, :password_confirmation, :default_display_name)
  end

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
