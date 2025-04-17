class CreateJoinTableIdentifierRegionCodeUniversalStaffIdentifier < ActiveRecord::Migration[8.0]
  def change
    create_join_table :identifier_region_codes, :universal_staff_identifiers do |t|
      t.index [ :identifier_region_code_id, :universal_staff_identifier_id ]
      t.index [ :universal_staff_identifier_id, :identifier_region_code_id ]
    end
  end
end
