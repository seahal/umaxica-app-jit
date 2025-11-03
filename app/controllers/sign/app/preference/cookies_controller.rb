# frozen_string_literal: true

module Sign
  module App
    module Preference
      class CookiesController < ApplicationController
        include ::Cookie
      end
    end
  end
end
