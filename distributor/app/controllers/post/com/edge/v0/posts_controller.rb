# typed: false
# frozen_string_literal: true

module Post
  module Com
    module Edge
      module V0
        class PostsController < ApplicationController
          # GET /posts?q=:query or /posts (show all)
          def index
            list_documents
          end

          # GET /posts/:id
          def show
            show_document
          end

          private

          def show_document
            permalink = params[:id]
            @document = ComDocument.available.find_by!(permalink: permalink)
            @version = @document.latest_version

            Rails.event.notify(
              "docs.post.viewed",
              document_id: @document.id,
              permalink: @document.permalink,
            )

            render json: { document: @document, version: @version }
          rescue ActiveRecord::RecordNotFound
            Rails.event.notify(
              "docs.post.not_found",
              permalink: permalink,
            )
            render json: { error: "not_found" }, status: :not_found
          end

          def list_documents
            @query = params[:q]
            @page = Integer((params[:page] || 1).to_s, 10)
            @per_page = 20

            # Search documents by permalink or title
            documents_scope = ComDocument.available

            if @query.present? && @query != "all"
              # Search by permalink or title in latest version
              # Sanitize the query to prevent SQL injection via LIKE special characters
              sanitized_query = ActiveRecord::Base.sanitize_sql_like(@query)
              like_pattern = "%#{sanitized_query}%"

              @documents = documents_scope
                .joins(:com_document_versions)
                .where("com_documents.permalink LIKE ? OR com_document_versions.title LIKE ?",
                       like_pattern, like_pattern,)
                .distinct
                .order("com_documents.created_at DESC")
                .offset((@page - 1) * @per_page)
                .limit(@per_page)

              @total_count = documents_scope
                .joins(:com_document_versions)
                .where("com_documents.permalink LIKE ? OR com_document_versions.title LIKE ?",
                       like_pattern, like_pattern,)
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

            @total_pages = (Float(@total_count) / @per_page).ceil

            Rails.event.notify(
              "docs.posts.listed",
              query: @query,
              results_count: @total_count,
            )

            render json: {
              data: @documents,
              meta: {
                query: @query,
                page: @page,
                per_page: @per_page,
                total_count: @total_count,
                total_pages: @total_pages,
              },
            }
          end
        end
      end
    end
  end
end
