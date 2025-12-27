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

        Rails.event.notify(
          "news.posts.listed",
          posts_count: @posts.size,
        )
      end

      def show
        @post_id = params[:id]
        @post = {
          id: @post_id,
          title: "News Post #{@post_id}",
          body: "This is a placeholder news post for #{@post_id}.",
          published_at: Time.current,
        }

        Rails.event.notify(
          "news.post.viewed",
          post_id: @post_id,
        )
      end
    end
  end
end
