---
title: 'Gomason'
description: CI/CD in your pocket. Build, sign, and publish Go binaries locally with a single command.
publishDate: 'Jan 01 2020'
isFeatured: false
seo:
  title: 'Gomason'
  description: Local CI/CD tool for building, signing, and publishing Go binaries.
---

Gomason puts CI/CD in your pocket. It builds, signs, and publishes Go binaries locally with a single command, giving developers a reproducible build pipeline without depending on external CI infrastructure. If it builds with Gomason on your laptop, it builds the same way everywhere.

The tool handles the entire release workflow: compiling for target platforms, running tests, signing artifacts with cryptographic keys, and publishing to artifact repositories. All of this is driven by a simple configuration file in the project root, making it easy to standardize build processes across multiple projects.

Gomason is particularly valuable for teams that need to produce signed binaries for distribution. Combined with the [Dynamic Binary Toolkit (DBT)](https://github.com/nikogura/dbt), it forms a complete pipeline for building signed binaries and distributing them as self-updating tools. Gomason handles the build and sign steps, while DBT handles the distribution and update lifecycle.

The tool is designed to be fast and predictable. It builds in a clean environment to avoid contamination from local state, ensuring that published artifacts are reproducible regardless of the developer's machine configuration.

GitHub: [https://github.com/nikogura/gomason](https://github.com/nikogura/gomason)
