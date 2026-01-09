# frozen_string_literal: true

module Core
  module Com
    module V1
      class PreferencesController < ApplicationController
        include Preference::Edge
      end
    end
  end
end
