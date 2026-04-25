# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Jit::Identity::Sign::Org
      class InsController < ApplicationController
        before_action :reject_logged_in_session

        def new
        end
      end
    end
  end
end
