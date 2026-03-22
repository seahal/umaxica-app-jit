# frozen_string_literal: true

# Migration to remove redundant indexes from token tables
# This resolves RedundantIndexChecker warnings
class RemoveRedundantTokenIndexes < ActiveRecord::Migration[7.1]
  def change
    # UserToken: index_user_tokens_on_user_id is redundant
    remove_index(:user_tokens, column: :user_id, name: "index_user_tokens_on_user_id", if_exists: true)

    # StaffToken: index_staff_tokens_on_staff_id is redundant
    remove_index(:staff_tokens, column: :staff_id, name: "index_staff_tokens_on_staff_id", if_exists: true)
  end
end
