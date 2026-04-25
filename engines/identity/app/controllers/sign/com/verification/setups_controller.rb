# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Com
        module Verification
          class SetupsController < Jit::Identity::Sign::Com::ApplicationController
            auth_required!

            before_action :authenticate_customer!

            def new
              @rd = params[:rd].to_s.presence
            end
          end
        end
      end
    end
  end
end
