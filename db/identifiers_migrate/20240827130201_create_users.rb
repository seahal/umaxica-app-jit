# frozen_string_literal: true

# ToDo: Use table partitioning.

class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    # FIXME: need hashed partition.
    create_table :users, id: :binary do |t|
      t.string :webauthn_id
      t.timestamps
    end
  end
end
