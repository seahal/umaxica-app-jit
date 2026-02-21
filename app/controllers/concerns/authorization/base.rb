# frozen_string_literal: true

module Authorization
  module Base
    extend ActiveSupport::Concern

    included do
      before_action :enforce_access_policy! if respond_to?(:before_action)
    end

    private

    # TBC: Pundit migration lands later.
    def authorize_request!
      true
    end
  end
end
