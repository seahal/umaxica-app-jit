# frozen_string_literal: true

class RemoveRedundantIndexes < ActiveRecord::Migration[8.2]
  def change
    # UserClient - index_user_clients_on_user_id is redundant as index_user_clients_on_user_id_and_client_id covers it
    remove_index :user_clients, column: :user_id if index_exists?(
      :user_clients,
      :user_id,
      name: :index_user_clients_on_user_id,
    )

    # ClientAvatarVisibility - index_client_avatar_visibilities_on_client_id is redundant
    remove_index :client_avatar_visibilities, column: :client_id if index_exists?(
      :client_avatar_visibilities,
      :client_id,
      name: :index_client_avatar_visibilities_on_client_id,
    )

    # ClientAvatarSuspension - index_client_avatar_suspensions_on_client_id is redundant
    remove_index :client_avatar_suspensions, column: :client_id if index_exists?(
      :client_avatar_suspensions,
      :client_id,
      name: :index_client_avatar_suspensions_on_client_id,
    )

    # ClientAvatarOversight - index_client_avatar_oversights_on_client_id is redundant
    remove_index :client_avatar_oversights, column: :client_id if index_exists?(
      :client_avatar_oversights,
      :client_id,
      name: :index_client_avatar_oversights_on_client_id,
    )

    # ClientAvatarImpersonation - index_client_avatar_impersonations_on_client_id is redundant
    remove_index :client_avatar_impersonations, column: :client_id if index_exists?(
      :client_avatar_impersonations,
      :client_id,
      name: :index_client_avatar_impersonations_on_client_id,
    )

    # ClientAvatarExtraction - index_client_avatar_extractions_on_client_id is redundant
    remove_index :client_avatar_extractions, column: :client_id if index_exists?(
      :client_avatar_extractions,
      :client_id,
      name: :index_client_avatar_extractions_on_client_id,
    )

    # ClientAvatarDeletion - index_client_avatar_deletions_on_client_id is redundant
    remove_index :client_avatar_deletions, column: :client_id if index_exists?(
      :client_avatar_deletions,
      :client_id,
      name: :index_client_avatar_deletions_on_client_id,
    )

    # ClientAvatarAccess - index_client_avatar_accesses_on_client_id is redundant
    remove_index :client_avatar_accesses, column: :client_id if index_exists?(
      :client_avatar_accesses,
      :client_id,
      name: :index_client_avatar_accesses_on_client_id,
    )

    # Department - index_departments_on_department_status_id is redundant
    remove_index :departments, column: :department_status_id if index_exists?(
      :departments,
      :department_status_id,
      name: :index_departments_on_department_status_id,
    )

    # Department - Remove one of the redundant unique indexes
    # Keep index_departments_on_status_and_parent and remove index_departments_on_department_status_id_and_parent_id
    remove_index :departments, column: %i[department_status_id parent_id] if index_exists?(
      :departments,
      %i[department_status_id parent_id],
      name: :index_departments_on_department_status_id_and_parent_id,
    )
  end
end
