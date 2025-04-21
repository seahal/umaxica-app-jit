class CreateTimeBasedOneTimePasswords < ActiveRecord::Migration[8.0]
  def change
    create_table :time_based_one_time_passwords, id: :bytea do |t|
      t.jsonb :private_key, null: false, limit: 1024
      t.timestamps
    end
  end
end
