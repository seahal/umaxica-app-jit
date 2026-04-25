# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    module Base
      module Org
        module Emergency
          module Com
            class OutagesController < Jit::Foundation::Base::Org::ApplicationController
              def show
                render "base/org/emergency/com/outage/show"
              end

              def update
                redirect_to(action: :show)
              end
            end
          end
        end
      end
    end
  end
end
