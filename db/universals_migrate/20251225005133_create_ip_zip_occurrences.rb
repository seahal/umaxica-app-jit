class CreateIpZipOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :ip_zip_occurrences, id: :uuid do |t|
      t.references :ip_occurrence, null: false, foreign_key: true, type: :uuid
      t.references :zip_occurrence, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
