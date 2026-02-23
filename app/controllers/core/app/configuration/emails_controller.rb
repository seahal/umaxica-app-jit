# typed: false
# frozen_string_literal: true

module Core
  module App
    module Configuration
      class EmailsController < Core::App::ApplicationController
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
