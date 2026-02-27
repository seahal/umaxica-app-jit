# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class ApplicationController < Sign::App::ApplicationController
        auth_required!
      end
    end
  end
end
