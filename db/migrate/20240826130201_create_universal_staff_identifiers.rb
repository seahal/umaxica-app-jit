# ToDo: Use table partitioning.
class CreateUniversalStaffIdentifiers < ActiveRecord::Migration[8.1]
  def change
    create_table :universal_staff_identifiers, id: :binary do |t|
      t.timestamps
    end
  end
end
