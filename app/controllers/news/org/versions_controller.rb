# frozen_string_literal: true

module News
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
          "news.versions.listed",
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
          title: "Sample News Version #{@version_id}",
          body: "This is the content of version #{@version_id}",
          created_at: Time.current,
        }

        Rails.event.notify(
          "news.version.viewed",
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
          "news.version.created",
          post_id: @post_id,
        )

        redirect_to news_org_post_versions_path(@post_id)
      end

      # PATCH/PUT /posts/:post_id/versions/:id
      def update
        @post_id = params[:post_id]
        @version_id = params[:id]
        Rails.event.notify(
          "news.version.updated",
          post_id: @post_id,
          version_id: @version_id,
        )

        redirect_to news_org_post_version_path(@post_id, @version_id)
      end

      # DELETE /posts/:post_id/versions/:id
      def destroy
        @post_id = params[:post_id]
        @version_id = params[:id]
        Rails.event.notify(
          "news.version.deleted",
          post_id: @post_id,
          version_id: @version_id,
        )

        redirect_to news_org_post_versions_path(@post_id)
      end
    end
  end
end
