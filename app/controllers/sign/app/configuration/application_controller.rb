# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class ApplicationController < Sign::App::ApplicationController
        include ::Fuse
        include ::Finisher

        auth_required!
      end
    end
  end
end
