module LoggingHistory
private
  def log_create
    History.log(:create, self)
  end
  def log_update
    History.log(:update, self)
  end
  def log_destroy
    History.log(:destroy, self)
  end
end
