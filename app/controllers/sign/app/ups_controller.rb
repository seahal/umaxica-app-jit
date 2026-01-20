# frozen_string_literal: true

module Sign
  module App
    class UpsController < ApplicationController
      guest_only! status: :unauthorized, message: "権限がありません"

      def new
      end
    end
  end
end
