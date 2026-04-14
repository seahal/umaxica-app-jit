# frozen_string_literal: true

class DropDeletableAtFromUsers < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    remove_index(:users, :deletable_at, algorithm: :concurrently) if index_exists?(:users, :deletable_at)
    safety_assured { remove_column(:users, :deletable_at) } if column_exists?(:users, :deletable_at)
  end

  def down
    return if column_exists?(:users, :deletable_at)

    safety_assured do
      add_column(:users, :deletable_at, :datetime, null: false, default: -> { "'infinity'" })
    end
    add_index(:users, :deletable_at, algorithm: :concurrently)
  end
end
