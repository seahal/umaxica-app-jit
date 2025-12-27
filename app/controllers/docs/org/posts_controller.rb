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

        Rails.event.notify(
          "docs.posts.listed",
          posts_count: @posts.size,
        )
      end

      def show
        @post_id = params[:id]
        @post = {
          id: @post_id,
          title: "Internal Document #{@post_id}",
          body: "This is a placeholder internal document for #{@post_id}.",
          updated_at: Time.current,
        }

        Rails.event.notify(
          "docs.post.viewed",
          post_id: @post_id,
        )
      end
    end
  end
end
