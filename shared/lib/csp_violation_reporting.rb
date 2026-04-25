# typed: false
# frozen_string_literal: true

module CspViolationReporting
  extend ActiveSupport::Concern

  private

  def create_csp_violation_report
    payload = parse_csp_violation_payload
    Rails.event.record("security.csp_violation", payload:)
    head :no_content
  rescue ActionDispatch::Http::Parameters::ParseError, JSON::ParserError, TypeError => e
    Rails.event.error("security.csp_violation.parse_failed", error_class: e.class.name, message: e.message)
    head :no_content
  end

  def parse_csp_violation_payload
    report = request.request_parameters
    report = report.with_indifferent_access if report.respond_to?(:with_indifferent_access)
    payload = report[:"csp-report"] || report[:csp_report] || report[:report] || report
    payload = payload.with_indifferent_access if payload.respond_to?(:with_indifferent_access)

    {
      document_uri: payload["document-uri"] || payload[:document_uri],
      violated_directive: payload["violated-directive"] || payload[:violated_directive],
      blocked_uri: payload["blocked-uri"] || payload[:blocked_uri],
      source_file: payload["source-file"] || payload[:source_file],
      line_number: payload["line-number"] || payload[:line_number],
      column_number: payload["column-number"] || payload[:column_number],
      original_policy: payload["original-policy"] || payload[:original_policy],
      referrer: payload["referrer"],
      effective_directive: payload["effective-directive"] || payload[:effective_directive],
      disposition: payload["disposition"],
    }.compact
  end
end
