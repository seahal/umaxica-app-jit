class CreateUserTimeBasedOneTimePasswords < ActiveRecord::Migration[8.2]
  def change
    create_table :user_time_based_one_time_passwords, id: false do |t|
      t.binary :time_based_one_time_password_id, null: false
      t.binary :user_id, null: false
    end
  end
end
