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

## add-resource.scm

Adds a new resource card to a section in `pages/index.scm`. The script reads the file, finds the target section, inserts the new resource card, and either outputs the result to stdout (for preview) or modifies the file in-place with the `--in-place` flag.

### Usage

```bash
./scripts/add-resource.scm [--in-place] <section-id> <title> <url> <description> <tags-json>
```

### Arguments

- `--in-place` (optional) - Modify `pages/index.scm` in-place instead of printing to stdout
- `section-id` - Section identifier (see Section IDs below)
- `title` - Title of the resource (use quotes if it contains spaces)
- `url` - URL of the resource
- `description` - Description of the resource (use quotes if it contains spaces)
- `tags-json` - JSON array of tags, e.g., `'["tag1", "tag2"]'`

**Note:** The target file is always `pages/index.scm` in the project root.

### Section IDs

- `general` - General Lisp Resources
- `common-lisp` - Common Lisp
- `scheme` - Scheme
- `racket` - Racket
- `clojure` - Clojure
- `emacs-lisp` - Emacs Lisp
- `janet` - Janet
- `others` - Other Lisps & Inspired Languages

### Exit Codes

- `0` - Success
- `1` - Invalid arguments
- `2` - File not found
- `3` - Parse/syntax error
- `4` - Section not found
- `5` - Validation failed

### Examples

```bash
# Preview changes (dry run - output to stdout)
./scripts/add-resource.scm scheme \
  "Sigil" \
  "https://usesigil.org/" \
  "David Wilson's Scheme implementation with simple syntax and powerful abstractions" \
  '["implementation", "free"]'

# Add a resource and modify the file in-place
./scripts/add-resource.scm --in-place common-lisp \
  "Quicklisp" \
  "https://www.quicklisp.org/" \
  "Library manager for Common Lisp - the de facto package manager" \
  '["tool", "free"]'

# Preview changes and save to a file
./scripts/add-resource.scm racket \
  "DrRacket" \
  "https://racket-lang.org/" \
  "Integrated development environment for Racket" \
  '["tool", "free", "beginner"]' > preview.scm
```

### How It Works

1. Reads all S-expressions from `pages/index.scm`
2. Finds the target section function (e.g., `scheme-section`)
3. Locates the `resources-grid` div within that section
4. Appends a new `,(resource-card ...)` form to the grid
5. Validates the output is valid Scheme
6. Either prints to stdout (default) or writes back to `pages/index.scm` (with `--in-place`)

### Special Characters

The script handles special characters in strings (quotes, backslashes) automatically. Shell quoting rules apply when passing arguments, so use appropriate quoting:

```bash
# Title with quotes
./scripts/add-resource.scm scheme \
  "The \"Little\" Schemer" \
  "https://example.com" \
  "Description here" \
  '["book"]'
```

## test-add-resource.scm

Test suite for the add-resource script.

### Usage

```bash
./scripts/test-add-resource.scm
```

Runs all tests and reports results. Exit code 0 indicates all tests passed.

### Test Coverage

The test suite validates:
- Script existence and executability
- Usage message display
- Invalid section handling
- Resource insertion into sections
- Output validity (parseable Scheme)
- In-place file modification
- Preservation of existing resources
- Special character handling
- Multiple section support
