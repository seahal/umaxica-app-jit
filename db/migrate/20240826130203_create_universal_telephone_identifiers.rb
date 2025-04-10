# ToDo: Use table partitioning.

class CreateUniversalTelephoneIdentifiers < ActiveRecord::Migration[7.2]
  def change
    create_table :universal_telephone_identifiers, id: :binary do |t|
      t.timestamps
    end
  end
end
