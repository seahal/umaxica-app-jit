# frozen_string_literal: true

class RenameOrgDocumentTagTables < ActiveRecord::Migration[8.2]
  def up
    # Rename org_document_tags to org_document_tag_masters
    rename_table(:org_document_tags, :org_document_tag_masters)

    execute(<<~SQL.squish)
      DO $$
      BEGIN
        IF EXISTS (
          SELECT 1
          FROM pg_constraint
          WHERE conname = 'org_document_tags_pkey'
        ) THEN
          ALTER TABLE org_document_tag_masters
            RENAME CONSTRAINT org_document_tags_pkey TO org_document_tag_masters_pkey;
        END IF;
      END $$;
    SQL

    # Rename org_document_taggers to org_document_tags
    rename_table(:org_document_taggers, :org_document_tags)

    execute(<<~SQL.squish)
      DO $$
      BEGIN
        IF EXISTS (
          SELECT 1
          FROM pg_constraint
          WHERE conname = 'org_document_taggers_pkey'
        ) THEN
          ALTER TABLE org_document_tags
            RENAME CONSTRAINT org_document_taggers_pkey TO org_document_tags_pkey;
        END IF;
      END $$;
    SQL

    # Update foreign key column name in the new org_document_tags table
    rename_column(:org_document_tags, :org_document_tag_id, :org_document_tag_master_id)
  end

  def down
    rename_column(:org_document_tags, :org_document_tag_master_id, :org_document_tag_id)

    # Rename org_document_tags back to org_document_taggers
    rename_table(:org_document_tags, :org_document_taggers)

    execute(<<~SQL.squish)
      DO $$
      BEGIN
        IF EXISTS (
          SELECT 1
          FROM pg_constraint
          WHERE conname = 'org_document_tags_pkey'
        ) THEN
          ALTER TABLE org_document_taggers
            RENAME CONSTRAINT org_document_tags_pkey TO org_document_taggers_pkey;
        END IF;
      END $$;
    SQL

    # Rename org_document_tag_masters back to org_document_tags
    rename_table(:org_document_tag_masters, :org_document_tags)

    execute(<<~SQL.squish)
      DO $$
      BEGIN
        IF EXISTS (
          SELECT 1
          FROM pg_constraint
          WHERE conname = 'org_document_tag_masters_pkey'
        ) THEN
          ALTER TABLE org_document_tags
            RENAME CONSTRAINT org_document_tag_masters_pkey TO org_document_tags_pkey;
        END IF;
      END $$;
    SQL
  end
end
