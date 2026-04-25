# typed: false
# frozen_string_literal: true

class RemoveRedundantIndexesAvatarClients < ActiveRecord::Migration[8.2]
  def change
    remove_index(:client_avatar_visibilities, column: :client_id) if index_exists?(
      :client_avatar_visibilities,
      :client_id,
      name: :index_client_avatar_visibilities_on_client_id,
    )

    remove_index(:client_avatar_suspensions, column: :client_id) if index_exists?(
      :client_avatar_suspensions,
      :client_id,
      name: :index_client_avatar_suspensions_on_client_id,
    )

    remove_index(:client_avatar_oversights, column: :client_id) if index_exists?(
      :client_avatar_oversights,
      :client_id,
      name: :index_client_avatar_oversights_on_client_id,
    )

    remove_index(:client_avatar_impersonations, column: :client_id) if index_exists?(
      :client_avatar_impersonations,
      :client_id,
      name: :index_client_avatar_impersonations_on_client_id,
    )

    remove_index(:client_avatar_extractions, column: :client_id) if index_exists?(
      :client_avatar_extractions,
      :client_id,
      name: :index_client_avatar_extractions_on_client_id,
    )

    remove_index(:client_avatar_deletions, column: :client_id) if index_exists?(
      :client_avatar_deletions,
      :client_id,
      name: :index_client_avatar_deletions_on_client_id,
    )

    remove_index(:client_avatar_accesses, column: :client_id) if index_exists?(
      :client_avatar_accesses,
      :client_id,
      name: :index_client_avatar_accesses_on_client_id,
    )
  end
end
