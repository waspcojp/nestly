class CreateNestTops < ActiveRecord::Migration[6.0]
  def change
    create_table :nest_tops do |t|
      t.integer		:max_update_entries, default: 15
      t.integer		:max_spaces, default: 15

      t.timestamps null: false
    end
    add_column :nests, :design_id, :integer
  end
end
