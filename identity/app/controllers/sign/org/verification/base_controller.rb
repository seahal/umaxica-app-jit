# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Verification
      class BaseController < Sign::Org::ApplicationController
        auth_required!

        include Sign::OrgVerificationBase

        activate_org_verification_base
      end
    end
  end
end
