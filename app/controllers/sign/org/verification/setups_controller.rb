# frozen_string_literal: true

module Sign
  module Org
    module Verification
      class SetupsController < ApplicationController
        auth_required!

        before_action :authenticate_staff!

        def new
          @rd = params[:rd].to_s.presence
        end
      end
    end
  end
end
