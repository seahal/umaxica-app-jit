# frozen_string_literal: true

module Docs
  module Com
    class PostController < ApplicationController
      # GET /post?id=:permalink
      def show
        permalink = params[:id]

        # If no permalink specified, show default or empty state
        if permalink.blank?
          @documents = ComDocument.available
            .order(position: :asc, created_at: :desc)
            .limit(20)
          return
        end

        @document = ComDocument.available.find_by!(permalink: permalink)

        Rails.event.notify("docs.post.viewed",
                           document_id: @document.id,
                           permalink: @document.permalink,)

        # Handle different response modes
        case @document.response_mode
        when "redirect"
          redirect_to @document.redirect_url, allow_other_host: true
        when "pdf"
          # TODO: Implement PDF rendering
          render plain: "PDF rendering not implemented yet", status: :not_implemented
        when "text"
          render plain: @document.latest_version.body, content_type: "text/plain"
        else # html
          @version = @document.latest_version
        end
      rescue ActiveRecord::RecordNotFound
        Rails.event.notify("docs.post.not_found",
                           permalink: permalink,)
        raise
      end
    end
  end
end
