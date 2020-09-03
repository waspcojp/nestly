class DeleteEntriesNoticeLevel < ActiveRecord::Migration[6.0]
  def change
    remove_column :entries, :notice_level
  end
end
