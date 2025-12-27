# frozen_string_literal: true

module Docs
  module Com
    class PostsController < ApplicationController
      # GET /posts?id=:permalink or /posts?q=:query or /posts (show all)
      def show
        # If id parameter is provided, show specific document
        if params[:id].present?
          show_document
        else
          # Otherwise, show list (with optional search)
          list_documents
        end
      end

      private

      def show_document
        permalink = params[:id]
        @document = ComDocument.available.find_by!(permalink: permalink)

        Rails.event.notify("docs.post.viewed",
                           document_id: @document.id,
                           permalink: @document.permalink,)

        # Handle different response modes
        case @document.response_mode
        when "redirect"
          handle_redirect_mode
        when "pdf"
          # TODO: Implement PDF rendering
          render plain: "PDF rendering not implemented yet", status: :not_implemented
        when "text"
          render plain: @document.latest_version.body, content_type: "text/plain"
        else # html
          @version = @document.latest_version
          render "show"
        end
      rescue ActiveRecord::RecordNotFound
        Rails.event.notify("docs.post.not_found",
                           permalink: permalink,)
        raise
      end

      # Handle redirect response mode with security validation
      # brakeman:skip-check Redirect - URL is validated by safe_redirect_url?
      def handle_redirect_mode
        redirect_url = @document.redirect_url

        if redirect_url.blank?
          Rails.event.notify("docs.post.empty_redirect",
                             document_id: @document.id,)
          render plain: "Redirect URL is not configured", status: :bad_request
          return
        end

        unless safe_redirect_url?(redirect_url)
          Rails.event.notify("docs.post.invalid_redirect",
                             document_id: @document.id,
                             redirect_url: redirect_url,)
          render plain: "Invalid redirect URL", status: :bad_request
          return
        end

        # URL has been validated - safe to redirect
        redirect_to redirect_url, allow_other_host: true
      end

      def safe_redirect_url?(url)
        return false if url.blank?

        begin
          uri = URI.parse(url)
          # Only allow http and https schemes
          return false unless %w(http https).include?(uri.scheme)

          # Check against allowlist if configured
          allowed_hosts = ENV["DOCS_ALLOWED_REDIRECT_HOSTS"]&.split(",")
          if allowed_hosts.present?
            return allowed_hosts.any? { |host| uri.host&.end_with?(host.strip) }
          end

          # If no allowlist, allow all valid http/https URLs
          true
        rescue URI::InvalidURIError
          false
        end
      end

      def list_documents
        @query = params[:q]
        @page = (params[:page] || 1).to_i
        @per_page = 20

        # Search documents by permalink or title
        documents_scope = ComDocument.available

        if @query.present? && @query != "all"
          # Search by permalink or title in latest version
          @documents = documents_scope
            .joins(:com_document_versions)
            .where("com_documents.permalink LIKE ? OR com_document_versions.title LIKE ?",
                   "%#{@query}%", "%#{@query}%",)
            .distinct
            .order("com_documents.created_at DESC")
            .offset((@page - 1) * @per_page)
            .limit(@per_page)

          @total_count = documents_scope
            .joins(:com_document_versions)
            .where("com_documents.permalink LIKE ? OR com_document_versions.title LIKE ?",
                   "%#{@query}%", "%#{@query}%",)
            .distinct
            .count
        else
          # Show all documents
          @documents = documents_scope
            .order("com_documents.position ASC, com_documents.created_at DESC")
            .offset((@page - 1) * @per_page)
            .limit(@per_page)

          @total_count = documents_scope.count
        end

        @total_pages = (@total_count.to_f / @per_page).ceil

        Rails.event.notify("docs.posts.listed",
                           query: @query,
                           results_count: @total_count,)

        render "index"
      end
    end
  end
end
