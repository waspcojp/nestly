class NestMember < ApplicationRecord
  belongs_to :user
  belongs_to :nest
  belongs_to :inviter, class_name: "User", optional: true
end
