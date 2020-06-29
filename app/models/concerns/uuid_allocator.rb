module UUIDAllocator
  def self.included(base)
    base.before_create :create_uuid
  end
  private
  def create_uuid
    if self.uuid.nil?
      self.uuid = SecureRandom.uuid
    end
  end
end
