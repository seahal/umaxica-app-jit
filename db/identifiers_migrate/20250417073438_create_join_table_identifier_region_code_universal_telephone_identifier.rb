class CreateJoinTableIdentifierRegionCodeUniversalTelephoneIdentifier < ActiveRecord::Migration[8.1]
  def change
    create_join_table :identifier_region_codes, :universal_telephone_identifiers do |t|
      t.index [:identifier_region_code_id, :universal_telephone_identifier_id]
      t.index [:universal_telephone_identifier_id, :identifier_region_code_id]
    end
  end
end
