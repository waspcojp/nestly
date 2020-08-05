class CreateSpaces < ActiveRecord::Migration[6.0]
  def change
    create_table :spaces do |t|
      t.integer		:nest_id
      t.integer		:creater_id
      t.string		:class_name, default: "Board"
      t.integer		:publication_level, default: 9
      t.integer		:notice_level, default: 0
      t.integer		:preparation_level, default: 4
      t.integer		:entry_publication_level, default: 3
      t.integer		:entry_comment_level, default: 3
      t.integer		:entry_edit_level, default: 4
      t.string		:title
      t.string		:title_id
      t.text		:description
      t.string		:localpart
      t.integer		:icon_image_id
      t.datetime	:released_at

      t.timestamps null: false
    end
    create_table :space_admins do |t|
      t.integer		:space_id
      t.integer		:user_id

      t.timestamps null: false
    end
    create_table :entries do |t|
      t.integer		:space_id
      t.integer		:author_id
      t.integer		:notice_level, default: 0
      t.string		:title
      t.text		:body
      t.string		:localpart
      t.integer		:body_type, default: 1
      t.integer		:comment_count, default: 0
      t.datetime	:released_at

      t.timestamps null: false
    end
    create_table :comments do |t|
      t.integer		:entry_id
      t.integer		:author_id
      t.integer		:parent_id
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
