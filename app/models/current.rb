# typed: false
# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :actor, :actor_type, :session, :token, :domain, :preference,
            :trace_id, :span_id,
            :surface, :realm, :request_id

  ALLOWED_ACTOR_TYPES = %i(user staff customer unauthenticated).freeze

  resets { self.preference = Current::Preference::NULL }

  def self.actor
    super || Unauthenticated.instance
  end

  def self.actor=(value)
    unless valid_actor?(value)
      # TODO: Replace with dedicated exception class (e.g., Current::InvalidActorError)
      # TODO: Consider adding controller-level rescue_from handling in a later pass
      # TODO: Consider forced logout / cookie cleanup for malicious input
      raise ArgumentError,
            "Current.actor must be User, Staff, Customer, or Unauthenticated.instance, " \
            "got #{value.class}"
    end
    super
  end

  def self.actor_type
    super || :unauthenticated
  end

  def self.actor_type=(value)
    unless ALLOWED_ACTOR_TYPES.include?(value)
      # TODO: Replace with dedicated exception class (e.g., Current::InvalidActorTypeError)
      # TODO: Consider adding controller-level rescue_from handling in a later pass
      raise ArgumentError,
            "Current.actor_type must be one of #{ALLOWED_ACTOR_TYPES.inspect}, got #{value.inspect}"
    end
    super
  end

  def self.preference
    super || Current::Preference::NULL
  end

  def self.user?
    actor_type == :user
  end

  def self.staff?
    actor_type == :staff
  end

  def self.customer?
    actor_type == :customer
  end

  def self.unauthenticated?
    actor_type == :unauthenticated
  end

  def self.authenticated?
    %i(user customer staff).include?(actor_type)
  end

  def self.boundary_key
    "#{realm}:#{surface}".freeze
  end

  def self.user
    actor if user?
  end

  def self.staff
    actor if staff?
  end

  def self.customer
    actor if customer?
  end

  def self.surface
    super || :com
  end

  def self.realm
    super || :www
  end

  def self.request_id
    super || ""
  end

  class << self
    private

    def valid_actor?(value)
      return true if value.equal?(Unauthenticated.instance)
      return true if value.is_a?(User)
      return true if value.is_a?(Staff)
      return true if value.is_a?(Customer)

      false
    end
  end
end
