# frozen_string_literal: true

module Docs
  module App
    class VersionsController < ApplicationController
      # GET /posts/:post_id/versions
      def index
        @post_id = params[:post_id]
        @versions = [
          { id: 1, version: "1.0.0", created_at: 2.days.ago },
          { id: 2, version: "1.1.0", created_at: 1.day.ago },
          { id: 3, version: "1.2.0", created_at: Time.current },
        ]

        Rails.event.notify("docs.versions.listed",
                           post_id: @post_id,
                           versions_count: @versions.size,)

        respond_to do |format|
          format.html
          format.json { render json: @versions }
        end
      end

      # GET /posts/:post_id/versions/:id
      def show
        @post_id = params[:post_id]
        @version_id = params[:id]
        @version = {
          id: @version_id,
          version: "1.#{@version_id}.0",
          title: "Sample Document Version #{@version_id}",
          body: "This is the content of version #{@version_id}",
          created_at: Time.current,
        }

        Rails.event.notify("docs.version.viewed",
                           post_id: @post_id,
                           version_id: @version_id,)

        respond_to do |format|
          format.html
          format.json { render json: @version }
        end
      end
    end
  end
end
