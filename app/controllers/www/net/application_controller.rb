# frozen_string_literal: true


module Www
  module Net
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern
    end
  end
end
