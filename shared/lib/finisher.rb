# typed: false
# frozen_string_literal: true

module Finisher
  extend ActiveSupport::Concern

  def purge_current
    Current.reset
  end

  private

  def finish_request
    # no-op
  rescue StandardError => e
    Rails.event.warn("finisher.purge_failed", error_class: e.class.name, message: e.message)
  end
end
