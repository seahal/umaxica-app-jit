# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Org
        module Verification
          class BaseController < Jit::Identity::Sign::Org::ApplicationController
            auth_required!

            include Jit::Identity::Sign::OrgVerificationBase

            activate_org_verification_base
          end
        end
      end
    end
  end
end
