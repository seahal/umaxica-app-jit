# frozen_string_literal: true

# Add status column to user_tokens and staff_tokens for session state management.
# Status values:
#   - active: Normal session, fully functional
#   - restricted: Session created when limit exceeded, can only manage sessions
#   - revoked: Session has been invalidated (covered by revoked_at, but explicit status helps)
class AddStatusToTokens < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    # Add status column to user_tokens
    safety_assured do
      add_column(:user_tokens, :status, :string, default: "active", null: false, limit: 20)
    end

    # Add status column to staff_tokens
    safety_assured do
      add_column(:staff_tokens, :status, :string, default: "active", null: false, limit: 20)
    end

    # Add index for status queries (concurrently for safety)
    add_index(:user_tokens, :status, algorithm: :concurrently)
    add_index(:staff_tokens, :status, algorithm: :concurrently)
  end
end
