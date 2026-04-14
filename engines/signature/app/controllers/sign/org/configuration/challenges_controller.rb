# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Configuration
      class ChallengesController < ApplicationController
        auth_required!

        include ::Verification::Staff

        before_action :authenticate_staff!

        def show
          @user = current_staff
        end

        def update
        end

        private

        def verification_required_action?
          action_name == "update"
        end

        def verification_scope
          "configuration_mfa"
        end
      end
    end
  end
end
