# frozen_string_literal: true

class UserIdentityAuditEvent < IdentitiesRecord
  # user_identity_audits との関連付け
  has_many :user_identity_audits, dependent: :destroy, inverse_of: :user_identity_audit_event

  before_validation { self.id = id&.upcase }
  # id自体が識別子なので、idに対するバリデーションを設定
  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: /\A[A-Z0-9_]+\z/, message: :identity_audit_event_format_invalid }
end
