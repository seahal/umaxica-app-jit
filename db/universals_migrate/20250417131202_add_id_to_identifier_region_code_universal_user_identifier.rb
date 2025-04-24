class AddIdToIdentifierRegionCodeUniversalUserIdentifier < ActiveRecord::Migration[8.0]
  def change
    add_column :identifier_region_codes_universal_user_identifiers, :id, :bytea, null: false
    add_index :identifier_region_codes_universal_user_identifiers, :id, unique: true
  end
end
