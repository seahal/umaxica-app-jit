# frozen_string_literal: true

module Core
  module Org
    module Configuration
      class EmailsController < Core::Org::ApplicationController
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
