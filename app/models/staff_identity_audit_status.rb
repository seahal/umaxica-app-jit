# frozen_string_literal: true

class StaffIdentityAuditStatus < IdentitiesRecord
  # staff_identity_audits との関連付け
  has_many :staff_identity_audits, dependent: :destroy, inverse_of: :staff_identity_audit_status

  # id自体が識別子なので、idに対するバリデーションを設定
  validates :id, presence: true, uniqueness: true, format: { with: /\A[A-Z_]+\z/, message: :identity_audit_event_format_invalid }
end
