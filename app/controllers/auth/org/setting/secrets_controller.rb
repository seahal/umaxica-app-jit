# frozen_string_literal: true

module Auth
  module Org
    module Setting
      class SecretsController < ApplicationController
        before_action :authenticate_staff!
        before_action :load_secrets
        before_action :set_secret, only: %i[show edit update destroy]

        def index
          render json: { secrets: @secrets }
        end

        def show
          render json: { secret: @secret }
        end

        def new
          render json: { secret: default_secret_payload }
        end

        def edit
          render json: { secret: @secret }
        end

        def create
          secret_record = default_secret_payload.merge(secret_params).merge(id: SecureRandom.uuid)
          @secrets << secret_record
          persist_secrets!

          render json: { secret: secret_record }, status: :created
        end

        def update
          @secret.merge!(secret_params)
          persist_secrets!

          render json: { secret: @secret }
        end

        def destroy
          @secrets.delete_if { |record| record[:id] == @secret[:id] }
          persist_secrets!

          head :see_other
        end

        private

          def load_secrets
            session[:org_setting_secrets] ||= []
            @secrets = session[:org_setting_secrets]
          end

          def set_secret
            @secret = @secrets.find { |record| record[:id] == params[:id] }
            return if @secret

            head :not_found
            nil
          end

          def secret_params
            params.fetch(:secret, {}).permit(:name, :value).to_h.symbolize_keys
          end

          def persist_secrets!
            session[:org_setting_secrets] = @secrets
          end

          def default_secret_payload
            { name: "Secret", value: "[redacted]" }
          end
      end
    end
  end
end
