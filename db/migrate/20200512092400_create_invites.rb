class CreateInvites < ActiveRecord::Migration[6.0]
  def change
    create_table	:invites do |t|
      t.string		:invitation_token
      t.integer		:inviter_id
      t.string		:to_mail
      t.integer		:nest_id

      t.datetime	:expired_at
      t.datetime	:mail_sent_at
      t.datetime	:created_at
    end
    add_index	:invites,	:invitation_token, unique: true
  end
end
