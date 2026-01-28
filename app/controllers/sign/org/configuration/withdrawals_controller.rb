# frozen_string_literal: true

module Sign
  module Org
    module Configuration
      class WithdrawalsController < ApplicationController
        before_action :authenticate_staff!

        def show
        end
      end
    end
  end
end
