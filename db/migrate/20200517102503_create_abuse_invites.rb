class CreateAbuseInvites < ActiveRecord::Migration[6.0]
  def change
    create_table :abuse_invites do |t|
      t.integer		:inviter_id
      t.string		:mail_address
      t.datetime	:mail_sent_at
      t.integer		:nest_id
      t.text		:report

      t.datetime	:created_at
    end
    add_index	:abuse_invites, [:inviter_id, :mail_address]
  end
end
