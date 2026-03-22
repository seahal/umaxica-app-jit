# frozen_string_literal: true

class AddMissingIndexesForAvatarConsistency < ActiveRecord::Migration[7.1]
  def up
    add_index(
      :avatar_role_permissions, :avatar_permission_id,
      if_not_exists: true,
    ) if table_exists?(:avatar_role_permissions)
    remove_index(
      :avatar_memberships, name: :index_avatar_memberships_on_avatar_id,
                           if_exists: true,
    ) if table_exists?(:avatar_memberships)
  end

  def down
    add_index(
      :avatar_memberships, :avatar_id, name: :index_avatar_memberships_on_avatar_id,
                                       if_not_exists: true,
    ) if table_exists?(:avatar_memberships)
  end
end
