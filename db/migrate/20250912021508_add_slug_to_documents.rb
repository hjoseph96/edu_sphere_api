class AddSlugToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :slug, :string
    add_index :documents, :slug, unique: true
  end
end
