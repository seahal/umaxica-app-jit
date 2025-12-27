# frozen_string_literal: true

class FixDocumentConsistency < ActiveRecord::Migration[8.2]
  def change
    %i(org com app).each do |prefix|
      # Tags - Add missing index for reverse association if needed
      # The checker complained about "associated model should have proper index"
      # explicitly for the has_many side usually, but let's stick to the ones likely missing.
      # existing schema showed some indexes.

      # Tag Master Parent Index (already in schema? let's ensure)
      add_index "#{prefix}_document_tag_masters", :parent_id, if_not_exists: true

      # Category Master Parent Index
      add_index "#{prefix}_document_category_masters", :parent_id, if_not_exists: true

      # Document Tags - The has_many association from TagMaster
      # "OrgDocumentTagMaster org_document_tags associated model should have proper index"
      # This usually means index on [tag_master_id] in the tags table.
      add_index "#{prefix}_document_tags", "#{prefix}_document_tag_master_id", if_not_exists: true

      # Document Categories
      add_index "#{prefix}_document_categories", "#{prefix}_document_category_master_id", if_not_exists: true
    end
  end
end
