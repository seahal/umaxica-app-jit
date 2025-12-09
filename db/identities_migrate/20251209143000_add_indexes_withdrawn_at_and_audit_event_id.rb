class AddIndexesWithdrawnAtAndAuditEventId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    # Partial indexes for withdrawn_at to speed up non-withdrawn queries
    unless index_exists?(:users, :withdrawn_at, name: 'index_users_on_withdrawn_at')
      add_index :users, :withdrawn_at, name: 'index_users_on_withdrawn_at', where: 'withdrawn_at IS NOT NULL'
    end

    unless index_exists?(:staffs, :withdrawn_at, name: 'index_staffs_on_withdrawn_at')
      add_index :staffs, :withdrawn_at, name: 'index_staffs_on_withdrawn_at', where: 'withdrawn_at IS NOT NULL'
    end

    # Indexes on audit event_id for faster joins/filters
    unless index_exists?(:user_identity_audits, :event_id, name: 'index_user_identity_audits_on_event_id')
      add_index :user_identity_audits, :event_id, name: 'index_user_identity_audits_on_event_id'
    end

    unless index_exists?(:staff_identity_audits, :event_id, name: 'index_staff_identity_audits_on_event_id')
      add_index :staff_identity_audits, :event_id, name: 'index_staff_identity_audits_on_event_id'
    end
  end
end
