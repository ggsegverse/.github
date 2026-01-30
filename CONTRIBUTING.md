# Contributing to ggseg

Thank you for considering contributing to ggseg! This document outlines how to contribute to any repository in the ggseg organization.

## Getting Started

1. Fork the repository you want to contribute to
2. Clone your fork locally
3. Create a new branch for your contribution

## Types of Contributions

### Bug Reports

- Use the bug report issue template
- Include a minimal reproducible example (reprex)
- Specify your R version and relevant package versions

### Feature Requests

- Use the feature request issue template
- Explain the use case and why existing functionality doesn't cover it

### Atlas Requests

Want a new brain atlas added to ggseg? Please check the [Atlas Wishlist](https://github.com/orgs/ggseg/discussions/categories/atlas-wishlist) first to see if it has already been requested. If not, post your request there. Atlas requests should go to Discussions, not Issues.

### Contributing an Atlas

Want to create and contribute a new atlas yourself? The [ggsegExtra](https://ggseg.github.io/ggsegExtra/) package provides functionality to create ggseg-compatible atlases.

Once your atlas package is ready, there are two ways to make it part of the ecosystem:

1. **Add to the ggseg organization** - Transfer or add your repository to the ggseg GitHub organization
2. **Link via r-universe** - Keep the package on your own GitHub account and have it linked through the ggseg r-universe

Reach out via [Discussions](https://github.com/orgs/ggseg/discussions) to coordinate adding your atlas to the ecosystem.

### Code Contributions

#### Before You Start

- For major changes, open an issue first to discuss your proposal
- Check existing issues and PRs to avoid duplicate work

#### Development Workflow

1. Install development dependencies: `devtools::install_dev_deps()`
2. Make your changes
3. Add or update tests as needed
4. Run `devtools::check()` and ensure it passes
5. Update documentation if you've changed function behavior

#### Code Style

- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Use roxygen2 for documentation
- Write tests using testthat

#### Pull Requests

- Use a clear, descriptive title
- Reference any related issues
- Describe what your changes do and why
- Ensure all CI checks pass

### Documentation

Documentation improvements are always welcome. This includes:

- Fixing typos
- Clarifying confusing sections
- Adding examples
- Improving vignettes

## Code of Conduct

Please note that ggseg projects are released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## Questions?

If you're unsure about anything, feel free to open an issue to ask.
