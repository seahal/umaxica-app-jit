# frozen_string_literal: true

module Sign
  module Org
    module Preference
      class CookiesController < ApplicationController
        include ::Cookie
      end
    end
  end
end
