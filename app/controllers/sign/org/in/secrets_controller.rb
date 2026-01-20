# frozen_string_literal: true

module Sign
  module Org
    module In
      class SecretsController < ApplicationController
        before_action :reject_logged_in_session

        def new
        end

        def create
        end
      end
    end
  end
end
