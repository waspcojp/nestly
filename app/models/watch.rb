class Watch < ApplicationRecord
  belongs_to :user, class_name: "User"
  belongs_to :target, polymorphic: :true
  before_save :create_token

private
  def create_token
    if self.accept_token.nil?
      self.accept_token = SecureRandom.uuid
    end
  end
end
