# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class GooglesController < ApplicationController
        before_action :authenticate_user!

        def show
        end
      end
    end
  end
end
