class CreateSpaces < ActiveRecord::Migration[6.0]
  def change
    create_table :spaces do |t|
      t.integer		:nest_id
      t.integer		:creater_id
      t.string		:class_name, default: "Board"
      t.integer		:publication_level, default: 9
      t.integer		:preparation_level, default: 2
      t.string		:title
      t.text		:description
      t.integer		:icon_image_id

      t.timestamps null: false
    end
    create_table :entries do |t|
      t.integer		:space_id
      t.integer		:author_id
      t.integer		:publication_level, default: 9
      t.integer		:comment_level, default: 2
      t.integer		:edit_level, default: 3
      t.string		:title
      t.text		:body
      t.string		:localpart
      t.string		:title_id
      t.integer		:body_type, default: 1
      t.integer		:comment_count, default: 0
      t.timestamp	:deleted_at
      t.integer		:deleted_by_id

      t.timestamps null: false
    end
    create_table :comments do |t|
      t.integer		:entry_id
      t.integer		:author_id
      t.text		:body
      t.integer		:number
      t.timestamp	:deleted_at
      t.integer		:deleted_by_id

      t.timestamps null: false
    end
    create_table :attach_files do |t|
      t.integer		:owner_id

      t.string		:name
      t.string		:title
      t.references	:file, polymorphic: true
      t.string		:content_type
      t.binary		:body, limit: 10.megabyte
      t.binary		:_thumb, limit: 10.megabyte

      t.timestamps null: false
    end
  end
end
