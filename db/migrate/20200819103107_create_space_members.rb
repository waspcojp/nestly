class CreateSpaceMembers < ActiveRecord::Migration[6.0]
  def change
    drop_table :space_admins
    create_table :space_members do |t|
      t.integer		:space_id
      t.integer		:user_id
      t.boolean		:admin, default: false

      t.timestamps null: false
    end
  end
end
