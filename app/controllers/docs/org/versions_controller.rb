# frozen_string_literal: true

module Docs
  module Org
    class VersionsController < ApplicationController
      # GET /posts/:post_id/versions
      def index
        @post_id = params[:post_id]
        @versions = [
          { id: 1, version: "1.0.0", created_at: 2.days.ago },
          { id: 2, version: "1.1.0", created_at: 1.day.ago },
          { id: 3, version: "1.2.0", created_at: Time.current },
        ]

        Rails.event.notify(
          "docs.versions.listed",
          post_id: @post_id,
          versions_count: @versions.size,
        )

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

        Rails.event.notify(
          "docs.version.viewed",
          post_id: @post_id,
          version_id: @version_id,
        )

        respond_to do |format|
          format.html
          format.json { render json: @version }
        end
      end

      # GET /posts/:post_id/versions/new
      def new
        @post_id = params[:post_id]
        @version = { version: "", body: "" }
      end

      # GET /posts/:post_id/versions/:id/edit
      def edit
        @post_id = params[:post_id]
        @version_id = params[:id]
        @version = { id: @version_id, version: "1.0.0", body: "" }
      end

      # POST /posts/:post_id/versions
      def create
        @post_id = params[:post_id]
        Rails.event.notify(
          "docs.version.created",
          post_id: @post_id,
        )

        safe_post_id = safe_segment(@post_id)
        redirect_to docs_org_post_versions_path(safe_post_id)
      end

      # PATCH/PUT /posts/:post_id/versions/:id
      def update
        @post_id = params[:post_id]
        @version_id = params[:id]
        Rails.event.notify(
          "docs.version.updated",
          post_id: @post_id,
          version_id: @version_id,
        )

        safe_post_id = safe_segment(@post_id)
        safe_version_id = safe_segment(@version_id)
        redirect_to docs_org_post_version_path(safe_post_id, safe_version_id)
      end

      # DELETE /posts/:post_id/versions/:id
      def destroy
        @post_id = params[:post_id]
        @version_id = params[:id]
        Rails.event.notify(
          "docs.version.deleted",
          post_id: @post_id,
          version_id: @version_id,
        )

        safe_post_id = safe_segment(@post_id)
        redirect_to docs_org_post_versions_path(safe_post_id)
      end

      private

      def safe_segment(value)
        value.to_s.gsub(/[^0-9A-Za-z_-]/, "")
      end
    end
  end
end
