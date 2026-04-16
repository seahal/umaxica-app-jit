# Regional Docs/News CMS Implementation Plan

## Status

Active draft (2026-04-16)

## Summary

Implement `Regional` content for `docs` and `news` using the already accepted canonical model
families:

- `docs` -> `Document`
- `news` -> `Timeline`

Implementation boundaries:

- editing only from the `org` staff CMS surface
- public read delivery for `app`, `com`, and `org`
- `help` is excluded
- `avatar.posts` is excluded

## Current Repo Findings

- `station` has stub staff CMS controllers for `docs`
- `station` has routes for `news`, but no meaningful controller implementation yet
- `press` has `docs` read endpoints, but they still return placeholder payloads
- `publication` schema already contains entry, revision, version, category, and tag tables for both
  `Document` and `Timeline`
- taxonomy trees already use recursive parent/child masters

## Implementation Changes

### 1. Public read controllers

Replace placeholder delivery in the current read surfaces with real model-backed behavior.

For `docs`:

- list entries from the `*Document` family
- show one entry from the current public version
- list versions for one entry
- show one version
- list category tree
- list tag tree

For `news`:

- mirror the same contract using the `*Timeline` family

Public source of truth:

- entry-level public pointer is `latest_version_id`
- public read must not use draft `revision` as the canonical source

Read filtering:

- allowed published status only
- `published_at <= now`
- `expires_at > now`

### 2. Staff CMS controllers

Implement content editing only under `org`.

For both `docs` and `news`, support:

- create entry shell
- show entry list
- show entry detail
- create draft revision
- edit by creating another draft revision
- assign one category
- assign zero or more tags
- publish a selected revision into a public version
- view version history

Do not implement taxonomy master CRUD in v1.

### 3. Draft and publish flow

Use the following behavior consistently for both model families:

- draft save creates a new `revision`
- publish creates or promotes a `version` derived from a selected `revision`
- entry updates:
  - `latest_revision_id`
  - `latest_version_id`
  - `status_id`
  - `published_at`
  - `expires_at`

Avoid treating `revision` and `version` as interchangeable even though their columns are similar.

### 4. Taxonomy behavior

Use existing recursive master trees.

- category tree read remains recursive
- tag tree read remains recursive
- category assignment stays one-per-entry
- tag assignment stays many-per-entry

v1 staff behavior:

- choose one category from existing masters
- choose many tags from existing masters
- no create/move/delete for masters

## API and UI Contract

### Public read contract

`docs` and `news` should expose the same shape by surface:

- entry list
- entry detail
- version list
- version detail
- category tree
- tag tree

### Staff CMS contract

`org` editing surface should provide:

- entry index
- entry create
- entry detail
- draft save
- taxonomy assignment
- publish action
- version history view

The staff CMS is the only write surface.

## Test Plan

### Public read

- `docs` list/show returns persisted `Document` content, not placeholder JSON
- `news` list/show returns persisted `Timeline` content, not placeholder JSON
- unpublished, expired, and inactive entries are excluded
- public show resolves through `latest_version_id`
- version endpoints return only versions belonging to the requested entry
- taxonomy endpoints return recursive tree data for both category and tag

### Staff CMS

- `org` can create entries for `docs`
- `org` can create entries for `news`
- saving draft creates a new `revision`
- publishing from a revision creates or promotes a `version`
- category assignment is single-valued
- tag assignment is multi-valued
- duplicate tag assignment is rejected
- `app` and `com` cannot perform write operations

## Assumptions

- `help` will be designed in a separate track
- existing taxonomy master tables are sufficient for v1 assignment use
- review workflow is not required for v1
- public read endpoints may keep the existing route shapes if they are remapped to canonical models
- if current controller names reflect old engine names, behavior matters more than naming during the
  first implementation pass
