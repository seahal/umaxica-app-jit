# typed: false
# frozen_string_literal: true

module Base
  module Org
    module Configuration
      class EmailsController < Base::Org::ApplicationController
        auth_required!

        def new
          render plain: "Core Org Configuration Emails New"
        end

        def create
          head :ok
        end
      end
    end
  end
end
