# frozen_string_literal: true

class AddStepUpToTokens < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column(:user_tokens, :last_step_up_at, :datetime) unless column_exists?(:user_tokens, :last_step_up_at)
    add_column(:user_tokens, :last_step_up_scope, :string) unless column_exists?(:user_tokens, :last_step_up_scope)
    add_index(:user_tokens, %i(user_id last_step_up_at), if_not_exists: true, algorithm: :concurrently)

    add_column(:staff_tokens, :last_step_up_at, :datetime) unless column_exists?(:staff_tokens, :last_step_up_at)
    add_column(:staff_tokens, :last_step_up_scope, :string) unless column_exists?(:staff_tokens, :last_step_up_scope)
    add_index(:staff_tokens, %i(staff_id last_step_up_at), if_not_exists: true, algorithm: :concurrently)
  end
end
