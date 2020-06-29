class HomeController < ApplicationController
  def index
  end
  def watches
  end
  def update_watch
    p params
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
