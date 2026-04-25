# typed: false
# frozen_string_literal: true

class FixDatabaseConsistencyAvatar < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    # Add foreign key for post versions
    return if foreign_key_exists?(:post_versions, :posts, column: :post_id)

    add_foreign_key(:post_versions, :posts, column: :post_id, validate: false)
    validate_foreign_key(:post_versions, :posts)

    # Add foreign key for client avatars (Cross-DB or same DB check)
    # Note: If this fails due to separate databases, it should be removed or handled differently.
    # Assuming user wants it here if they put it in identities_migrate originally.
    # But strictly, avatars is in avatar_db. clients is in identity_db.
    # We will try to add it here.
    # unless foreign_key_exists?(:avatars, :clients, column: :client_id)
    #   add_foreign_key :avatars, :clients,
    #                   column: :client_id,
    #                   on_delete: :nullify,
    #                   validate: false
    #   validate_foreign_key :avatars, :clients
    # end
  end

  def down
    remove_foreign_key(:post_versions, :posts, if_exists: true)
    # remove_foreign_key :avatars, :clients, if_exists: true
  end
end
