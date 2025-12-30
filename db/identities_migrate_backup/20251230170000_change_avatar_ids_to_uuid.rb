# frozen_string_literal: true

class ChangeAvatarIdsToUuid < ActiveRecord::Migration[8.2]
  REFERENCE_COLUMNS = [
    { table: :handle_assignments, old: :avatar_id, new: :avatar_uuid, not_null: true },
    { table: :avatar_monikers, old: :avatar_id, new: :avatar_uuid, not_null: true },
    { table: :avatar_memberships, old: :avatar_id, new: :avatar_uuid, not_null: true },
    { table: :avatar_ownership_periods, old: :avatar_id, new: :avatar_uuid, not_null: true },
    { table: :avatar_assignments, old: :avatar_id, new: :avatar_uuid, not_null: true },
    { table: :posts, old: :author_avatar_id, new: :author_avatar_uuid, not_null: true },
    { table: :avatar_follows, old: :follower_avatar_id, new: :follower_avatar_uuid, not_null: true },
    { table: :avatar_follows, old: :followed_avatar_id, new: :followed_avatar_uuid, not_null: true },
    { table: :avatar_blocks, old: :blocker_avatar_id, new: :blocker_avatar_uuid, not_null: true },
    { table: :avatar_blocks, old: :blocked_avatar_id, new: :blocked_avatar_uuid, not_null: true },
    { table: :avatar_mutes, old: :muter_avatar_id, new: :muter_avatar_uuid, not_null: true },
    { table: :avatar_mutes, old: :muted_avatar_id, new: :muted_avatar_uuid, not_null: true },
  ].freeze

  def up
    remove_avatar_foreign_keys

    add_column :avatars, :uuid, :uuid
    safety_assured do
      execute "UPDATE avatars SET uuid = uuidv7() WHERE uuid IS NULL"
      change_column_null :avatars, :uuid, false
      add_index :avatars, :uuid, unique: true
    end

    add_reference_uuid_columns
    backfill_reference_uuid_columns(from: :id, to: :uuid)
    swap_reference_columns

    swap_avatar_primary_key
    rebuild_reference_indexes

    add_avatar_foreign_keys(validate: false)
  end

  def down
    remove_avatar_foreign_keys

    add_reference_string_columns
    backfill_reference_string_columns
    swap_reference_columns(reverse: true)

    restore_avatar_primary_key
    rebuild_reference_indexes

    add_avatar_foreign_keys(validate: false)
  end

  private

  def remove_avatar_foreign_keys
    remove_foreign_key :handle_assignments, column: :avatar_id, if_exists: true
    remove_foreign_key :avatar_monikers, column: :avatar_id, if_exists: true
    remove_foreign_key :avatar_memberships, column: :avatar_id, if_exists: true
    remove_foreign_key :avatar_ownership_periods, column: :avatar_id, if_exists: true
    remove_foreign_key :avatar_assignments, column: :avatar_id, if_exists: true
    remove_foreign_key :posts, column: :author_avatar_id, if_exists: true
    remove_foreign_key :avatar_follows, column: :follower_avatar_id, if_exists: true
    remove_foreign_key :avatar_follows, column: :followed_avatar_id, if_exists: true
    remove_foreign_key :avatar_blocks, column: :blocker_avatar_id, if_exists: true
    remove_foreign_key :avatar_blocks, column: :blocked_avatar_id, if_exists: true
    remove_foreign_key :avatar_mutes, column: :muter_avatar_id, if_exists: true
    remove_foreign_key :avatar_mutes, column: :muted_avatar_id, if_exists: true
  end

  def add_avatar_foreign_keys(validate:)
    add_foreign_key :handle_assignments, :avatars, column: :avatar_id, validate: validate if column_exists?(
      :handle_assignments, :avatar_id,
    )
    add_foreign_key :avatar_monikers, :avatars, column: :avatar_id, validate: validate if column_exists?(
      :avatar_monikers, :avatar_id,
    )
    add_foreign_key :avatar_memberships, :avatars, column: :avatar_id, validate: validate if column_exists?(
      :avatar_memberships, :avatar_id,
    )
    add_foreign_key :avatar_ownership_periods, :avatars, column: :avatar_id, validate: validate if column_exists?(
      :avatar_ownership_periods, :avatar_id,
    )
    add_foreign_key :avatar_assignments, :avatars, column: :avatar_id, on_delete: :cascade,
                                                   validate: validate if column_exists?(
                                                     :avatar_assignments, :avatar_id,
                                                   )
    add_foreign_key :posts, :avatars, column: :author_avatar_id, validate: validate if column_exists?(
      :posts,
      :author_avatar_id,
    )
    add_foreign_key :avatar_follows, :avatars, column: :follower_avatar_id, validate: validate if column_exists?(
      :avatar_follows, :follower_avatar_id,
    )
    add_foreign_key :avatar_follows, :avatars, column: :followed_avatar_id, validate: validate if column_exists?(
      :avatar_follows, :followed_avatar_id,
    )
    add_foreign_key :avatar_blocks, :avatars, column: :blocker_avatar_id, validate: validate if column_exists?(
      :avatar_blocks, :blocker_avatar_id,
    )
    add_foreign_key :avatar_blocks, :avatars, column: :blocked_avatar_id, validate: validate if column_exists?(
      :avatar_blocks, :blocked_avatar_id,
    )
    add_foreign_key :avatar_mutes, :avatars, column: :muter_avatar_id, validate: validate if column_exists?(
      :avatar_mutes, :muter_avatar_id,
    )
    add_foreign_key :avatar_mutes, :avatars, column: :muted_avatar_id, validate: validate if column_exists?(
      :avatar_mutes, :muted_avatar_id,
    )
  end

  def add_reference_uuid_columns
    REFERENCE_COLUMNS.each do |ref|
      next unless column_exists?(ref[:table], ref[:old])

      add_column ref[:table], ref[:new], :uuid
    end
  end

  def backfill_reference_uuid_columns(from:, to:)
    REFERENCE_COLUMNS.each do |ref|
      next unless column_exists?(ref[:table], ref[:new])

      safety_assured do
        execute <<~SQL.squish
          UPDATE #{ref[:table]}
          SET #{ref[:new]} = avatars.#{to}
          FROM avatars
          WHERE #{ref[:table]}.#{ref[:old]} = avatars.#{from}
        SQL

        change_column_null ref[:table], ref[:new], false if ref[:not_null]
      end
    end
  end

  def add_reference_string_columns
    REFERENCE_COLUMNS.each do |ref|
      next unless column_exists?(ref[:table], ref[:old])

      add_column ref[:table], "#{ref[:old]}_legacy", :string
    end
  end

  def backfill_reference_string_columns
    safety_assured do
      execute "UPDATE avatars SET legacy_id = id::text WHERE legacy_id IS NULL"
    end

    REFERENCE_COLUMNS.each do |ref|
      legacy_column = "#{ref[:old]}_legacy"
      next unless column_exists?(ref[:table], legacy_column)

      safety_assured do
        execute <<~SQL.squish
          UPDATE #{ref[:table]}
          SET #{legacy_column} = avatars.legacy_id
          FROM avatars
          WHERE #{ref[:table]}.#{ref[:old]} = avatars.id
        SQL
      end
    end
  end

  def swap_reference_columns(reverse: false)
    if reverse
      REFERENCE_COLUMNS.each do |ref|
        legacy_column = "#{ref[:old]}_legacy"
        next unless column_exists?(ref[:table], legacy_column)

        safety_assured do
          remove_column ref[:table], ref[:old], :uuid
          rename_column ref[:table], legacy_column, ref[:old]
          change_column_null ref[:table], ref[:old], false if ref[:not_null]
        end
      end
    else
      REFERENCE_COLUMNS.each do |ref|
        next unless column_exists?(ref[:table], ref[:new])

        safety_assured do
          remove_column ref[:table], ref[:old], :string
          rename_column ref[:table], ref[:new], ref[:old]
        end
      end
    end
  end

  def swap_avatar_primary_key
    safety_assured do
      execute "ALTER TABLE avatars DROP CONSTRAINT IF EXISTS avatars_pkey"
      rename_column :avatars, :id, :legacy_id
      # rubocop:disable Rails/DangerousColumnNames
      rename_column :avatars, :uuid, :id
      # rubocop:enable Rails/DangerousColumnNames
      change_column_null :avatars, :legacy_id, true
    end
    change_column_default :avatars, :id, from: nil, to: -> { "uuidv7()" }
    safety_assured do
      execute "ALTER TABLE avatars ADD PRIMARY KEY (id)"
    end
  end

  def restore_avatar_primary_key
    safety_assured do
      execute "ALTER TABLE avatars DROP CONSTRAINT IF EXISTS avatars_pkey"
      rename_column :avatars, :id, :uuid
      # rubocop:disable Rails/DangerousColumnNames
      rename_column :avatars, :legacy_id, :id
      # rubocop:enable Rails/DangerousColumnNames
      change_column_null :avatars, :id, false
    end
    change_column_default :avatars, :id, from: -> { "uuidv7()" }, to: nil
    safety_assured do
      execute "ALTER TABLE avatars ADD PRIMARY KEY (id)"
      remove_column :avatars, :uuid, :uuid
    end
  end

  def rebuild_reference_indexes
    safety_assured do
      add_index :handle_assignments, :avatar_id,
                unique: true,
                where: "valid_to = 'infinity'",
                name: "index_handle_assignments_on_avatar_id",
                if_not_exists: true
      add_index :handle_assignments, [:avatar_id, :valid_from],
                order: { valid_from: :desc },
                name: "index_handle_assignments_on_avatar_id_and_valid_from",
                if_not_exists: true

      add_index :avatar_monikers, :avatar_id,
                unique: true,
                where: "valid_to = 'infinity'",
                name: "index_avatar_monikers_on_avatar_id",
                if_not_exists: true
      add_index :avatar_monikers, [:avatar_id, :valid_from],
                order: { valid_from: :desc },
                name: "index_avatar_monikers_on_avatar_id_and_valid_from",
                if_not_exists: true

      add_index :avatar_memberships, [:avatar_id, :actor_id],
                unique: true,
                where: "valid_to = 'infinity'",
                name: "index_avatar_memberships_on_avatar_id_and_actor_id",
                if_not_exists: true
      add_index :avatar_memberships, :avatar_id,
                where: "valid_to = 'infinity'",
                name: "index_avatar_memberships_on_avatar_id",
                if_not_exists: true

      add_index :avatar_ownership_periods, :avatar_id,
                unique: true,
                where: "valid_to = 'infinity'",
                name: "index_avatar_ownership_periods_on_avatar_id",
                if_not_exists: true

      add_index :posts, [:author_avatar_id, :created_at],
                order: { created_at: :desc },
                name: "index_posts_on_author_avatar_id_and_created_at",
                if_not_exists: true

      add_index :avatar_assignments, %i(avatar_id user_id role),
                unique: true,
                name: "index_avatar_assignments_unique",
                if_not_exists: true

      execute <<~SQL.squish
        CREATE UNIQUE INDEX IF NOT EXISTS index_avatar_assignments_unique_owner
        ON avatar_assignments (avatar_id)
        WHERE role = 'owner';
      SQL
      execute <<~SQL.squish
        CREATE UNIQUE INDEX IF NOT EXISTS index_avatar_assignments_unique_affiliation
        ON avatar_assignments (avatar_id)
        WHERE role = 'affiliation';
      SQL

      add_index :avatar_follows, :follower_avatar_id, if_not_exists: true
      add_index :avatar_follows, :followed_avatar_id, if_not_exists: true
      add_index :avatar_blocks, :blocker_avatar_id, if_not_exists: true
      add_index :avatar_blocks, :blocked_avatar_id, if_not_exists: true
      add_index :avatar_mutes, :muter_avatar_id, if_not_exists: true
      add_index :avatar_mutes, :muted_avatar_id, if_not_exists: true
    end
  end
end
