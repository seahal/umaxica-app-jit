# typed: false
# frozen_string_literal: true

module Sign
  module Org
    class RootsController < ApplicationController
      guest_only! status: :unauthorized

      def index
      end
    end
  end
end
