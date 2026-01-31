# frozen_string_literal: true

class AvatarReferenceTableTimestampsRemoval < ActiveRecord::Migration[8.2]
  TARGET_TABLES = %i(
    avatar_membership_statuses
    avatar_moniker_statuses
    avatar_ownership_statuses
    handle_assignment_statuses
    handle_statuses
    post_statuses
  ).freeze

  def up
    TARGET_TABLES.each do |table|
      next unless table_exists?(table)

      safety_assured do
        remove_column(table, :created_at) if column_exists?(table, :created_at)
        remove_column(table, :updated_at) if column_exists?(table, :updated_at)
      end
    end
  end

  def down
    TARGET_TABLES.each do |table|
      next unless table_exists?(table)

      safety_assured do
        add_column(
          table,
          :created_at,
          :datetime,
          null: false,
          default: -> { "CURRENT_TIMESTAMP" },
        ) unless column_exists?(table, :created_at)
        add_column(
          table,
          :updated_at,
          :datetime,
          null: false,
          default: -> { "CURRENT_TIMESTAMP" },
        ) unless column_exists?(table, :updated_at)

        change_column_default(table, :created_at, nil) if column_exists?(table, :created_at)
        change_column_default(table, :updated_at, nil) if column_exists?(table, :updated_at)
      end
    end
  end
end
