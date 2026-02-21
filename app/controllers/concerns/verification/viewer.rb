# frozen_string_literal: true

module Verification
  module Viewer
    extend ActiveSupport::Concern

    class UnsupportedActor < StandardError; end

    include Verification::Base

    private

    def enforce_verification_if_required
      return true unless verification_required?

      raise UnsupportedActor, "Verification is not supported for viewer actor"
    end
  end
end
