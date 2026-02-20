# frozen_string_literal: true

module Sign
  module Org
    module Configuration
      class ApplicationController < Sign::Org::ApplicationController
        include ::Fuse

        auth_required!
      end
    end
  end
end
