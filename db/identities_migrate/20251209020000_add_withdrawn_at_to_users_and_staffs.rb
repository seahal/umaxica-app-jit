class AddWithdrawnAtToUsersAndStaffs < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :withdrawn_at, :datetime unless column_exists?(:users, :withdrawn_at)
    add_column :staffs, :withdrawn_at, :datetime unless column_exists?(:staffs, :withdrawn_at)
  end
end
