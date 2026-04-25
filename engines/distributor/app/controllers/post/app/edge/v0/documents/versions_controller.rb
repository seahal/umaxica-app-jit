# typed: strict
# frozen_string_literal: true

module Jit::Distributor::Post::App::Edge::V0::Documents
  class VersionsController < ApplicationController
    def index
      @record = AppDocument.find(params[:document_id])
      @versions = @record.app_document_versions
      render json: @versions
    end

    def show
      @version = AppDocumentVersion.find(params[:id])
      render json: @version
    end
  end
end
