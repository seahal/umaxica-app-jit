# frozen_string_literal: true

module News
  module App
    class PostsController < ApplicationController
      def index
        @posts = [
          { id: 1, title: "Product Update", published_at: 2.days.ago },
          { id: 2, title: "Release Notes", published_at: 1.day.ago },
          { id: 3, title: "Community Spotlight", published_at: Time.current },
        ]

        Rails.event.notify("news.posts.listed",
                           posts_count: @posts.size,)
      end

      def show
        @post_id = params[:id]
        @post = {
          id: @post_id,
          title: "News Post #{@post_id}",
          body: "This is a placeholder news post for #{@post_id}.",
          published_at: Time.current,
        }

        Rails.event.notify("news.post.viewed",
                           post_id: @post_id,)
      end

      def new
        @post = { title: "", body: "" }
      end

      def edit
        @post_id = params[:id]
        @post = { id: @post_id, title: "News Post #{@post_id}", body: "" }
      end

      def create
        Rails.event.notify("news.post.created",
                           title: params.dig(:post, :title),)

        redirect_to news_app_posts_path
      end

      def update
        @post_id = params[:id]
        Rails.event.notify("news.post.updated",
                           post_id: @post_id,)

        redirect_to news_app_post_path(@post_id)
      end

      def destroy
        @post_id = params[:id]
        Rails.event.notify("news.post.deleted",
                           post_id: @post_id,)

        redirect_to news_app_posts_path
      end
    end
  end
end
