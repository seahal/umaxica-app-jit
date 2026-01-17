# frozen_string_literal: true

module Core
  module App
    module Edge
      module V1
        class PreferencesController < ApplicationController
          include Preference::Edge
        end
      end
    end
  end
end
