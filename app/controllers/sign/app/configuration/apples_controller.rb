# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class ApplesController < ApplicationController
        before_action :authenticate_user!

        def show
        end
      end
    end
  end
end
