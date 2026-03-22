# frozen_string_literal: true

class FixConsistencyAvatars < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      tables = %w(
        posts post_versions post_reviews
        avatars avatar_capabilities avatar_role_permissions avatar_roles avatar_permissions
        avatar_memberships avatar_membership_statuses avatar_monikers avatar_moniker_statuses
        avatar_ownership_periods avatar_ownership_statuses
        handles handle_statuses handle_assignments handle_assignment_statuses
      )
      existing = tables.select { |t| table_exists?(t) }
      execute("TRUNCATE TABLE #{existing.join(", ")} CASCADE") if existing.any?

      # --- Post ---
      change_column(:posts, :post_status_id, :bigint)
      add_foreign_key(:posts, :post_statuses, column: :post_status_id)

      if foreign_key_exists?(:post_versions, :posts)
        remove_foreign_key(:post_versions, :posts)
      end
      add_foreign_key(:post_versions, :posts, on_delete: :cascade)

      # --- PostReview ---
      change_column(:post_reviews, :post_review_status_id, :bigint)
      add_foreign_key(:post_reviews, :post_review_statuses, column: :post_review_status_id)

      # --- Avatar Membership ---
      change_column(:avatar_memberships, :role_id, :bigint)
      add_index(:avatar_memberships, :role_id) unless index_exists?(:avatar_memberships, :role_id)
      # Assuming link to avatar_roles
      add_foreign_key(:avatar_memberships, :avatar_roles, column: :role_id)

      change_column(:avatar_memberships, :avatar_membership_status_id, :bigint)
      add_foreign_key(:avatar_memberships, :avatar_membership_statuses)

      # --- Avatar Role Permission ---
      change_column(:avatar_role_permissions, :avatar_role_id, :bigint)
      change_column(:avatar_role_permissions, :avatar_permission_id, :bigint)
      add_foreign_key(:avatar_role_permissions, :avatar_roles)
      add_foreign_key(:avatar_role_permissions, :avatar_permissions)

      # --- Avatar ---
      change_column(:avatars, :capability_id, :bigint)
      add_foreign_key(:avatars, :avatar_capabilities, column: :capability_id)

      # --- Avatar Moniker ---
      change_column(:avatar_monikers, :avatar_moniker_status_id, :bigint)
      add_foreign_key(:avatar_monikers, :avatar_moniker_statuses)

      # --- Avatar Ownership ---
      change_column(:avatar_ownership_periods, :avatar_ownership_status_id, :bigint)
      add_foreign_key(:avatar_ownership_periods, :avatar_ownership_statuses)

      # --- Handle ---
      change_column(:handles, :handle_status_id, :bigint)
      add_foreign_key(:handles, :handle_statuses)

      # --- Handle Assignment ---
      change_column(:handle_assignments, :handle_assignment_status_id, :bigint)
      add_foreign_key(:handle_assignments, :handle_assignment_statuses)
    end
  end

  def down; raise ActiveRecord::IrreversibleMigration; end
end
