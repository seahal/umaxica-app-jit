# ToDo: Use table partitioning.

class CreateUniversalUserIdentifiers < ActiveRecord::Migration[8.1]
  def change
    create_table :universal_user_identifiers, id: :binary do |t|
      t.timestamps
    end
  end
end
