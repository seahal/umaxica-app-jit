# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: jwt_anomaly_events
# Database name: occurrence
#
#  id                :bigint           not null, primary key
#  alg               :string           default(""), not null
#  code              :string           default(""), not null
#  error_class       :string           default(""), not null
#  error_message     :string           default(""), not null
#  issuer            :string           default(""), not null
#  jti               :string           default(""), not null
#  kid               :string           default(""), not null
#  metadata          :jsonb            not null
#  occurred_at       :datetime         not null
#  request_host      :string           default(""), not null
#  typ               :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  jwt_occurrence_id :bigint           not null
#
# Indexes
#
#  index_jwt_anomaly_events_on_code               (code)
#  index_jwt_anomaly_events_on_jwt_occurrence_id  (jwt_occurrence_id)
#  index_jwt_anomaly_events_on_occurred_at        (occurred_at)
#
# Foreign Keys
#
#  fk_jwt_anomaly_events_on_jwt_occurrence_id  (jwt_occurrence_id => jwt_occurrences.id)
#
require "test_helper"

class JwtAnomalyEventTest < ActiveSupport::TestCase
  fixtures :jwt_occurrences

  test "validates code presence" do
    event = JwtAnomalyEvent.new(
      jwt_occurrence: jwt_occurrences(:auth_user_malformed_token),
      code: "",
      request_host: "example.com",
      metadata: {},
      occurred_at: Time.current,
    )

    assert_not_predicate event, :valid?
    assert_predicate event.errors[:code], :present?
  end

  test "validates code maximum length" do
    event = JwtAnomalyEvent.new(
      jwt_occurrence: jwt_occurrences(:auth_user_malformed_token),
      code: "a" * 256,
      request_host: "example.com",
      metadata: {},
      occurred_at: Time.current,
    )

    assert_not_predicate event, :valid?
    assert_predicate event.errors[:code], :present?
  end

  test "validates request_host maximum length" do
    event = JwtAnomalyEvent.new(
      jwt_occurrence: jwt_occurrences(:auth_user_malformed_token),
      code: "MALFORMED_TOKEN",
      request_host: "a" * 256,
      metadata: {},
      occurred_at: Time.current,
    )

    assert_not_predicate event, :valid?
    assert_predicate event.errors[:request_host], :present?
  end

  test "validates presence of metadata" do
    event = JwtAnomalyEvent.new(
      jwt_occurrence: jwt_occurrences(:auth_user_malformed_token),
      code: "MALFORMED_TOKEN",
      request_host: "example.com",
      metadata: nil,
      occurred_at: Time.current,
    )

    assert_not_predicate event, :valid?
    assert_predicate event.errors[:metadata], :present?
  end

  test "validates presence of occurred_at" do
    event = JwtAnomalyEvent.new(
      jwt_occurrence: jwt_occurrences(:auth_user_malformed_token),
      code: "MALFORMED_TOKEN",
      request_host: "example.com",
      metadata: {},
      occurred_at: nil,
    )

    assert_not_predicate event, :valid?
    assert_predicate event.errors[:occurred_at], :present?
  end

  test "validates kid maximum length" do
    event = JwtAnomalyEvent.new(
      jwt_occurrence: jwt_occurrences(:auth_user_malformed_token),
      code: "MALFORMED_TOKEN",
      kid: "a" * 256,
      request_host: "example.com",
      metadata: {},
      occurred_at: Time.current,
    )

    assert_not_predicate event, :valid?
    assert_predicate event.errors[:kid], :present?
  end

  test "validates error_message maximum length" do
    event = JwtAnomalyEvent.new(
      jwt_occurrence: jwt_occurrences(:auth_user_malformed_token),
      code: "MALFORMED_TOKEN",
      error_message: "a" * 1001,
      request_host: "example.com",
      metadata: {},
      occurred_at: Time.current,
    )

    assert_not_predicate event, :valid?
    assert_predicate event.errors[:error_message], :present?
  end

  test "belongs_to jwt_occurrence" do
    event = JwtAnomalyEvent.new(
      jwt_occurrence: jwt_occurrences(:auth_user_malformed_token),
      code: "MALFORMED_TOKEN",
      request_host: "example.com",
      metadata: {},
      occurred_at: Time.current,
    )

    assert event.jwt_occurrence
    assert_equal jwt_occurrences(:auth_user_malformed_token), event.jwt_occurrence
  end
end
