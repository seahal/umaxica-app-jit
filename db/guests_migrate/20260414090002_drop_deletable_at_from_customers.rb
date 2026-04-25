# frozen_string_literal: true

class DropDeletableAtFromCustomers < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    remove_index(:customers, :deletable_at, algorithm: :concurrently) if index_exists?(:customers, :deletable_at)
    safety_assured { remove_column(:customers, :deletable_at) } if column_exists?(:customers, :deletable_at)
  end

  def down
    return if column_exists?(:customers, :deletable_at)

    safety_assured do
      add_column(:customers, :deletable_at, :datetime, null: false, default: -> { "'infinity'" })
    end
    add_index(:customers, :deletable_at, algorithm: :concurrently)
  end
end
