# frozen_string_literal: true

module Core
  module Org
    module Edge
      module V1
        class PreferencesController < ApplicationController
          include Preference::Edge
        end
      end
    end
  end
end
