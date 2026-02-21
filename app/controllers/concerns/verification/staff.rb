# frozen_string_literal: true

module Verification
  module Staff
    extend ActiveSupport::Concern

    include Verification::Base

    private

    def actor_staff?
      true
    end
  end
end
