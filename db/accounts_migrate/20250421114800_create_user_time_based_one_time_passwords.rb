class CreateUserTimeBasedOneTimePasswords < ActiveRecord::Migration[8.0]
  def change
    create_table :user_time_based_one_time_passwords, id: false do |t|
      t.binary :user_id, null: false # , foreign_key: true
      t.binary :time_based_one_time_password_id, null: false # , foreign_key: true
    end
  end
end
