# frozen_string_literal: true

class AddRefreshTokenDigestToTokens < ActiveRecord::Migration[8.2]
  class UserToken < ActiveRecord::Base
    self.table_name = "user_tokens"
  end

  class StaffToken < ActiveRecord::Base
    self.table_name = "staff_tokens"
  end

  def up
    add_column :user_tokens, :refresh_token_digest, :string
    add_column :staff_tokens, :refresh_token_digest, :string

    require "bcrypt"
    require "securerandom"

    UserToken.reset_column_information
    StaffToken.reset_column_information

    UserToken.where(refresh_token_digest: nil).find_each do |token|
      token.update!(refresh_token_digest: BCrypt::Password.create(SecureRandom.hex(32)))
    end

    StaffToken.where(refresh_token_digest: nil).find_each do |token|
      token.update!(refresh_token_digest: BCrypt::Password.create(SecureRandom.hex(32)))
    end

    change_column_null :user_tokens, :refresh_token_digest, false
    change_column_null :staff_tokens, :refresh_token_digest, false

    add_index :user_tokens, :refresh_token_digest, unique: true
    add_index :staff_tokens, :refresh_token_digest, unique: true
  end

  def down
    remove_index :user_tokens, :refresh_token_digest
    remove_index :staff_tokens, :refresh_token_digest
    remove_column :user_tokens, :refresh_token_digest
    remove_column :staff_tokens, :refresh_token_digest
  end
end
