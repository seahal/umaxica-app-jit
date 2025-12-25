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

      assert_raises ActiveRecord::RecordNotUnique do
        Billing::StripeEvent.insert_all!([build_attributes(event_id: event_id)])
      end
    end
  end
end
