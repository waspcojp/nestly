class SorceryCore < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string		:user_name,        null: false
      t.string		:crypted_password
      t.string		:salt
      t.string		:default_display_name
      t.integer		:icon_image_id
      t.string		:uuid
      t.string		:timezone, default: 'UTC'

      t.datetime	:locked_at
      t.datetime	:expire_force_notice
      t.datetime	:expire_use_admin

      t.timestamps                null: false
    end

    add_index :users, :user_name, unique: true
  end
end
