# frozen_string_literal: true

module Docs
  module Com
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern
    end
  end
end
