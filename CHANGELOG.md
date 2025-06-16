# Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

### Compatible changes

### Breaking changes


## 0.6.0 2025-06-16

### Compatible changes
* Added: New option `--prefix` to specify the location of the dependency files
  in case they are not on root level of your git repository.


## 0.5.0 2025-03-26

### Compatible changes
* Dependencies are also parsed from package-lock.json and pnpm-lock.yaml if present.


## 0.4.0 2024-11-15

### Compatible changes
* Added: Reporting of the repository path as identifier. Should it ever change,
  it is an indicator for an unchanged gurney.yml in a project fork, and the 
  API may respond with an error.


## 0.3.0 2024-11-14

### Compatible changes
* Added: Compatibility with Ruby 3
* Fixed: Support UTF-8 chars in branch names


## 0.2.3 2023-05-24

### Compatible changes
* Added: Suppress Bundler's "the Bundler version is older than the one in the lockfile" warning.
