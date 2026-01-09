# frozen_string_literal: true

module Core
  module Org
    module V1
      class PreferencesController < ApplicationController
        include Preference::Edge
      end
    end
  end
end
