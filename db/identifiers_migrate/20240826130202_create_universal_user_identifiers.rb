# ToDo: Use table partitioning.

class CreateUniversalUserIdentifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :universal_user_identifiers, id: :bytea do |t|
      t.timestamps
    end
  end
end
