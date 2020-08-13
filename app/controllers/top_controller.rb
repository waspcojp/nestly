class TopController < ApplicationController
  skip_before_action :require_login

  def method_missing
  end
end
