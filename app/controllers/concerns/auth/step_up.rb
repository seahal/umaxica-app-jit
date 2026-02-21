# frozen_string_literal: true

module Auth
  module StepUp
    extend ActiveSupport::Concern

    include ::Verification::Base
  end
end
