class HomeController < ApplicationController
  skip_before_action :require_login, only: [:index]

  def index
    if ( current_user )
      render
    else
      redirect_to top_path
    end
  end

  def watches
  end
  def update_watch
    if ( params[:id].to_i == 0 )
      @watch = Watch.new(target_type: params[:target_type],
                         target_id: params[:target_id],
                         user: current_user)
    else
      @watch = Watch.find(params[:id])
    end
    @watch.active = params[:on_off]
    @watch.save
  end
end
