# frozen_string_literal: true

# Migration to remove redundant indexes from avatar tables
# This resolves RedundantIndexChecker warnings
class RemoveRedundantAvatarIndexes < ActiveRecord::Migration[7.1]
  def change
    # ClientAvatarVisibility
    remove_index :client_avatar_visibilities,
                 name: "index_client_avatar_visibilities_on_client_id",
                 if_exists: true

    # ClientAvatarSuspension
    remove_index :client_avatar_suspensions,
                 name: "index_client_avatar_suspensions_on_client_id",
                 if_exists: true

    # ClientAvatarOversight
    remove_index :client_avatar_oversights,
                 name: "index_client_avatar_oversights_on_client_id",
                 if_exists: true

    # ClientAvatarImpersonation
    remove_index :client_avatar_impersonations,
                 name: "index_client_avatar_impersonations_on_client_id",
                 if_exists: true

    # ClientAvatarExtraction
    remove_index :client_avatar_extractions,
                 name: "index_client_avatar_extractions_on_client_id",
                 if_exists: true

    # ClientAvatarDeletion
    remove_index :client_avatar_deletions,
                 name: "index_client_avatar_deletions_on_client_id",
                 if_exists: true

    # ClientAvatarAccess
    remove_index :client_avatar_accesses,
                 name: "index_client_avatar_accesses_on_client_id",
                 if_exists: true

    # AvatarRolePermission
    remove_index :avatar_role_permissions,
                 name: "index_avatar_role_permissions_on_avatar_role_id",
                 if_exists: true
  end
end
