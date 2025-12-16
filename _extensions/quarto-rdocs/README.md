# quarto-rdocs

A Quarto extension for generating R package documentation websites directly from `.Rd` files.

## Features

- **Native Quarto integration**: Uses pre-render scripts, not a wrapper
- **Single config**: Everything in `_quarto.yml`
- **pkgdown-style sections**: Group functions by category with pattern matching
- **Freeze/caching**: Skip re-evaluation of unchanged examples
- **Cross-references**: Integrates with downlit for package links
- **Dark mode**: Built-in light/dark theme support
- **Source links**: Link directly to GitHub source code

## Installation

```bash
quarto add Data-Wise/quarto-rdocs
```

Or manually copy the `_extensions/quarto-rdocs` folder to your project.

## Quick Start

1. Add the extension to your project
2. Configure `_quarto.yml`:

```yaml
project:
  type: website
  pre-render:
    - _extensions/quarto-rdocs/R/rdocs-render.R

rdocs:
  package: yourpackage
  dir: reference

  sections:
    - title: "Main Functions"
      desc: "Core functionality"
      contents:
        - main_function
        - helper_function
        - starts_with("calc_")  # Pattern matching!

format:
  html:
    theme:
      light: [flatly, _extensions/quarto-rdocs/scss/rdocs.scss]
      dark: [darkly, _extensions/quarto-rdocs/scss/rdocs.scss]
```

3. Render your site:

```bash
quarto render
```

## Configuration Reference

### `rdocs` section

| Option | Description | Default |
|--------|-------------|---------|
| `package` | Package name | Directory name |
| `dir` | Output directory for reference docs | `reference` |
| `sidebar` | Path to generated sidebar YAML | `reference/_sidebar.yml` |
| `sections` | List of section definitions | All exports |

### Section Definition

```yaml
sections:
  - title: "Section Title"
    desc: "Optional description"
    contents:
      - exact_function_name
      - starts_with("prefix")
      - ends_with("suffix")
      - matches("regex_pattern")
      - -excluded_function    # Exclude with -
```

### Options

```yaml
rdocs:
  options:
    examples: false          # Evaluate examples (slower but shows output)
    freeze: true             # Cache example results
    source_links: true       # Add "View source" links
    repo_url: https://github.com/user/repo
```

## Pattern Matching

The `contents` field supports several selectors:

| Selector | Description | Example |
|----------|-------------|---------|
| `name` | Exact function name | `mediate` |
| `starts_with()` | Functions starting with prefix | `starts_with("calc_")` |
| `ends_with()` | Functions ending with suffix | `ends_with("_plot")` |
| `matches()` | Regex pattern match | `matches("^get_.*_data$")` |
| `-name` | Exclude function | `-internal_helper` |

## Generated Files

After running `quarto render`, you'll have:

```
reference/
├── _sidebar.yml          # Navigation (auto-generated)
├── index.qmd             # Function index page
├── function1.qmd         # Individual function docs
├── function2.qmd
└── ...
```

## Comparison with Alternatives

| Feature | quarto-rdocs | altdoc | pkgdown |
|---------|--------------|--------|---------|
| Config location | `_quarto.yml` | `altdoc/` folder | `_pkgdown.yml` |
| Renderer | Quarto native | Quarto/MkDocs/etc | Built-in |
| Section grouping | Yes (patterns) | Basic | Yes |
| Dark mode | Native toggle | Via Quarto | Manual |
| Install method | `quarto add` | `install.packages()` | `install.packages()` |

## Requirements

- Quarto >= 1.4.0
- R with packages: `yaml`, `tools`

## License

MIT
