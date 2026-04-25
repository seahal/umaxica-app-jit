# typed: strict
# frozen_string_literal: true

module Post::Org::Edge::V0::Documents
  class VersionsController < ApplicationController
    def index
      @record = OrgDocument.find(params[:document_id])
      @versions = @record.org_document_versions
      render json: @versions
    end

    def show
      @version = OrgDocumentVersion.find(params[:id])
      render json: @version
    end
  end
end
