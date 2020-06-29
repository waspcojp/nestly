class Notice < ApplicationRecord
  belongs_to :user
  belongs_to :history
  belongs_to :watch
end
