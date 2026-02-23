# typed: false
# frozen_string_literal: true

module Sign
  module Org
    class RootsController < ApplicationController
      before_action :reject_logged_in_session

      def index
      end
    end
  end
end
