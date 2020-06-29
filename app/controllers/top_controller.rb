class TopController < ApplicationController

  before_action :redirect_new_session, if: :from_smartphone? 

  def index
    render layout: 'top'
  end
  def about
    render layout: 'application'
  end
  def guidance
    render layout: 'application'
  end
  def comming_soon
    render layout: 'application'
  end
  def term
    render layout: 'application'
  end
  def privacy
    render layout: 'application'
  end
  private
  def from_smartphone?
    request.from_smartphone? && action_name == "index"
  end
  def redirect_new_session
    redirect_to  new_session_path(:user)
  end
  def sign_in_params
    params.fetch("users", {})
  end

end
