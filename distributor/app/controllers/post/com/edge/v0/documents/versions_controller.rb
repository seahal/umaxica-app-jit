# typed: strict
# frozen_string_literal: true

module Post::Com::Edge::V0::Documents
  class VersionsController < ApplicationController
    def index
      @record = ComDocument.find(params[:document_id])
      @versions = @record.com_document_versions
      render json: @versions
    end

    def show
      @version = ComDocumentVersion.find(params[:id])
      render json: @version
    end
  end
end
