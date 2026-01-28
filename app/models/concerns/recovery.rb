# frozen_string_literal: true

module Recovery
  extend ActiveSupport::Concern

  def recovery_enabled?
    false
  end

  def needs_recovery_setup?
    true
  end
end
