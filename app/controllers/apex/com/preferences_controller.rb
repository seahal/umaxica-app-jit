# typed: false
# frozen_string_literal: true

module Apex
  module Com
    class PreferencesController < ApplicationController
      def show
        @preferences = ::ComPreference.new
      end
    end
  end
end
