class SessionsController < ApplicationController
  skip_before_action :require_login, except: [:destroy], raise: false

  def new
    if ( !current_user )
      @user = User.new
    else
      redirect_to "/home"
    end
  end
  def create
    user = login(params[:user_name], params[:password], params[:remember])
    if user
      print "logged in\n"
      redirect_back_or_to params[:return] ? params[:return] : "/home"
    else
      flash[:danger] = I18n.t("users.user_or_password_was_invalid")
      render :new
    end
  end

  def destroy
    logout
    flash[:success] = I18n.t("users.logged_out")
    redirect_to top_path
  end

end
