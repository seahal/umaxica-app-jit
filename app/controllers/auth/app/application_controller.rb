# frozen_string_literal: true

module Auth
  module App
    class ApplicationController < ActionController::Base
      include ::Authn
      include Pundit::Authorization

      allow_browser versions: :modern
    end
  end
end
