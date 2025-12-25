class CreateAreaIpOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :area_ip_occurrences, id: :uuid do |t|
      t.references :area_occurrence, null: false, foreign_key: true, type: :uuid
      t.references :ip_occurrence, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
