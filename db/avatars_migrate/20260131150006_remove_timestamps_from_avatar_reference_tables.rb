# frozen_string_literal: true

class RemoveTimestampsFromAvatarReferenceTables < ActiveRecord::Migration[8.2]
  REFERENCE_TABLES = %w[
    avatar_capabilities
    avatar_permissions
    avatar_roles
    post_review_statuses
    avatar_role_permissions
  ].freeze

  def up
    REFERENCE_TABLES.each do |table|
      %i[created_at updated_at].each do |column|
        safety_assured { remove_column table, column, :datetime } if column_exists?(table, column)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
