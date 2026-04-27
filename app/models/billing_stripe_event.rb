# typed: false
# frozen_string_literal: true

# Records events received from Stripe for audit and processing.
# == Schema Information
#
# Table name: billing_stripe_events
# Database name: billing
#
#  id           :bigint           not null, primary key
#  event_type   :string           not null
#  livemode     :boolean          default(FALSE), not null
#  payload_json :jsonb            not null
#  received_at  :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  event_id     :string           not null
#
# Indexes
#
#  index_billing_stripe_events_on_event_id     (event_id) UNIQUE
#  index_billing_stripe_events_on_received_at  (received_at)
#
class BillingStripeEvent < BillingRecord
  validates :event_id, presence: true, uniqueness: true
  validates :event_type, presence: true
  validates :payload_json, presence: true

  # Stores raw payload and meta
  def self.record!(stripe_event)
    create!(
      event_id: stripe_event.id,
      event_type: stripe_event.type,
      livemode: stripe_event.livemode,
      payload_json: stripe_event.to_hash,
      received_at: Time.current,
    )
  end
end
