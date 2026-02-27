# typed: false
# frozen_string_literal: true

module Auth
  module VerificationEnforcer
    extend ActiveSupport::Concern

    include ::Verification::Base
  end
end
