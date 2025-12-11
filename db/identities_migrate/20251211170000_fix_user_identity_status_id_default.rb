class FixUserIdentityStatusIdDefault < ActiveRecord::Migration[8.2]
  def up
    # rubocop:disable Rails/BulkChangeTable
    change_column_default :users, :user_identity_status_id, from: "NONE", to: nil
    change_column_null :users, :user_identity_status_id, true
    # rubocop:enable Rails/BulkChangeTable
  end

  def down
    # rubocop:disable Rails/BulkChangeTable
    change_column_null :users, :user_identity_status_id, false
    change_column_default :users, :user_identity_status_id, from: nil, to: "NONE"
    # rubocop:enable Rails/BulkChangeTable
  end
end
