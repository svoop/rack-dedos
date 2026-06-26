# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/),
and this project adheres to [Break Versioning](https://www.taoensso.com/break-versioning).

## [Unreleased]

### Changed

- Relaxed dependency on connection_pool for better legacy support

## [0.7.2] - 2026-06-26

### Added

- Spamhaus filter

## [0.7.1] - 2026-04-21

### Added

- Enforce MFA for future gem releases

## [0.7.0] - 2026-03-11

### Changed

- **Breaking:** Changed format of country code details in log

### Fixed

- Dropped keyword arguments for Rack compatibility
- Fixed collision with Rack::Logger

## [0.6.0] - 2026-03-11

### Changed

- **Breaking:** Log to STDOUT (instead of STDERR) by default

### Added

- Suppport custom loggers
- Optionally log request headers

## [0.5.1] - 2026-01-08

### Fixed

- Fixed getcwd errors due to unlinked tmpdir

## [0.5.0] - 2026-01-06

### Changed

- Updated to Ruby 4.0
- Require Minitest >= 6

## [0.4.2] - 2025-12-01

### Changed

- Adhere to [BreakVer](https://www.taoensso.com/break-versioning) from this point forward

### Added

- Include the requested URL in warnings
- Added `only_paths` and `except_paths` options

## [0.4.1] - 2025-11-04

### Fixed

- Correctly include details in warnings (i.e. country code)

## [0.4.0] - 2025-07-21

### Changed

- Dropped certs
- Addded action for trusted release

## [0.3.2] - 2025-01-16

### Changed

- Resolve all paths to prevent problems with relative paths

## [0.3.1] - 2025-01-16

### Fixed

- Root `File` operations to prevent clashes with Rack

## [0.3.0] - 2025-01-16

### Changed

- Converted `geoipget` from Bash to Ruby

## [0.2.4] - 2025-01-15

### Changed

- Use Bash for `geoipget` to prevent problems with `/bin/sh` diversity

## [0.2.3] - 2025-01-15

### Added

- `geoipget` shell script

## [0.2.2] - 2024-12-25

### Changed

- Updated to Ruby 3.4

## [0.2.1] - 2024-11-20

### Fixed

- Fixed paths on conditional requires
- Renewed certificate

## [0.2.0] - 2023-05-16

### Changed

- Determine real client IP
- Dropped autoload and put filters in proper namespace

## [0.1.0] - 2023-02-03

### Added

- UserAgent filter
- Country filter
