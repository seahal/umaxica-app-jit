# frozen_string_literal: true

module Authorization
  module Base
    extend ActiveSupport::Concern

    included do
      # Add any instance methods or callbacks here
    end

    def active?
      raise NotImplementedError, "active? must be implemented in including module"
    end

    # RBAC / ABAC placeholders
    def am_i_user?
      raise NotImplementedError, "am_i_user? must be implemented in including module"
    end

    def am_i_staff?
      raise NotImplementedError, "am_i_staff? must be implemented in including module"
    end

    def am_i_owner?
      raise NotImplementedError, "am_i_owner? must be implemented in including module"
    end
  end
end
