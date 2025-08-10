# frozen_string_literal: true

module Apex
  module Com
    class HealthsController < ApplicationController
      def show
        @health_status = {
          status: "healthy",
          timestamp: Time.current,
          version: "1.0.0",
          environment: Rails.env,
          services: {
            database: check_database,
            cache: check_cache,
            external_apis: check_external_services
          }
        }
        
        render json: @health_status, status: overall_status
      end

      private

      def check_database
        ActiveRecord::Base.connection.execute("SELECT 1")
        "ok"
      rescue => e
        "error: #{e.message}"
      end

      def check_cache
        Rails.cache.write("health_check", "ok", expires_in: 1.minute)
        Rails.cache.read("health_check") == "ok" ? "ok" : "error"
      rescue => e
        "error: #{e.message}"
      end

      def check_external_services
        # Simulate external service checks
        "ok"
      end

      def overall_status
        @health_status[:services].values.all? { |status| status == "ok" } ? :ok : :service_unavailable
      end
    end
  end
end
