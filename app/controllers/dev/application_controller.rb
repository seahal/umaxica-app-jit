# frozen_string_literal: true

module Dev
  class ApplicationController < ActionController::Base
    allow_browser versions: :modern
  end
end
