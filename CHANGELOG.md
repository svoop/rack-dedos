## Main

### Fixes
* Correctly include details in warnings (i.e. country code)

## 0.4.0

### Changes
* Drop certs
* Add action for trusted release

## 0.3.2

### Changes
* Resolve all paths to prevent problems with relative paths

## 0.3.1

### Changes
* Root `File` operations to prevent clashes with Rack

## 0.3.0

### Changes
* Convert `geoipget` from Bash to Ruby

## 0.2.4

### Changes
* Use Bash for `geoipget` to prevent problems with `/bin/sh` diversity

## 0.2.3

### Additions
* `geoipget` shell script

## 0.2.2

### Changes
* Update to Ruby 3.4

## 0.2.1

### Fixes

* Fix paths on conditional requires
* Renew certificate

## 0.2.0

### Changes

* Determine real client IP
* Drop autoload and put filters in proper namespace

## 0.1.0

### Initial implementation

* UserAgent filter
* Country filter
