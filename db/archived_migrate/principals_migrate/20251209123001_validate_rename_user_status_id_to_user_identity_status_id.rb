# frozen_string_literal: true

class ValidateRenameUserStatusIdToUserIdentityStatusId < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key(:users, :user_identity_statuses)
  end
end
