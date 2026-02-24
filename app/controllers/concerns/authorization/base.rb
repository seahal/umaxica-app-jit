# typed: false
# frozen_string_literal: true

module Authorization
  module Base
    extend ActiveSupport::Concern

    private

    # TBC: Pundit migration lands later.
    def authorize_request!
      true
    end
  end
end
