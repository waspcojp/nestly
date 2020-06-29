class UserMailAddress < ApplicationRecord
  belongs_to :user
  validates :mail_address, uniqueness: true
end
