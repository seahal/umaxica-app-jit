# frozen_string_literal: true

module Edge
  module V1
    class HealthsController < BaseController
      def show
        render json: { status: "OK" }, status: :ok
      end
    end
  end
end
