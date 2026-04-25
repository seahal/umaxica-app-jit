# typed: false
# frozen_string_literal: true

module Jit
  module Distributor
    module Post
      module Org
        module Edge
          module V0
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

                render json: @posts
              end

              def show
                @post = {
                  id: params[:id],
                  title: "Internal Document #{params[:id]}",
                  body: "This is a placeholder internal document for #{params[:id]}.",
                  updated_at: Time.current,
                }

                Rails.event.notify(
                  "docs.post.viewed",
                  post_id: params[:id],
                )

                render json: @post
              end
            end
          end
        end
      end
    end
  end
end
