# frozen_string_literal: true

class DropDeletableAtFromStaffs < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    remove_index(:staffs, :deletable_at, algorithm: :concurrently) if index_exists?(:staffs, :deletable_at)
    safety_assured { remove_column(:staffs, :deletable_at) } if column_exists?(:staffs, :deletable_at)
  end

  def down
    return if column_exists?(:staffs, :deletable_at)

    safety_assured do
      add_column(:staffs, :deletable_at, :datetime, null: false, default: -> { "'infinity'" })
    end
    add_index(:staffs, :deletable_at, algorithm: :concurrently)
  end
end
