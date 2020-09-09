class SpaceMember < ApplicationRecord
  belongs_to :target, polymorphic: :true
  belongs_to :space

  def display_name
    self.target.member_name(self.space.nest)
  end
end
