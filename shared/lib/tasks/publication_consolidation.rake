# typed: false
# frozen_string_literal: true

namespace :publication do
  namespace :consolidation do
    desc "Show current status of document/publication consolidation"
    task status: :environment do
      puts "Publication Consolidation Status"
      puts "=" * 50
      puts

      # Check DocumentRecord inheritance
      puts "DocumentRecord inheritance:"
      puts "  DocumentRecord < PublicationRecord: #{DocumentRecord < PublicationRecord}"
      puts "  DocumentRecord.abstract_class: #{DocumentRecord.abstract_class}"
      puts

      # List DocumentRecord models
      puts "Models inheriting from DocumentRecord:"
      document_models = [
        AppDocument, ComDocument, OrgDocument,
        AppDocumentVersion, ComDocumentVersion, OrgDocumentVersion,
        AppDocumentRevision, ComDocumentRevision, OrgDocumentRevision,
        AppDocumentTag, ComDocumentTag, OrgDocumentTag,
        AppDocumentCategory, ComDocumentCategory, OrgDocumentCategory,
        AppDocumentStatus, ComDocumentStatus, OrgDocumentStatus,
        AppDocumentTagMaster, ComDocumentTagMaster, OrgDocumentTagMaster,
        AppDocumentCategoryMaster, ComDocumentCategoryMaster, OrgDocumentCategoryMaster,
      ]

      document_models.each do |model|
        connection_class = model.ancestors.find { |a| a.is_a?(Class) && a < ActiveRecord::Base && a.abstract_class? }
        puts "  #{model.name}: #{connection_class&.name || "Unknown"}"
      end
      puts

      # Check database connections
      puts "Database connections:"
      puts "  PublicationRecord connection: #{PublicationRecord.connection_db_config.database}"
      puts "  DocumentRecord connection: #{DocumentRecord.connection_db_config.database}"
      puts

      # Migration paths
      puts "Migration paths:"
      puts "  publications_migrate: db/publications_migrate (ACTIVE)"
      puts "  documents_migrate: db/documents_migrate (LEGACY - frozen)"
      puts

      puts "Status: Phase 2 Complete (Document models use PublicationRecord)"
      puts "Next: Phase 3 - Define news domain structure"
    end

    desc "Verify document tables exist in publication database"
    task verify_tables: :environment do
      # rubocop:disable I18n/RailsI18n/DecorateString
      puts "Verifying document tables in publication database..."
      # rubocop:enable I18n/RailsI18n/DecorateString
      puts

      required_tables = %w(
        app_documents com_documents org_documents
        app_document_versions com_document_versions org_document_versions
        app_document_revisions com_document_revisions org_document_revisions
        app_document_tags com_document_tags org_document_tags
        app_document_categories com_document_categories org_document_categories
        app_document_statuses com_document_statuses org_document_statuses
        app_document_tag_masters com_document_tag_masters org_document_tag_masters
        app_document_category_masters com_document_category_masters org_document_category_masters
      )

      PublicationRecord.connection do |conn|
        existing_tables = conn.tables

        required_tables.each do |table|
          exists = existing_tables.include?(table)
          status = exists ? "✓" : "✗"
          puts "  #{status} #{table}"
        end
      end
    end

    desc "Show guidance for news domain implementation (Phase 3)"
    task news_guidance: :environment do
      puts "News Domain Implementation Guidance"
      puts "=" * 50
      puts
      # rubocop:disable I18n/RailsI18n/DecorateString
      puts "The publication database should be the home for all published content."
      # rubocop:enable I18n/RailsI18n/DecorateString
      puts "For the news domain, choose one of these approaches:"
      puts
      puts "Option 1: News as Document Subtype"
      puts "  - Add a 'news' document type to existing document tables"
      puts "  - Pros: Reuses existing structure, simpler migration"
      puts "  - Cons: News-specific fields may require nullable columns"
      puts
      puts "Option 2: News as Timeline Subtype"
      puts "  - Extend timeline models to support news content"
      puts "  - Pros: Timelines already in publication, good for chronological content"
      puts "  - Cons: May not fit all news content patterns"
      puts
      puts "Option 3: Dedicated News Tables"
      puts "  - Create app_news, com_news, org_news tables in publication"
      puts "  - Pros: Clean separation, news-specific schema"
      puts "  - Cons: More tables to maintain, potential duplication"
      puts
      puts "Recommended: Option 1 or 3 for clarity"
      puts
      puts "See: plans/backlog/publication-consolidation-plan.md for full details"
    end
  end
end
