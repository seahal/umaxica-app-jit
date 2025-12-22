# NOTE: If this code is only included in User controllers, consider moving to app/controllers/concerns/authentication/user.rb

module Authorization
  module User
    include Authorization::Base
    extend ActiveSupport::Concern

    included do
      helper_method :active_user?
    end

    def active_user?
      current_user.present? && current_user.active?
    end

    def am_i_user?
      true
    end

    def am_i_staff?
      false
    end

    def am_i_owner?
      # TODO: Implement owner check logic for user
      false
    end
  end
end
