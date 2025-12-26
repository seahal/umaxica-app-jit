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

require "test_helper"

module Billing
  class StripeEventTest < ActiveSupport::TestCase
    def build_attributes(event_id: "evt_#{SecureRandom.hex(6)}")
      {
        event_id: event_id,
        event_type: "payment_intent.succeeded",
        livemode: false,
        payload_json: { id: event_id, object: "event" },
        received_at: Time.current
      }
    end

    test "uses the billing database" do
      assert_equal "billing", Billing::StripeEvent.connection_db_config.name
    end

    test "creates a billing stripe event" do
      event = Billing::StripeEvent.create!(build_attributes)
      assert_predicate event, :persisted?
    end

    test "enforces unique event_id at the database level" do
      event_id = "evt_unique_1"
      Billing::StripeEvent.create!(build_attributes(event_id: event_id))

      attributes = build_attributes(event_id: event_id)
      timestamp = Time.current
      sql = <<~SQL.squish
        INSERT INTO billing_stripe_events (
          event_id, event_type, livemode, payload_json, received_at, created_at, updated_at
        ) VALUES (
          #{Billing::StripeEvent.connection.quote(attributes[:event_id])},
          #{Billing::StripeEvent.connection.quote(attributes[:event_type])},
          #{Billing::StripeEvent.connection.quote(attributes[:livemode])},
          #{Billing::StripeEvent.connection.quote(attributes[:payload_json].to_json)},
          #{Billing::StripeEvent.connection.quote(attributes[:received_at])},
          #{Billing::StripeEvent.connection.quote(timestamp)},
          #{Billing::StripeEvent.connection.quote(timestamp)}
        )
      SQL

      assert_raises ActiveRecord::RecordNotUnique do
        Billing::StripeEvent.connection.execute(sql)
      end
    end
  end
end
