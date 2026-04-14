# typed: false
# frozen_string_literal: true

module Core
  module Org
    module Emergency
      module Org
        class TokensController < Core::Org::ApplicationController
          def show
            render "core/org/emergency/org/token/show"
          end

          def update
            redirect_to(action: :show)
          end
        end
      end
    end
  end
end
