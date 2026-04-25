# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    module Base
      module Com
        module Edge
          module V0
            class MessagesController < ApplicationController
              include ::Foundation::Edge::V0::MessagesEndpoint

              before_action :ensure_json_request
              before_action :set_message_id, only: %i(show update destroy)

              def index
                render json: { data: [], meta: { resource: "messages" } }, status: :ok
              end

              def show
                render json: { data: message_payload(@message_id) }, status: :ok
              end

              def create
                render json: { data: message_payload(SecureRandom.uuid), meta: { persisted: false } }, status: :created
              end

              def update
                render json: { data: message_payload(@message_id) }, status: :ok
              end

              def destroy
                render json: { data: { id: @message_id, type: "message", deleted: true } }, status: :ok
              end
            end
          end
        end
      end
    end
  end
end
