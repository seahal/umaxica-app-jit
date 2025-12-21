# frozen_string_literal: true

module Auth
  module App
    module Setting
      class SessionsController < ApplicationController
        before_action :authenticate_user!
        before_action :load_sessions
        before_action :set_session, only: %i[show edit update destroy]

        def index
          render json: { sessions: @sessions }
        end

        def show
          render json: { session: @session }
        end

        def new
          render json: { session: default_session_payload }
        end

        def edit
          render json: { session: @session }
        end

        def create
          session_record = default_session_payload.merge(session_params.stringify_keys).merge("id" => SecureRandom.uuid)
          @sessions << session_record
          persist_sessions!

          render json: { session: session_record }, status: :created
        end

        def update
          @session.merge!(session_params.stringify_keys)
          persist_sessions!

          render json: { session: @session }
        end

        def destroy
          @sessions.delete_if { |record| record["id"] == @session["id"] }
          persist_sessions!

          head :see_other
        end

        private

          def load_sessions
          session[:app_setting_sessions] ||= []
          @sessions = session[:app_setting_sessions].map { |record| record.stringify_keys }
          end

          def set_session
          @session = @sessions.find { |record| record["id"] == params[:id] }
            return if @session

            head :not_found
            nil
          end

          def session_params
            params.fetch(:session, {}).permit(:name, :status).to_h.symbolize_keys
          end

          def persist_sessions!
            session[:app_setting_sessions] = @sessions
          end

          def default_session_payload
          { "name" => "Connected app", "status" => "active" }
          end
      end
    end
  end
end
