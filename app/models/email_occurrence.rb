class EmailOccurrence < UniversalRecord
  include PublicId

  belongs_to :email_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :email_occurrences

  validates :public_id,
            presence: true,
            length: { is: 21 },
            format: { with: /\A[A-Za-z0-9_-]{21}\z/ },
            uniqueness: true
  validates :body, presence: true, uniqueness: true
  validates :status_id, presence: true
  validates :memo, length: { maximum: 1024 }, allow_nil: true
end
