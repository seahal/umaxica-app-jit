# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class ApplicationController < Sign::App::ApplicationController
        include RestrictedSessionGuard

        auth_required!
      end
    end
  end
end
