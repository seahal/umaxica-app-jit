# frozen_string_literal: true

class Client
  module V1
    class HealthsController < BaseController
      def show
        render json: { status: "OK" }, status: :ok
      end
    end
  end
end
