class CreateNotices < ActiveRecord::Migration[6.0]
  def change
    create_table :watches do |t|
      t.integer		:user_id
      t.boolean		:active, default: false
      t.references	:target, polymorphic: true
      t.string		:accept_token

      t.timestamps null: false
    end
    create_table :histories do |t|
      t.references	:target, polymorphic: true
      t.string		:operation
      t.text		:body

      t.datetime	:created_at
    end
    create_table :notices do |t|
      t.integer		:user_id
      t.integer		:history_id
      t.integer		:watch_id
      t.datetime	:read_at

      t.datetime	:created_at
    end
    add_column :user_mail_addresses, :notice, :boolean, default: false
  end
end
