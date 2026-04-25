# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    module Base
      module Org
        module Emergency
          module Org
            class TokensController < Jit::Foundation::Base::Org::ApplicationController
              def show
                render "base/org/emergency/org/token/show"
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
