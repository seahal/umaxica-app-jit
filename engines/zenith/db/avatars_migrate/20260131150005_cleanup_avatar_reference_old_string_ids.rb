# typed: false
# frozen_string_literal: true

class CleanupAvatarReferenceOldStringIds < ActiveRecord::Migration[8.2]
  TABLES = %w(
    avatar_membership_statuses
    avatar_moniker_statuses
    avatar_ownership_statuses
    handle_assignment_statuses
    handle_statuses
    post_statuses
    avatar_capabilities
    avatar_permissions
    avatar_roles
    post_review_statuses
  ).freeze

  def up
    TABLES.each do |table|
      safety_assured do
        remove_column(table, :id_old_string, :string) if column_exists?(table, :id_old_string)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
