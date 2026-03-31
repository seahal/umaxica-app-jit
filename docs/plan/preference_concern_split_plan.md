# Preference Concern Split Plan

## Why Split

`Preference::Core` currently concentrates multiple responsibilities in one place.

The likely benefits of splitting later are:

- clearer ownership by preference area
- easier testing and debugging
- safer future changes for `com/customer` alignment
- smaller, easier-to-reason-about update paths
- cleaner separation between update logic, token refresh, cookie handling, and resource sync

## Candidate Future Structure

- `Preference::RegionActions`
- `Preference::LanguageActions`
- `Preference::TimezoneActions`
- `Preference::ThemeActions`
- `Preference::CookieActions`
- `Preference::ResourceSync`

## Status

This is a planning note, not an immediate implementation task. The current priority is aligning
behavior and dual-write, not splitting concerns first.
