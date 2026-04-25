# typed: false
# frozen_string_literal: true

module Base
  module App
    module Configuration
      class EmailsController < Base::App::ApplicationController
        auth_required!

        def new
          render plain: "Core App Configuration Emails New"
        end

        def create
          head :ok
        end
      end
    end
  end
end
