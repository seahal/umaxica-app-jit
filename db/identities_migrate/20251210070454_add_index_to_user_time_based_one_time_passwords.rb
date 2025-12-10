class AddIndexToUserTimeBasedOneTimePasswords < ActiveRecord::Migration[8.2]
  def change
    add_index :user_time_based_one_time_passwords, :user_id, if_not_exists: true
  end
end
