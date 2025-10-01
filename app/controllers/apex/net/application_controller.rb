# frozen_string_literal: true

module Apex
  module Net
    class ApplicationController < ActionController::Base
      include ::RateLimit

      allow_browser versions: :modern
    end
  end
end
