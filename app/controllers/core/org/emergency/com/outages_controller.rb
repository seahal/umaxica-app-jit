# typed: false
# frozen_string_literal: true

module Core
  module Org
    module Emergency
      module Com
        class OutagesController < Core::Org::ApplicationController
          def show
            render "core/org/emergency/com/outage/show"
          end

          def update
            redirect_to action: :show
          end
        end
      end
    end
  end
end
