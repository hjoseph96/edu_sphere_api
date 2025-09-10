class CreatePageViews < ActiveRecord::Migration[8.0]
  def change
    create_table :page_views, id: :uuid do |t|
      t.string :pageviewable_type
      t.uuid :pageviewable_id
      t.uuid :user_id
      t.string :controller_name
      t.string :action_name
      t.string :view_name
      t.string :request_hash
      t.string :session_hash
      t.string :ip_address
      t.text :params
      t.string :referrer

      t.timestamps
    end

    add_index :page_views, [:pageviewable_type, :pageviewable_id]
    add_index :page_views, :user_id
    add_index :page_views, [:controller_name, :action_name]
    add_index :page_views, :created_at
    add_index :page_views, :request_hash
  end
end
