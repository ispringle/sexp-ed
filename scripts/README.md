# Scripts

This directory contains utility scripts for the sexp-ed project.

## validate-index.scm

Validates the `pages/index.scm` file to ensure it contains all required section functions.

### Usage

```bash
./scripts/validate-index.scm [path-to-index.scm]
```

If no path is provided, defaults to `pages/index.scm`.

### Exit Codes

- `0` - File is valid
- `1` - File not found
- `2` - Parse/syntax error in file
- `3` - Missing required functions

### Required Functions

The validator checks for the following functions:

- `general-section`
- `common-lisp-section`
- `scheme-section`
- `racket-section`
- `clojure-section`
- `emacs-lisp-section`
- `janet-section`
- `others-section`
- `index-content`

### Examples

```bash
# Validate the default file
./scripts/validate-index.scm

# Validate a specific file
./scripts/validate-index.scm pages/index.scm

# Check exit code
./scripts/validate-index.scm && echo "Valid!" || echo "Invalid!"
```

## test-validate-index.scm

Test suite for the validator script.

### Usage

```bash
./scripts/test-validate-index.scm
```

Runs all tests and reports results. Exit code 0 indicates all tests passed.
