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
#  index_billing_stripe_events_on_event_id     (event_id)
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
        received_at: Time.current,
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
      event_id = "evt_#{SecureRandom.uuid}"
      event = Billing::StripeEvent.create!(build_attributes(event_id: event_id))

      duplicate = Billing::StripeEvent.new(build_attributes(event_id: event_id))
      assert_raises ActiveRecord::RecordNotUnique do
        duplicate.save(validate: false)
      end
    end
  end
end
