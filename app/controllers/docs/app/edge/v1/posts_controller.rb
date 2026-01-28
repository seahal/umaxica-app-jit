# frozen_string_literal: true

module Docs
  module App
    module Edge
      module V1
        class PostsController < ApplicationController
          def index
            @posts = [
              { id: 1, title: "Getting Started", updated_at: 2.days.ago },
              { id: 2, title: "API Reference", updated_at: 1.day.ago },
              { id: 3, title: "FAQ", updated_at: Time.current }
            ]

            Rails.event.notify(
              "docs.posts.listed",
              posts_count: @posts.size,
            )

            render json: @posts
          end

          def show
            @post_id = params[:id]
            @post = {
              id: @post_id,
              title: "Sample Document #{@post_id}",
              body: "This is a placeholder document for #{@post_id}.",
              updated_at: Time.current
            }

            Rails.event.notify(
              "docs.post.viewed",
              post_id: @post_id,
            )

            render json: @post
          end
        end
      end
    end
  end
end
