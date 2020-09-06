class SpaceMember < ApplicationRecord
  belongs_to :target, polymorphic: :true
  belongs_to :space
end
