# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Org
        module Configuration
          class WithdrawalsController < ApplicationController
            auth_required!

            include ::Verification::Staff

            before_action :authenticate_staff!

            def show
            end

            private

            def verification_required_action?
              true
            end

            def verification_scope
              "withdrawal"
            end
          end
        end
      end
    end
  end
end
