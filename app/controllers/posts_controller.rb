# typed: false
# frozen_string_literal: true

class PostsController < ApplicationController
  def index
    @posts = Post.all

    if params[:q].present?
      # (A) Escape LIKE search: escape user input with sanitize_sql_like,
      # treating wildcards (% / _) as literal characters.
      escaped_q = ActiveRecord::Base.sanitize_sql_like(params[:q])
      @posts = @posts.where("body LIKE ?", "%#{escaped_q}%")
    end

    render json: @posts
  end
end
