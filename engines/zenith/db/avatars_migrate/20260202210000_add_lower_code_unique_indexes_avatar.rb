# typed: false
# frozen_string_literal: true

class AddLowerCodeUniqueIndexesAvatar < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %w(
    avatar_capabilities
    avatar_membership_statuses
    avatar_moniker_statuses
    avatar_ownership_statuses
    avatar_permissions
    avatar_roles
    handle_assignment_statuses
    handle_statuses
    post_review_statuses
    post_statuses
  ).freeze

  def up
    safety_assured do
      TABLES.each do |table|
        add_lower_code_index(table)
      end
    end
  end

  def down
    TABLES.each do |table|
      index_name = "index_#{table}_on_lower_code"
      remove_index(table, name: index_name) if index_exists?(table, nil, name: index_name)
    end
  end

  private

  def add_lower_code_index(table)
    return unless table_exists?(table) && column_exists?(table, :code)

    index_name = "index_#{table}_on_lower_code"
    return if index_exists?(table, nil, name: index_name)

    add_index(table, "lower(code)", unique: true, name: index_name, algorithm: :concurrently)
  end
end
