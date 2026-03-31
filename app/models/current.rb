# typed: false
# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :actor, :actor_type, :session, :token, :domain, :preference,
            :trace_id, :span_id

  resets { self.preference = Current::Preference::NULL }

  def self.actor
    super || Unauthenticated.instance
  end

  def self.actor_type
    super || :unauthenticated
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

  def self.user
    actor if user?
  end

  def self.staff
    actor if staff?
  end

  def self.customer
    actor if customer?
  end
end
