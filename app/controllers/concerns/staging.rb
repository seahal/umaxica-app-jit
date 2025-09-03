# frozen_string_literal: true

module Staging
  extend ActiveSupport::Concern

  def show
    expires_in 1.second, public: true # this page wouldn't include private data

    # Check if this is an API controller (no respond_to method available)
    if self.class.ancestors.include?(ActionController::API)
      # API controllers only return JSON - reject HTML requests
      if request.format.html?
        head :not_acceptable
        return
      end

      # API controllers only return JSON
      if ENV["STAGING"].blank? && Rails.env.production?
        render status: :ok, json: { staging: true }
      else
        render status: :ok, json: { staging: false, id: ENV.fetch("COMMIT_HASH", nil) || "" }
      end
    else
      # Web controllers can respond to multiple formats
      if ENV["STAGING"].blank? && Rails.env.production?
        respond_to do |format|
          format.html { @git_hash = "" }
          format.json { render status: :ok, json: { staging: true } }
        end
      else
        respond_to do |format|
          format.html { @git_hash = ENV.fetch("COMMIT_HASH", nil) }
          format.json { render status: :ok, json: { staging: false, id: ENV.fetch("COMMIT_HASH", nil) || "" } }
        end
      end
    end
  end
end
