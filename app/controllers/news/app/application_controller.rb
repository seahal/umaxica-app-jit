# frozen_string_literal: true

module News
  module App
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern
    end
  end
end
