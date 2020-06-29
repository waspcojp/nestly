class AbuseInvite < ApplicationRecord
  belongs_to :inviter, class_name: "User"
  belongs_to :nest
end
