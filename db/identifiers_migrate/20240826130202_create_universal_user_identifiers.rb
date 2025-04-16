# ToDo: Use table partitioning.

class CreateUniversalUserIdentifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :universal_user_identifiers, id: :uuid do |t|
      t.timestamps
    end
  end
end
