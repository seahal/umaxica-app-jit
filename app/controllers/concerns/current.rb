# typed: false
# frozen_string_literal: true

module Current
  extend ActiveSupport::Concern

  class << self
    def preference
      Thread.current[:_current_preference] ||= Current::Preference::NULL
    end

    def preference=(value)
      Thread.current[:_current_preference] = value
    end

    def actor
      Thread.current[:_current_actor]
    end

    def actor=(value)
      Thread.current[:_current_actor] = value
    end

    def actor_type
      Thread.current[:_current_actor_type]
    end

    def actor_type=(value)
      Thread.current[:_current_actor_type] = value
    end

    def session
      Thread.current[:_current_session]
    end

    def session=(value)
      Thread.current[:_current_session] = value
    end

    def token
      Thread.current[:_current_token]
    end

    def token=(value)
      Thread.current[:_current_token] = value
    end

    def domain
      Thread.current[:_current_domain]
    end

    def domain=(value)
      Thread.current[:_current_domain] = value
    end

    def user?
      actor_type == :user
    end

    def staff?
      actor_type == :staff
    end

    def reset
      Thread.current[:_current_preference] = Current::Preference::NULL
      Thread.current[:_current_actor] = nil
      Thread.current[:_current_actor_type] = nil
      Thread.current[:_current_session] = nil
      Thread.current[:_current_token] = nil
      Thread.current[:_current_domain] = nil
    end
  end

  included do
    after_action :_reset_current_state
  end

  private

  def set_current
  end

  def _reset_current_state
    Current.reset
  end
end
