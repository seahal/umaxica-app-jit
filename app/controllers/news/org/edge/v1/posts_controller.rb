# frozen_string_literal: true

module News
  module Org
    module Edge
      module V1
        class PostsController < ApplicationController
          def index
            @posts = [
              { id: 1, title: "Staff Bulletin", published_at: 2.days.ago },
              { id: 2, title: "Operational Update", published_at: 1.day.ago },
              { id: 3, title: "Internal Note", published_at: Time.current },
            ]

            Rails.event.notify(
              "news.posts.listed",
              posts_count: @posts.size,
            )

            render json: @posts
          end

          def show
            @post_id = params[:id]
            @post = {
              id: @post_id,
              title: "Staff News #{@post_id}",
              body: "This is a placeholder staff news post for #{@post_id}.",
              published_at: Time.current,
            }

            Rails.event.notify(
              "news.post.viewed",
              post_id: @post_id,
            )

            render json: @post
          end
        end
      end
    end
  end
end
