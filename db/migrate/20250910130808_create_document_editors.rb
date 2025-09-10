class CreateDocumentEditors < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pg_trgm'
    
    create_table :document_editors, id: :uuid do |t|
      t.references :document, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :role, null: false, default: 0

      t.timestamps
    end
  end
end
