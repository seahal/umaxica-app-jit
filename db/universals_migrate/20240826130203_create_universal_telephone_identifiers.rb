# ToDo: Use table partitioning.
# INFO: Use lowercase for telephone number.

class CreateUniversalTelephoneIdentifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :universal_telephone_identifiers, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.timestamps
    end
  end
end
