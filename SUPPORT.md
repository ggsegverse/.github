# Getting Help with ggseg

## Documentation

Before asking for help, please check the relevant package documentation:

- Function documentation: `?function_name` in R
- Package vignettes: `browseVignettes("package_name")`
- [ggseg documentation site](https://ggseg.github.io/)

## Asking Questions

### GitHub Discussions

For general questions, ideas, and community conversation, please use [ggseg Discussions](https://github.com/orgs/ggseg/discussions).

### Requesting a New Atlas

Before requesting a new atlas, please check the [Atlas Wishlist](https://github.com/orgs/ggseg/discussions/categories/atlas-wishlist) to see if it has already been requested. If not, post your request there rather than opening an issue.

If you want to create an atlas yourself, see the [ggsegExtra](https://ggseg.github.io/ggsegExtra/) package and our [contributing guide](CONTRIBUTING.md#contributing-an-atlas).

### GitHub Issues

For bugs and confirmed feature requests (not atlas requests), use GitHub Issues on the relevant repository with the appropriate issue template.

### Stack Overflow

For general usage questions, consider posting on [Stack Overflow](https://stackoverflow.com/) with the tag `ggseg`.

## Reporting Bugs

When reporting bugs, please include:

1. A minimal reproducible example (reprex)
2. Your R version (`R.version.string`)
3. Package versions (`packageVersion("ggseg")`)
4. Your operating system

Use the `reprex` package to create reproducible examples:

```r
reprex::reprex({
  library(ggseg)
  # your code here
})
```

