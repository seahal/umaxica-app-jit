# typed: false
# frozen_string_literal: true

module Auth
  module Checkpoint
    extend ActiveSupport::Concern

    CHECKPOINT_SESSION_KEY = :checkpoint
    CHECKPOINT_TIMEOUT = 2.hours

    def issue_checkpoint!(kind: "mock", state: "new", payload: {})
      session[CHECKPOINT_SESSION_KEY] = {
        "issued_at" => Time.current.to_i,
        "kind" => kind.to_s,
        "state" => state.to_s,
      }.merge(payload.stringify_keys)
    end

    def checkpoint_state
      raw = session[CHECKPOINT_SESSION_KEY]
      return nil unless raw.is_a?(Hash)

      raw.with_indifferent_access
    end

    def checkpoint_active?
      checkpoint_state.present? && !checkpoint_expired?
    end

    def checkpoint_expired?
      data = checkpoint_state
      return true if data.blank?

      issued_at = data[:issued_at].to_i
      return true if issued_at <= 0

      Time.current.to_i >= issued_at + CHECKPOINT_TIMEOUT.to_i
    end

    def refresh_checkpoint_dimension!(state: "updated")
      data = checkpoint_state
      return unless data

      session[CHECKPOINT_SESSION_KEY] = data.merge(
        "issued_at" => Time.current.to_i,
        "state" => state.to_s,
      )
    end

    def consume_checkpoint!
      session.delete(CHECKPOINT_SESSION_KEY)
    end

    def maybe_inject_test_checkpoint!
      return unless Rails.env.test?

      raw = request.headers[Auth::IoKeys::Headers::TEST_CHECKPOINT]
      return if raw.blank?
      return if session[CHECKPOINT_SESSION_KEY].present?

      session[CHECKPOINT_SESSION_KEY] = JSON.parse(raw)
    end
  end
end
