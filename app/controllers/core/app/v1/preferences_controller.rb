# frozen_string_literal: true

module Core
  module App
    module V1
      class PreferencesController < ApplicationController
        include Preference::Edge
      end
    end
  end
end
