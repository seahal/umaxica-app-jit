# frozen_string_literal: true

class AddPrimaryKeyToUserIdentityOneTimePasswords < ActiveRecord::Migration[8.2]
  def up
    # Add UUID primary key column with uuidv7() default
    execute <<-SQL.squish
      ALTER TABLE user_identity_one_time_passwords
      ADD COLUMN id uuid DEFAULT uuidv7() PRIMARY KEY;
    SQL
  end

  def down
    # Remove the primary key column on rollback
    remove_column :user_identity_one_time_passwords, :id
  end
end
