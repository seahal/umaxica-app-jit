# typed: false
# frozen_string_literal: true

# Migration to remove redundant indexes from avatar tables
# This resolves RedundantIndexChecker warnings
class RemoveRedundantAvatarIndexes < ActiveRecord::Migration[7.1]
  def change
    # ClientAvatarVisibility
    remove_index(
      :client_avatar_visibilities,
      column: :client_id,
      name: "index_client_avatar_visibilities_on_client_id",
      if_exists: true,
    )

    # ClientAvatarSuspension
    remove_index(
      :client_avatar_suspensions,
      column: :client_id,
      name: "index_client_avatar_suspensions_on_client_id",
      if_exists: true,
    )

    # ClientAvatarOversight
    remove_index(
      :client_avatar_oversights,
      column: :client_id,
      name: "index_client_avatar_oversights_on_client_id",
      if_exists: true,
    )

    # ClientAvatarImpersonation
    remove_index(
      :client_avatar_impersonations,
      column: :client_id,
      name: "index_client_avatar_impersonations_on_client_id",
      if_exists: true,
    )

    # ClientAvatarExtraction
    remove_index(
      :client_avatar_extractions,
      column: :client_id,
      name: "index_client_avatar_extractions_on_client_id",
      if_exists: true,
    )

    # ClientAvatarDeletion
    remove_index(
      :client_avatar_deletions,
      column: :client_id,
      name: "index_client_avatar_deletions_on_client_id",
      if_exists: true,
    )

    # ClientAvatarAccess
    remove_index(
      :client_avatar_accesses,
      column: :client_id,
      name: "index_client_avatar_accesses_on_client_id",
      if_exists: true,
    )

    # AvatarRolePermission
    remove_index(
      :avatar_role_permissions,
      column: :avatar_role_id,
      name: "index_avatar_role_permissions_on_avatar_role_id",
      if_exists: true,
    )
  end
end
