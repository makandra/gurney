# Gurney changelog

## 0.4.0 (2024-11-15)
* Added: Reporting of the repository path as identifier. Should it ever change,
  it is an indicator for an unchanged gurney.yml in a project fork, and the 
  API may respond with an error.

## 0.3.0 (2024-11-14)
* Added: Compatibility with Ruby 3
* Fixed: Support UTF-8 chars in branch names

## 0.2.3 (2023-05-24)
* Added: Suppress Bundler's "the Bundler version is older than the one in the lockfile" warning.
