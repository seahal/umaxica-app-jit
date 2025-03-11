# frozen_string_literal: true


module Www
  module App
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern
    end
  end
end
