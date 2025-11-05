# frozen_string_literal: true

module Bff
  module Org
    class ApplicationController < ActionController::Base
      include Pundit::Authorization

      allow_browser versions: :modern
    end
  end
end
