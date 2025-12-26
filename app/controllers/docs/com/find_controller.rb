# frozen_string_literal: true

module Docs
  module Com
    class FindController < ApplicationController
      # GET /find/:id
      # :id is used as a search query parameter
      def show
        @query = params[:id]
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

        Rails.event.notify("docs.find.searched",
                           query: @query,
                           results_count: @total_count,)
      end
    end
  end
end
