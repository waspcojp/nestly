class SorceryCore < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string	:user_name,        null: false
      t.string	:crypted_password
      t.string	:salt
      t.string	:default_display_name
      t.integer	:icon_image_id

      t.timestamps                null: false
    end

    add_index :users, :user_name, unique: true
  end
end
