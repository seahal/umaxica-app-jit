# frozen_string_literal: true

module Core
  module Org
    module Emergency
      module App
        class TokensController < Core::Org::ApplicationController
          def show
            render "core/org/emergency/app/token/show"
          end

          def update
            redirect_to action: :show
          end
        end
      end
    end
  end
end
