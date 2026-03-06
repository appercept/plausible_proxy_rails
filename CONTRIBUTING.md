# Contributing

Thanks for your interest in contributing to plausible_proxy_rails!

## Getting Started

1. Fork and clone the repository
2. Run `bundle install` to install dependencies
3. Run `bundle exec rake` to make sure tests and linting pass

## Making Changes

1. Create a branch for your change
2. Make your changes
3. Add or update tests as needed
4. Run `bundle exec rake` to ensure tests pass and code style is clean
5. Submit a pull request

## Running Tests

```bash
bundle exec rake spec          # Run all tests
bundle exec rspec spec/path    # Run a specific spec file
```

## Code Style

This project uses [Standard](https://github.com/standardrb/standard) for Ruby code style. Run `bundle exec rake standard:fix` to auto-fix any style issues.

## Reporting Bugs

Open an issue on GitHub with:

- What you expected to happen
- What actually happened
- Steps to reproduce
- Ruby and Rails versions

## Security Issues

Please report security vulnerabilities by emailing richard@appercept.com rather than opening a public issue.
