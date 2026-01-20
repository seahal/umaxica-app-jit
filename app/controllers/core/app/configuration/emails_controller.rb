# frozen_string_literal: true

module Core
  module App
    module Configuration
      class EmailsController < Core::App::ApplicationController
        prepend_before_action :authenticate_user!

        def new
          render plain: "Core App Configuration Emails New"
        end
      end
    end
  end
end
