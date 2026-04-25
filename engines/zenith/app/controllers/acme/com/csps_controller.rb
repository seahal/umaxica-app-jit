# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    module Acme
      module Com
        class CspsController < ApplicationController
          include ::CspViolationReporting

          skip_before_action :canonicalize_query_params, raise: false
          skip_before_action :set_region, raise: false
          public_strict!

          def create
            create_csp_violation_report
          end
        end
      end
    end
  end
end
