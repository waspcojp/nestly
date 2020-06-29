class CreateIcons < ActiveRecord::Migration[6.0]
  def change
    create_table :icons do |t|
      t.string   :name
      t.integer  :owner_id
      t.binary   :body, limit: 10.megabyte
      t.binary   :size_192, limit: 10.megabyte
      t.binary   :size_140, limit: 10.megabyte
      t.binary   :size_45,  limit: 10.megabyte
      t.string   :content_type
      t.integer  :x
      t.integer  :y
      t.integer  :width
      t.integer  :height

      t.timestamps
    end
  end
end
