# frozen_string_literal: true

module Docs
  module App
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern
    end
  end
end
