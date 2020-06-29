class CreateNests < ActiveRecord::Migration[6.0]
  def change
    create_table	:user_mail_addresses do |t|
      t.integer		:user_id
      t.string		:mail_address
      t.string		:authenticate_token
      t.datetime	:mail_sent_at
      t.datetime	:authorized_at
    end
    create_table	:nests do |t|
      t.integer		:owner_id
      t.string		:title
      t.text		:description
      t.integer		:icon_image_id
      t.integer		:publication_level, default: 9
      t.integer		:preparation_level, default: 2
      t.integer		:join_method, default: 99

      t.timestamps null: false
    end
    create_table	:nest_members do |t|
      t.integer		:nest_id
      t.integer		:user_id
      t.string		:display_name
      t.integer		:inviter_id
      t.boolean		:board, default: false

      t.timestamps null: false
    end
    add_index	:user_mail_addresses, :mail_address, unique: true
    add_index	:nest_members,	:user_id
    add_index	:nest_members,	:nest_id
    add_index	:nest_members,	[:user_id, :nest_id], unique: true
  end
end
