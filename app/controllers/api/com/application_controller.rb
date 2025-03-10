# frozen_string_literal: true


module Api
  module Com
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern
    end
  end
end
