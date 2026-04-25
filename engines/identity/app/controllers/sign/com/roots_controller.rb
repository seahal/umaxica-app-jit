# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Com
        class RootsController < ApplicationController
          guest_only! status: :unauthorized

          def index
          end
        end
      end
    end
  end
end
