class AddIndexToUsersAndStaffsOnWithdrawnAt < ActiveRecord::Migration[8.2]
  def change
    add_index :users, :withdrawn_at, where: "withdrawn_at IS NOT NULL" unless index_exists?(:users, :withdrawn_at, where: "withdrawn_at IS NOT NULL")
    add_index :staffs, :withdrawn_at, where: "withdrawn_at IS NOT NULL" unless index_exists?(:staffs, :withdrawn_at, where: "withdrawn_at IS NOT NULL")
  end
end
