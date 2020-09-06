class ChangeSpaceMembersUser < ActiveRecord::Migration[6.0]
  def change
    change_table	:space_members do |t|
      t.remove		:user_id
      t.references	:target, polymorphic: true
    end
  end
end
