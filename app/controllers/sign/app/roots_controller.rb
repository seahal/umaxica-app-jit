# frozen_string_literal: true

module Sign
  module App
    class RootsController < ApplicationController
      guest_only! status: :unauthorized, message: "権限がありません"

      def index
      end
    end
  end
end
