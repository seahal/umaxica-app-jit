# frozen_string_literal: true

# == Schema Information
#
# Table name: reauth_sessions
# Database name: token
#
#  id            :bigint           not null, primary key
#  actor_type    :string           not null
#  attempt_count :integer          default(0), not null
#  expires_at    :datetime         not null
#  method        :string           not null
#  return_to     :text             not null
#  scope         :string           not null
#  status        :string           not null
#  verified_at   :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  actor_id      :bigint           not null
#
# Indexes
#
#  index_reauth_sessions_on_actor_type_and_actor_id_and_status  (actor_type,actor_id,status)
#  index_reauth_sessions_on_expires_at                          (expires_at)
#
class ReauthSession < TokenRecord
  STATUSES = %w(PENDING VERIFIED CANCELLED EXPIRED).freeze
  METHODS = %w(passkey totp email_otp).freeze

  belongs_to :actor, polymorphic: true

  validates :actor_type, presence: true
  validates :scope, presence: true
  validates :return_to, presence: true
  validates :method, presence: true, inclusion: { in: METHODS }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :expires_at, presence: true
  validates :attempt_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :for_actor, ->(actor) { where(actor_type: actor.class.name, actor_id: actor.id) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: "PENDING") }

  def expired?
    expires_at <= Time.current
  end
end
