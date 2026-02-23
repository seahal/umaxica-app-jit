# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Configuration
      class ApplicationController < Sign::Org::ApplicationController
        include ::Fuse
        include ::Finisher

        auth_required!
      end
    end
  end
end
