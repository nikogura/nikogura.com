# GitHub Actions Reference Implementation

This document describes the reference implementation for GitHub Actions CI/CD pipelines based on the [diagnostic-slackbot](https://github.com/nikogura/diagnostic-slackbot) project.

## Table of Contents
- [Overview](#overview)
- [Complete Workflow Configuration](#complete-workflow-configuration)
- [Workflow Breakdown](#workflow-breakdown)
- [Key Features](#key-features)
- [Best Practices](#best-practices)
- [Customization Guide](#customization-guide)

---

## Overview

This CI/CD pipeline provides:
- ✅ Automated testing on every push and PR
- ✅ Linting with both golangci-lint and namedreturns
- ✅ Semantic versioning with automatic tag creation
- ✅ Automatic GitHub releases on main branch
- ✅ Docker layer and Go module caching for speed
- ✅ Proper permissions management

---

## Complete Workflow Configuration

**File**: `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  GO_VERSION: '1.25'

permissions:
  contents: write
  packages: write
  pull-requests: write

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    outputs:
      version_tag: ${{ steps.semver.outputs.version_tag }}
      version: ${{ steps.semver.outputs.version }}

    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Generate Version
      run: |
        LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
        echo "Last tag: $LAST_TAG"

        # Extract version numbers
        VERSION=${LAST_TAG#v}
        IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

        # Increment patch version
        PATCH=$((PATCH + 1))
        NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"

        echo "New version: $NEW_VERSION"
        echo "version_tag=$NEW_VERSION" >> $GITHUB_OUTPUT
        echo "version=${MAJOR}.${MINOR}.${PATCH}" >> $GITHUB_OUTPUT
      id: semver

    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: ${{ env.GO_VERSION }}

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Cache Go modules
      uses: actions/cache@v4
      with:
        path: ~/go/pkg/mod
        key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
        restore-keys: |
          ${{ runner.os }}-go-

    - name: Cache Docker layers
      uses: actions/cache@v4
      with:
        path: /tmp/.buildx-cache
        key: ${{ runner.os }}-buildx-${{ github.sha }}
        restore-keys: |
          ${{ runner.os }}-buildx-

    - name: Download dependencies
      run: go mod download

    - name: Run unit tests
      run: make test

    - name: Install namedreturns
      run: go install github.com/nikogura/namedreturns@latest

    - name: golangci-lint
      uses: golangci/golangci-lint-action@v8
      with:
        version: latest

    - name: Lint Checks
      run: make lint

  publish:
    name: Publish
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'

    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Tag Repo
      uses: mathieudutour/github-tag-action@v6.2
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        custom_tag: ${{ needs.test.outputs.version_tag }}

    - name: Publish Release
      uses: softprops/action-gh-release@v2
      with:
        tag_name: ${{ needs.test.outputs.version_tag }}
        name: ${{ needs.test.outputs.version_tag }}
        draft: false
        prerelease: false
        token: ${{ secrets.GITHUB_TOKEN }}
```

---

## Workflow Breakdown

### 1. Trigger Configuration

```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
```

**Purpose**: Run CI on:
- Every push to `main` or `develop` branches
- Every pull request targeting `main`

**Why this pattern**:
- `main` is production-ready code
- `develop` is integration testing
- PRs to `main` must pass all checks before merge

### 2. Environment Variables

```yaml
env:
  GO_VERSION: '1.25'
```

**Purpose**: Centralize Go version for easy updates

**Best practice**: Update this single value to upgrade Go across all steps

### 3. Permissions

```yaml
permissions:
  contents: write      # Create tags and releases
  packages: write      # Publish packages
  pull-requests: write # Comment on PRs
```

**Purpose**: Explicit least-privilege permissions

**Security**: Only grant what's needed. Avoid `permissions: write-all`

### 4. Test Job

#### Semantic Versioning

```yaml
- name: Generate Version
  run: |
    LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    VERSION=${LAST_TAG#v}
    IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
    PATCH=$((PATCH + 1))
    NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
    echo "version_tag=$NEW_VERSION" >> $GITHUB_OUTPUT
  id: semver
```

**Purpose**: Automatic patch version increment

**Output**: Makes version available to other jobs via `needs.test.outputs.version_tag`

**Alternative**: For manual version control, use version files or manual tags

#### Caching Strategy

**Go Modules Cache**:
```yaml
- name: Cache Go modules
  uses: actions/cache@v4
  with:
    path: ~/go/pkg/mod
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
    restore-keys: |
      ${{ runner.os }}-go-
```

**Docker Build Cache**:
```yaml
- name: Cache Docker layers
  uses: actions/cache@v4
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-buildx-
```

**Impact**: Reduces build time from 3-5 minutes to 30-60 seconds

#### Testing

```yaml
- name: Run unit tests
  run: make test
```

**Requires**: `Makefile` with `test` target

**Example Makefile**:
```makefile
test:
	go test -v ./... -count=1 --cover
```

#### Linting

**Step 1: Install namedreturns**
```yaml
- name: Install namedreturns
  run: go install github.com/nikogura/namedreturns@latest
```

**Step 2: Run golangci-lint action**
```yaml
- name: golangci-lint
  uses: golangci/golangci-lint-action@v8
  with:
    version: latest
```

**Step 3: Run custom lint target**
```yaml
- name: Lint Checks
  run: make lint
```

**Why both?**:
- The action provides GitHub annotations on PRs
- The `make lint` target runs namedreturns (not included in golangci-lint)

**Required Makefile target**:
```makefile
lint:
	@echo "Running namedreturns linter..."
	namedreturns ./...
	@echo "Running golangci-lint..."
	golangci-lint run
```

### 5. Publish Job

```yaml
publish:
  name: Publish
  runs-on: ubuntu-latest
  needs: test
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

**Purpose**: Only publish on successful test + main branch push

**Why conditional**:
- `needs: test` ensures tests pass first
- `if:` prevents publishing from PRs or other branches

#### Automatic Tagging

```yaml
- name: Tag Repo
  uses: mathieudutour/github-tag-action@v6.2
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    custom_tag: ${{ needs.test.outputs.version_tag }}
```

**Purpose**: Create git tag from generated version

**Access pattern**: Uses outputs from `test` job

#### Release Creation

```yaml
- name: Publish Release
  uses: softprops/action-gh-release@v2
  with:
    tag_name: ${{ needs.test.outputs.version_tag }}
    name: ${{ needs.test.outputs.version_tag }}
    draft: false
    prerelease: false
```

**Purpose**: Create GitHub release with changelog

**Result**: Automatically publishes release notes visible in GitHub

---

## Key Features

### 1. Fail-Fast Pipeline

The workflow stops immediately if:
- Tests fail
- Linting fails (golangci-lint or namedreturns)
- Build fails

**Why**: Don't waste time on subsequent steps if early checks fail

### 2. Dependency Caching

**Go modules cache** based on `go.sum` hash:
- Cache hit: ~5 seconds to restore
- Cache miss: ~60 seconds to download

**Docker layers cache** based on git SHA:
- Incremental builds: ~30 seconds
- Full rebuild: ~2-3 minutes

### 3. Parallel Testing Strategy

The `test` job can be extended to run multiple test suites in parallel:

```yaml
test:
  strategy:
    matrix:
      go: ['1.23', '1.24', '1.25']
  steps:
    - uses: actions/setup-go@v5
      with:
        go-version: ${{ matrix.go }}
```

### 4. Branch Protection Integration

This workflow integrates with GitHub branch protection:
- Require "Test" job to pass before merge
- Require "Lint Checks" to pass before merge
- Prevent direct pushes to main

**GitHub Settings** → **Branches** → **Branch protection rules**:
```
✅ Require status checks to pass before merging
  ✅ Test
  ✅ Lint Checks
✅ Require branches to be up to date before merging
```

---

## Best Practices

### 1. Pin Action Versions

**DO**:
```yaml
uses: actions/checkout@v4
uses: golangci/golangci-lint-action@v8
```

**DON'T**:
```yaml
uses: actions/checkout@main
uses: golangci/golangci-lint-action@latest
```

**Why**: Prevent breaking changes from upstream actions

### 2. Use `fetch-depth: 0` for Versioning

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0  # Required for git describe
```

**Why**: `git describe --tags` needs full history

### 3. Separate Test and Publish Jobs

**Benefits**:
- PRs run tests without attempting to publish
- Clear separation of concerns
- Easier to debug failures

### 4. Use Job Outputs for Data Flow

```yaml
jobs:
  test:
    outputs:
      version_tag: ${{ steps.semver.outputs.version_tag }}

  publish:
    needs: test
    steps:
      - run: echo ${{ needs.test.outputs.version_tag }}
```

**Why**: Clean data flow between jobs without artifacts

### 5. Make Workflow Idempotent

Each step should be safe to re-run:
- Cache restoration handles misses gracefully
- Version generation is deterministic
- Tests don't modify external state

---

## Customization Guide

### For Non-Go Projects

Replace Go-specific steps:

```yaml
# Replace
- name: Set up Go
  uses: actions/setup-go@v5

# With (for Node.js)
- name: Set up Node
  uses: actions/setup-node@v4
  with:
    node-version: '20'
```

### For Docker Image Publishing

Add to `publish` job:

```yaml
- name: Log in to GitHub Container Registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}

- name: Build and push
  uses: docker/build-push-action@v5
  with:
    push: true
    tags: ghcr.io/${{ github.repository }}:${{ needs.test.outputs.version_tag }}
    cache-from: type=local,src=/tmp/.buildx-cache
    cache-to: type=local,dest=/tmp/.buildx-cache-new
```

### For Multi-Architecture Builds

```yaml
- name: Set up QEMU
  uses: docker/setup-qemu-action@v3

- name: Build and push
  uses: docker/build-push-action@v5
  with:
    platforms: linux/amd64,linux/arm64
    push: true
    tags: ghcr.io/${{ github.repository }}:${{ needs.test.outputs.version_tag }}
```

### For Manual Version Control

Replace the version generation step:

```yaml
- name: Get version from file
  run: |
    VERSION=$(cat VERSION)
    echo "version_tag=v$VERSION" >> $GITHUB_OUTPUT
  id: semver
```

### For Integration Tests

Add a separate job:

```yaml
integration:
  name: Integration Tests
  runs-on: ubuntu-latest
  needs: test

  services:
    postgres:
      image: postgres:16
      env:
        POSTGRES_PASSWORD: postgres
      options: >-
        --health-cmd pg_isready
        --health-interval 10s
        --health-timeout 5s
        --health-retries 5

  steps:
    - name: Run integration tests
      run: make integration-test
      env:
        DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
```

---

## Required Repository Setup

### 1. Makefile Targets

Your repository must include these `make` targets:

```makefile
.PHONY: test lint

test:
	go test -v ./... -count=1 --cover

lint:
	@echo "Running namedreturns linter..."
	namedreturns ./...
	@echo "Running golangci-lint..."
	golangci-lint run
```

### 2. golangci-lint Configuration

Include `.golangci.yml` in repository root:

```yaml
linters:
  enable:
    - gofmt
    - goimports
    - govet
    - errcheck
    - staticcheck
    # ... other linters
```

### 3. Branch Protection Rules

**GitHub Settings** → **Branches** → **Add rule**:

```
Branch name pattern: main

☑ Require a pull request before merging
  ☑ Require approvals: 1
☑ Require status checks to pass before merging
  ☑ Require branches to be up to date before merging
  Status checks: Test, Lint Checks
☑ Do not allow bypassing the above settings
```

---

## Troubleshooting

### Tests Pass Locally But Fail in CI

**Possible causes**:
1. Missing environment variables
2. Different Go version
3. Race conditions in tests
4. File system differences

**Solution**: Run with same Go version as CI:
```bash
docker run --rm -v $(pwd):/app -w /app golang:1.25 make test
```

### Cache Not Restoring

**Check**:
- Is `go.sum` committed?
- Did dependencies change?
- Is cache key correctly formatted?

**Force cache rebuild**:
- Update cache key in workflow
- Or clear GitHub Actions cache via Settings

### Version Tag Already Exists

**Cause**: Attempting to create duplicate tag

**Solution**: Delete tag or increment manually:
```bash
git tag -d v1.2.3
git push origin :refs/tags/v1.2.3
```

### namedreturns Not Found

**Cause**: Installation step failed or skipped

**Solution**: Check step logs, ensure:
```yaml
- name: Install namedreturns
  run: go install github.com/nikogura/namedreturns@latest
```

---

## Reference Implementation

Live example: [nikogura/diagnostic-slackbot](https://github.com/nikogura/diagnostic-slackbot/blob/main/.github/workflows/ci.yml)

For questions or issues with this reference implementation, see the [EngineeringStandards.md](EngineeringStandards.md) or open an issue.
