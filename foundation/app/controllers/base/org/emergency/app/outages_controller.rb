# typed: false
# frozen_string_literal: true

module Base
  module Org
    module Emergency
      module App
        class OutagesController < Base::Org::ApplicationController
          def show
            render "base/org/emergency/app/outage/show"
          end

          def update
            redirect_to(action: :show)
          end
        end
      end
    end
  end
end
