# frozen_string_literal: true

class AddLockVersionToUsersAndStaffs < ActiveRecord::Migration[7.1]
  def up
    # users
    unless column_exists?(:users, :lock_version)
      add_column :users, :lock_version, :integer
      execute "UPDATE users SET lock_version = 0 WHERE lock_version IS NULL"
      change_column_default :users, :lock_version, 0
      change_column_null :users, :lock_version, false
    end

    # staffs
    unless column_exists?(:staffs, :lock_version)
      add_column :staffs, :lock_version, :integer
      execute "UPDATE staffs SET lock_version = 0 WHERE lock_version IS NULL"
      change_column_default :staffs, :lock_version, 0
      change_column_null :staffs, :lock_version, false
    end
  end

  def down
    remove_column :users,  :lock_version if column_exists?(:users,  :lock_version)
    remove_column :staffs, :lock_version if column_exists?(:staffs, :lock_version)
  end
end
