---
title: 'Dynamic Binary Toolkit (DBT)'
description: Framework for distributing self-updating signed binaries that transparently check for updates, verify signatures, and replace themselves.
publishDate: 'Jan 01 2020'
isFeatured: false
seo:
  title: 'Dynamic Binary Toolkit (DBT)'
  description: Framework for distributing self-updating, cryptographically signed binaries.
---

The Dynamic Binary Toolkit (DBT) is a framework for distributing self-updating, cryptographically signed binaries. Users always run the latest version of a tool without manual upgrade steps. When a binary is executed, DBT transparently checks for updates, verifies the cryptographic signature of the new version, and replaces the running binary before continuing execution.

This approach solves a persistent problem in tool distribution: getting users to actually run the latest version. With DBT, there is no upgrade process to forget or skip. The tool handles it automatically, and the signature verification ensures that only authorized builds are executed, preventing supply-chain tampering.

DBT is designed for organizations that distribute internal tooling to engineers, operations teams, or CI/CD systems. It eliminates the overhead of managing tool versions across fleets of machines while maintaining strong security guarantees through cryptographic signing. The framework supports any binary, not just Go programs.

The toolkit pairs well with [Gomason](https://github.com/nikogura/gomason) for building and signing the binaries that DBT distributes, providing a complete pipeline from source code to self-updating deployment.

GitHub: [https://github.com/nikogura/dbt](https://github.com/nikogura/dbt)
