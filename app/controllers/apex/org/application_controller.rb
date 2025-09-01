# frozen_string_literal: true

module Apex
  module Org
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      allow_browser versions: :modern
    end
  end
end
