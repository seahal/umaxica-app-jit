# frozen_string_literal: true

module Docs
  module Org
    class PostsController < ApplicationController
      def index
        @posts = [
          { id: 1, title: "Internal Handbook", updated_at: 2.days.ago },
          { id: 2, title: "Ops Runbook", updated_at: 1.day.ago },
          { id: 3, title: "Security Notes", updated_at: Time.current },
        ]

        Rails.event.notify("docs.posts.listed",
                           posts_count: @posts.size,)
      end

      def show
        @post_id = params[:id]
        @post = {
          id: @post_id,
          title: "Internal Document #{@post_id}",
          body: "This is a placeholder internal document for #{@post_id}.",
          updated_at: Time.current,
        }

        Rails.event.notify("docs.post.viewed",
                           post_id: @post_id,)
      end

      def new
        @post = { title: "", body: "" }
      end

      def edit
        @post_id = params[:id]
        @post = { id: @post_id, title: "Internal Document #{@post_id}", body: "" }
      end

      def create
        Rails.event.notify("docs.post.created",
                           title: params.dig(:post, :title),)

        redirect_to docs_org_posts_path
      end

      def update
        @post_id = params[:id]
        Rails.event.notify("docs.post.updated",
                           post_id: @post_id,)

        redirect_to docs_org_post_path(@post_id)
      end

      def destroy
        @post_id = params[:id]
        Rails.event.notify("docs.post.deleted",
                           post_id: @post_id,)

        redirect_to docs_org_posts_path
      end
    end
  end
end
