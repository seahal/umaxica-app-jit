# frozen_string_literal: true

module Docs
  module Com
    module Cms
      class DocumentsController < ApplicationController
        before_action :set_document, only: %i(show edit update destroy publish unpublish)

        # GET /cms/documents
        def index
          @page = (params[:page] || 1).to_i
          @per_page = 20
          @documents = ComDocument.order(created_at: :desc)
            .offset((@page - 1) * @per_page)
            .limit(@per_page)
          @total_count = ComDocument.count
          @total_pages = (@total_count.to_f / @per_page).ceil
        end

        # GET /cms/documents/:id
        def show
          @versions = @document.com_document_versions.order(created_at: :desc)
        end

        # GET /cms/documents/new
        def new
          @document = ComDocument.new
          @document.published_at = Time.current
          @document.expires_at = 1.year.from_now
        end

        # GET /cms/documents/:id/edit
        def edit
        end

        # POST /cms/documents
        def create
          @document = ComDocument.new(document_params)
          @document.status_id = "DRAFT"

          if @document.save
            create_version(@document, document_version_params)

            Rails.event.notify(
              "cms.document.created",
              document_id: @document.id,
              permalink: @document.permalink,
              actor_type: "Staff",
            )

            respond_to do |format|
              format.html {
                redirect_to docs_com_cms_document_path(@document), notice: t("docs.com.cms.documents.created")
              }
              format.turbo_stream
            end
          else
            render :new, status: :unprocessable_content
          end
        end

        # PATCH/PUT /cms/documents/:id
        def update
          if @document.update(document_params)
            create_version(@document, document_version_params)

            Rails.event.notify(
              "cms.document.updated",
              document_id: @document.id,
              permalink: @document.permalink,
              actor_type: "Staff",
            )

            respond_to do |format|
              format.html {
                redirect_to docs_com_cms_document_path(@document), notice: t("docs.com.cms.documents.updated")
              }
              format.turbo_stream
            end
          else
            render :edit, status: :unprocessable_content
          end
        end

        # DELETE /cms/documents/:id
        def destroy
          @document.destroy!

          Rails.event.notify(
            "cms.document.deleted",
            document_id: @document.id,
            permalink: @document.permalink,
            actor_type: "Staff",
          )

          respond_to do |format|
            format.html { redirect_to docs_com_cms_documents_path, notice: t("docs.com.cms.documents.deleted") }
            format.turbo_stream
          end
        end

        # POST /cms/documents/:id/publish
        def publish
          @document.update!(status_id: "ACTIVE", published_at: Time.current)

          Rails.event.notify(
            "cms.document.published",
            document_id: @document.id,
            permalink: @document.permalink,
            actor_type: "Staff",
          )

          respond_to do |format|
            format.html {
              redirect_to docs_com_cms_document_path(@document), notice: t("docs.com.cms.documents.published")
            }
            format.turbo_stream {
              render turbo_stream: turbo_stream.replace(
                "document_#{@document.id}",
                partial: "docs/com/cms/documents/document", locals: { document: @document },
              )
            }
          end
        end

        # POST /cms/documents/:id/unpublish
        def unpublish
          @document.update!(status_id: "DRAFT")

          Rails.event.notify(
            "cms.document.unpublished",
            document_id: @document.id,
            permalink: @document.permalink,
            actor_type: "Staff",
          )

          respond_to do |format|
            format.html {
              redirect_to docs_com_cms_document_path(@document), notice: t("docs.com.cms.documents.unpublished")
            }
            format.turbo_stream {
              render turbo_stream: turbo_stream.replace(
                "document_#{@document.id}",
                partial: "docs/com/cms/documents/document", locals: { document: @document },
              )
            }
          end
        end

        private

        def set_document
          @document = ComDocument.find(params[:id])
        end

        def document_params
          params.expect(
            com_document: %i(permalink
                             response_mode
                             redirect_url
                             published_at
                             expires_at
                             position),
          )
        end

        def document_version_params
          params.expect(
            com_document: %i(title
                             description
                             body),
          )
        end

        def create_version(document, version_params)
          document.com_document_versions.create!(
            permalink: document.permalink,
            response_mode: document.response_mode,
            redirect_url: document.redirect_url,
            title: version_params[:title],
            description: version_params[:description],
            body: version_params[:body],
            published_at: document.published_at,
            expires_at: document.expires_at,
            edited_by_type: "Staff",
            edited_by_id: nil, # TODO: Set actual staff ID when authentication is implemented
          )
        end
      end
    end
  end
end
