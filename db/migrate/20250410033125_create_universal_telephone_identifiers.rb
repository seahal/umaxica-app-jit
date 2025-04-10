class CreateUniversalTelephoneIdentifiers < ActiveRecord::Migration[8.1]
  def change
    create_table :universal_telephone_identifiers do |t|
      t.timestamps
    end
  end
end
