# typed: false
# frozen_string_literal: true

module Core
  module Org
    module Emergency
      module App
        class OutagesController < Core::Org::ApplicationController
          def show
            render "core/org/emergency/app/outage/show"
          end

          def update
            redirect_to(action: :show)
          end
        end
      end
    end
  end
end
