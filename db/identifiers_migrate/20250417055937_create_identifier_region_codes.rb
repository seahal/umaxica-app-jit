class CreateIdentifierRegionCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :identifier_region_codes, id: :string do |t|
      t.timestamps
    end
  end
end
