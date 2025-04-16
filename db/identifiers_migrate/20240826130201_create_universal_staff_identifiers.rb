# ToDo: Use table partitioning.
class CreateUniversalStaffIdentifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :universal_staff_identifiers, id: :uuid do |t|
      t.timestamps
    end
  end
end
