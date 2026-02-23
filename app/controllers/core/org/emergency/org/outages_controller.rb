# typed: false
# frozen_string_literal: true

module Core
  module Org
    module Emergency
      module Org
        class OutagesController < Core::Org::ApplicationController
          def show
            render "core/org/emergency/org/outage/show"
          end

          def update
            redirect_to action: :show
          end
        end
      end
    end
  end
end
