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
