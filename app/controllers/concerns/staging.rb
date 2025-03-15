# frozen_string_literal: true

module Staging
  extend ActiveSupport::Concern

  def show
    if ENV["STAGING"].blank? && Rails.env.production?
      raise ActionController::RoutingError, "Page not found when run on production"
    end

    @git_hash = ENV.fetch("COMMIT_HASH", nil) || ""
  end
end
