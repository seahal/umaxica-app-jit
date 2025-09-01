# frozen_string_literal: true

module Help
  module Org
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern
    end
  end
end
