# frozen_string_literal: true

# == Schema Information
#
# Table name: billing_stripe_events
#
#  id           :uuid             not null, primary key
#  event_id     :string           not null
#  event_type   :string           not null
#  livemode     :boolean          default(FALSE), not null
#  payload_json :jsonb            not null
#  received_at  :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_billing_stripe_events_on_event_id     (event_id) UNIQUE
#  index_billing_stripe_events_on_received_at  (received_at)
#

module Billing
  class StripeEvent < BillingRecord
    self.table_name = "billing_stripe_events"

    validates :event_id, presence: true, uniqueness: true
    validates :event_type, presence: true
    validates :livemode, inclusion: { in: [true, false] }
    validates :payload_json, presence: true
    validates :received_at, presence: true
  end
end
