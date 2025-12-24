class AddPrimaryKeyToUserIdentityOneTimePasswords < ActiveRecord::Migration[8.2]
  def up
    execute <<-SQL
      ALTER TABLE user_identity_one_time_passwords
      ADD COLUMN id uuid DEFAULT uuidv7() PRIMARY KEY;
    SQL
  end

  def down
    remove_column :user_identity_one_time_passwords, :id
  end
end
