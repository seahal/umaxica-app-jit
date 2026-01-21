# frozen_string_literal: true

module Sign
  module App
    module In
      class PasskeysController < ApplicationController
        before_action :reject_logged_in_session

        def new
        end
      end
    end
  end
end
