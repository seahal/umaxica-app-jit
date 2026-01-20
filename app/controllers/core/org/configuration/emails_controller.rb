# frozen_string_literal: true

module Core
  module Org
    module Configuration
      class EmailsController < Core::Org::ApplicationController
        prepend_before_action :authenticate_staff!

        def new
          render plain: "Core Org Configuration Emails New"
        end
      end
    end
  end
end
