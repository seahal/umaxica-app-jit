class UpdateStaffIdentityAuditsForeignKey < ActiveRecord::Migration[8.2]
  def change
    # テーブルがリネームされた後なので、FK は自動的に更新される
    # もし FK に問題がある場合は、明示的に再作成する
    unless foreign_key_exists?(:staff_identity_audits, column: :status_id)
      if foreign_key_exists?(:staff_identity_audits, :staff_identity_audit_statuses)
        remove_foreign_key :staff_identity_audits, :staff_identity_audit_statuses
      end
      add_foreign_key :staff_identity_audits, :staff_identity_audit_statuses, column: :status_id
    end
  end
end
