# frozen_string_literal: true

require "test_helper"

class OccurrenceWriterTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @previous_env = ENV["OCCURRENCE_HMAC_SECRET"]
    ENV["OCCURRENCE_HMAC_SECRET"] = "secret"
    Occurrence::Writer.instance_variable_set(:@status_id_cache, nil)
  end

  teardown do
    if @previous_env.nil?
      ENV.delete("OCCURRENCE_HMAC_SECRET")
    else
      ENV["OCCURRENCE_HMAC_SECRET"] = @previous_env
    end

    EmailOccurrence.delete_all
    TelephoneOccurrence.delete_all
    IpOccurrence.delete_all
  end

  test "log_email! sets expires_at and memo defaults" do
    travel_to Time.zone.parse("2026-02-12 12:00:00") do
      record = Occurrence::Writer.log_email!(email: "test@example.com", status: :active)

      assert_equal "", record.memo
      assert_equal 366.days.from_now, record.expires_at
      assert_equal EmailOccurrenceStatus::ACTIVE, record.status_id
    end
  end

  test "log_ip! sets expires_at" do
    travel_to Time.zone.parse("2026-02-12 12:00:00") do
      record = Occurrence::Writer.log_ip!(ip: "192.0.2.1", status: :active, memo: "")

      assert_equal 31.days.from_now, record.expires_at
      assert_equal IpOccurrenceStatus::ACTIVE, record.status_id
    end
  end

  test "writer does not call SecureRandom.uuid" do
    SecureRandom.stub(:uuid, -> { raise "uuid should not be called" }) do
      Occurrence::Writer.log_email!(email: "test@example.com", status: :active)
    end
  end

  test "status resolution uses status model lookup" do
    called = false
    EmailOccurrenceStatus.stub(
      :find_or_create_by!, lambda { |id:|
                             called = true
                             EmailOccurrenceStatus.find_by(id: id) || EmailOccurrenceStatus.create!(id: id)
                           },
    ) do
      record = Occurrence::Writer.log_email!(email: "status@example.com", status: :active)

      assert_equal EmailOccurrenceStatus::ACTIVE, record.status_id
    end

    assert called
  end
end
