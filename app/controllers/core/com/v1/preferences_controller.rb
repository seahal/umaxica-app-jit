# frozen_string_literal: true

module Core
  module Com
    module V1
      class PreferencesController < ApplicationController
        include Preference::Edge

        def show
          render json: {
            preference: {
              id: @preferences.id,
              public_id: @preferences.public_id,
              expires_at: @preferences.expires_at,
            },
          }
        end
      end
    end
  end
end
