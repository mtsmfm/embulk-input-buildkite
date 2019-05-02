# Buildkite input plugin for Embulk

Fetch Buildkite build results

## Overview

- **Plugin type**: input
- **Resume supported**: ?
- **Cleanup supported**: ?
- **Guess supported**: no

## Configuration

- **org_slug**: Target repository name like `rails` (string, required)
- **pipeline_slug**: Target pipeline name like `rails` (string, required)
- **build_nums**: Build numbers (Array of integer, required)
- **token**: Buildkite API token which can be found on https://buildkite.com/user/api-access-tokens (string, required)

## Example

```liquid
in:
  type: buildkite
  org_slug: rails
  pipeline_slug: rails
  build_nums: [60894]
  token: {{ env.BUILDKITE_ACCESS_TOKEN }}
```

## Build

```
$ rake
```

## Test

```
$ embulk run config.yml.liquid -b $BUNDLE_PATH -L .
```

## Example

```yaml
in:
  type: travis
  repo: rails/rails
  build_num_from: 59100
  step: 15
  token: xxxxxxxxxxxxxxxxxxxxxx
```
