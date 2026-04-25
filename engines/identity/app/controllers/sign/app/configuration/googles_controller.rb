# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module App
        module Configuration
          class GooglesController < ApplicationController
            auth_required!

            include ::Verification::User

            before_action :authenticate_user!

            def show
            end
          end
        end
      end
    end
  end
end
