class NoticesController < ApplicationController
  skip_before_action :require_login

  def watch
    @watch = Watch.where(accept_token: params[:id]).first
    if ( @watch )
      if ( !params[:watch] )
        @watch.active = ! @watch.active
      elsif ( params[:watch] =~ /on/i )
        @watch.active = true
      elsif ( params[:watch] =~ /off/i )
        @watch.active = false
      end
      @watch.accept_token = ""
      @watch.save
    else
      redirect_to_404
    end
  end
end
