# frozen_string_literal: true

# NOTE: If this code is only included in Staff controllers, consider moving to
# app/controllers/concerns/authentication/staff.rb

module Authorization
  module Staff
    include Authorization::Base
    extend ActiveSupport::Concern

    included do
      helper_method :active_staff?
    end

    def active_staff?
      current_staff.present? && current_staff.active?
    end

    def am_i_user?
      false
    end

    def am_i_staff?
      true
    end

    def am_i_owner?
      # TODO: Implement owner check logic for staff
      false
    end
  end
end
