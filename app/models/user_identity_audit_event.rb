class UserIdentityAuditEvent < IdentitiesRecord
  # user_identity_audits との関連付け
  has_many :user_identity_audits, dependent: :destroy, inverse_of: :user_identity_audit_event

  # id自体が識別子なので、idに対するバリデーションを設定
  validates :id, presence: true, uniqueness: true, format: { with: /\A[A-Z_]+\z/, message: :identity_audit_event_format_invalid }
end
