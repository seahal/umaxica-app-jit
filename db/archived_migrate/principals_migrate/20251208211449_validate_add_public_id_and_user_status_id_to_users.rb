# frozen_string_literal: true

class ValidateAddPublicIdAndUserStatusIdToUsers < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :users, :user_identity_statuses
  end
end
