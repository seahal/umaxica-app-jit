# frozen_string_literal: true

module Staging
  extend ActiveSupport::Concern

  def show
    expires_in 1.second, public: true # this page wouldn't include private data

    if ENV["STAGING"].blank? && Rails.env.production?
      respond_to do |format|
        format.html { @git_hash = "" }
        format.json { render status: 200, json: { staging: true } }
      end
    else
      respond_to do |format|
        format.html { @git_hash = ENV.fetch("COMMIT_HASH", nil) }
        format.json { render status: 200, json: { staging: false, id: ENV.fetch("COMMIT_HASH", nil) || "" } }
      end
    end
  end
end
