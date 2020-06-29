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
    #p "params", params
    user = login(params[:user_name], params[:password], params[:remember])
    if user
      print "logged in\n"
      redirect_back_or_to params[:return] ? params[:return] : "/home"
    else
      flash.now[:alert] = "User name or password was invalid"
      render :new
    end
  end

  def destroy
    logout
    redirect_to login_path, notice: "Logged out!"
  end

end
