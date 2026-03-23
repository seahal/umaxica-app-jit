# typed: false
# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :actor, :actor_type, :session, :token, :domain, :preference

  resets { self.preference = Current::Preference::NULL }

  def self.preference
    super || Current::Preference::NULL
  end

  def self.user?
    actor_type == :user
  end

  def self.staff?
    actor_type == :staff
  end

  def self.user
    actor if user?
  end

  def self.staff
    actor if staff?
  end
end
