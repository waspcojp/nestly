class CreateDownLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :down_logs do |t|
      t.text     :request_uri
      t.text     :error_message
      t.text     :session
      t.binary   :raw_post
      t.text     :referer
      t.text	 :trace
      t.string   :remote_host
      t.datetime :checked_at, :default => nil
      t.datetime :finished_at, :default => nil

      t.timestamps
    end
  end
end
