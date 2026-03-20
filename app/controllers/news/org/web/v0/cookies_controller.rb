# typed: false
# frozen_string_literal: true

module News
  module Org
    module Web
      module V0
        class CookiesController < ApplicationController
          include ::Preference::WebCookieActions
        end
      end
    end
  end
end
