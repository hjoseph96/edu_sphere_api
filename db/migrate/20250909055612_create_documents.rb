class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents, id: :uuid do |t|
      t.string :title
      t.text :markdown
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
