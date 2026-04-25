# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    module Base
      module Org
        module Configuration
          class EmailsController < Jit::Foundation::Base::Org::ApplicationController
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
  end
end
