# typed: false
# frozen_string_literal: true

module Core
  module Org
    module Edge
      module V0
        class PreferencesController < ApplicationController
          include ::Preference::Edge
        end
      end
    end
  end
end
