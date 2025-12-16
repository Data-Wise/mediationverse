# quarto-rdocs Design Document

> **TL;DR**: A Quarto extension that converts R package `.Rd` files into beautiful documentation websites. Like pkgdown, but native to Quarto.

---

## 🎯 The Problem

```mermaid
flowchart LR
    subgraph Current["😤 Current Pain Points"]
        A[pkgdown] --> B[Separate from Quarto]
        A --> C[Own config file]
        A --> D[Can't mix with Quarto features]

        E[altdoc] --> F[Wrapper approach]
        E --> G[Multiple config locations]
        E --> H[Limited customization]
    end

    subgraph Goal["✨ What We Want"]
        I[Single _quarto.yml]
        J[Native Quarto features]
        K[Easy install: quarto add]
        L[Full theming control]
    end

    Current --> Goal
```

---

## 🏗️ Architecture Overview

```mermaid
flowchart TB
    subgraph Input["📥 INPUT"]
        RD[".Rd Files<br/>(roxygen2 output)"]
        NS["NAMESPACE<br/>(exports)"]
        CFG["_quarto.yml<br/>(config)"]
    end

    subgraph Process["⚙️ PROCESSING"]
        PR["Pre-render Script<br/>(R)"]
        PARSE["Parse .Rd"]
        CONVERT["Convert to .qmd"]
        GEN["Generate sidebar"]
    end

    subgraph Output["📤 OUTPUT"]
        QMD["reference/*.qmd"]
        SIDE["_sidebar.yml"]
        IDX["index.qmd"]
    end

    subgraph Render["🎨 QUARTO RENDER"]
        HTML["HTML Site"]
    end

    RD --> PR
    NS --> PR
    CFG --> PR

    PR --> PARSE --> CONVERT --> QMD
    PR --> GEN --> SIDE
    PR --> IDX

    QMD --> HTML
    SIDE --> HTML
    IDX --> HTML

    style Input fill:#e1f5fe
    style Process fill:#fff3e0
    style Output fill:#e8f5e9
    style Render fill:#fce4ec
```

---

## 📁 File Structure

```
your-package/
│
├── 📄 _quarto.yml          # ← All config lives here!
│
├── 📁 _extensions/
│   └── 📁 quarto-rdocs/    # ← The extension
│       ├── _extension.yml
│       ├── 📁 R/
│       │   ├── rd-parser.R      # Parse .Rd files
│       │   ├── qmd-generator.R  # Create .qmd files
│       │   └── rdocs-render.R   # Main entry point
│       └── 📁 scss/
│           └── rdocs.scss       # Styling
│
├── 📁 man/                 # ← Your .Rd files (input)
│   ├── function1.Rd
│   └── function2.Rd
│
├── 📁 reference/           # ← Generated docs (output)
│   ├── _sidebar.yml
│   ├── index.qmd
│   ├── function1.qmd
│   └── function2.qmd
│
└── 📁 docs/                # ← Final HTML (gitignored)
```

---

## 🔄 Data Flow

```mermaid
sequenceDiagram
    participant U as User
    participant Q as Quarto
    participant R as Pre-render (R)
    participant FS as File System

    U->>Q: quarto render
    Q->>R: Run pre-render script

    R->>FS: Read _quarto.yml
    R->>FS: Read NAMESPACE
    R->>FS: Read man/*.Rd

    loop For each function
        R->>R: Parse .Rd
        R->>R: Convert to Markdown
        R->>FS: Write reference/fn.qmd
    end

    R->>FS: Write reference/index.qmd
    R->>FS: Write reference/_sidebar.yml
    R->>Q: Done!

    Q->>Q: Render all .qmd to HTML
    Q->>FS: Write docs/
    Q->>U: Site ready! 🎉
```

---

## 🧩 Core Components

### 1️⃣ Rd Parser (`rd-parser.R`)

**Job**: Read `.Rd` files → Structured data

```mermaid
flowchart LR
    subgraph Input
        RD["mediationverse_packages.Rd"]
    end

    subgraph Parser
        T["tools::parse_Rd()"]
        E["Extract tags"]
    end

    subgraph Output
        L["List with:
        • name
        • title
        • description
        • usage
        • arguments
        • examples
        • ..."]
    end

    RD --> T --> E --> L
```

**Key Functions**:
| Function | Does What |
|----------|-----------|
| `parse_rd_file()` | Main parser |
| `extract_rd_tag()` | Get specific section |
| `extract_rd_arguments()` | Parse arguments table |
| `rd_to_text()` | Convert Rd markup → Markdown |

---

### 2️⃣ Qmd Generator (`qmd-generator.R`)

**Job**: Structured data → Quarto Markdown

```mermaid
flowchart LR
    subgraph Input
        L["Parsed List"]
    end

    subgraph Generator
        Y["YAML frontmatter"]
        H["# Headers"]
        T["Tables"]
        C["Code blocks"]
    end

    subgraph Output
        Q["function.qmd"]
    end

    L --> Y & H & T & C --> Q
```

**Output Template**:
```markdown
---
title: "function_name"
description: "Brief description"
---

# function_name {.function-name}

Description text...

## Usage
```r
function_name(arg1, arg2)
```

## Arguments
| Argument | Description |
|----------|-------------|
| `arg1`   | What it does |

## Examples
```r
# Example code
```
```

---

### 3️⃣ Pre-render Script (`rdocs-render.R`)

**Job**: Orchestrate everything

```mermaid
flowchart TB
    START([Start]) --> READ[Read _quarto.yml]
    READ --> CHECK{rdocs config?}

    CHECK -->|No| SKIP[Skip, exit]
    CHECK -->|Yes| FILES[Get .Rd files]

    FILES --> EXPORTS[Get exports from NAMESPACE]
    EXPORTS --> SECTIONS{Has sections?}

    SECTIONS -->|Yes| RESOLVE[Resolve patterns<br/>starts_with, ends_with, etc.]
    SECTIONS -->|No| ALL[Use all exports]

    RESOLVE --> LOOP
    ALL --> LOOP

    subgraph LOOP[For Each Function]
        PARSE[Parse .Rd]
        CONVERT[Convert to .qmd]
        WRITE[Write file]
        PARSE --> CONVERT --> WRITE
    end

    LOOP --> INDEX[Generate index.qmd]
    INDEX --> SIDEBAR[Generate _sidebar.yml]
    SIDEBAR --> DONE([Done!])
```

---

## ⚙️ Configuration

### Minimal Config
```yaml
rdocs:
  package: mypackage
```

### Full Config
```yaml
rdocs:
  package: mediationverse
  dir: reference
  sidebar: reference/_sidebar.yml

  sections:
    - title: "Core Functions"
      desc: "Main analysis functions"
      contents:
        - mediate
        - starts_with("calc_")
        - -internal_helper      # exclude

    - title: "Utilities"
      contents:
        - ends_with("_plot")

  options:
    examples: true     # Evaluate examples?
    freeze: true       # Cache results?
    source_links: true # GitHub links?
```

---

## 🎨 Pattern Matching

```mermaid
flowchart LR
    subgraph Patterns["Pattern Types"]
        E["exact_name"]
        S["starts_with('prefix')"]
        EN["ends_with('suffix')"]
        M["matches('regex')"]
        X["-excluded"]
    end

    subgraph Examples
        E --> E1["mediate"]
        S --> S1["calc_mean, calc_sd"]
        EN --> EN1["forest_plot, box_plot"]
        M --> M1["get_data, set_data"]
        X --> X1["Remove from list"]
    end
```

---

## 🔮 Future Enhancements

```mermaid
mindmap
  root((quarto-rdocs))
    Phase 1 ✅
      Basic Rd parsing
      Qmd generation
      Sidebar
      Sections
    Phase 2
      Cross-references
        downlit integration
        Package links
      Source links
        GitHub line numbers
    Phase 3
      Example caching
        Freeze support
        Incremental builds
      S7/R6 classes
        Method docs
        Inheritance
    Phase 4
      Versioning
        mike integration
        Version dropdown
      Search
        Custom ranking
        Code search
```

---

## 🆚 Comparison

| Feature | quarto-rdocs | altdoc | pkgdown |
|:--------|:------------:|:------:|:-------:|
| Config in `_quarto.yml` | ✅ | ❌ | ❌ |
| Install via `quarto add` | ✅ | ❌ | ❌ |
| Section grouping | ✅ | ⚠️ | ✅ |
| Pattern matching | ✅ | ❌ | ✅ |
| Native dark mode | ✅ | ✅ | ❌ |
| Quarto extensions | ✅ | ❌ | ❌ |
| Maturity | 🆕 | ⭐⭐ | ⭐⭐⭐ |

---

## 🚀 Quick Start

```bash
# 1. Add extension
quarto add Data-Wise/quarto-rdocs

# 2. Add to _quarto.yml
# rdocs:
#   package: yourpackage

# 3. Build!
quarto render
```

---

## 📊 Success Metrics

| Metric | Target |
|--------|--------|
| Build time (100 functions) | < 30s |
| Generated file size | ~5KB per function |
| Lighthouse score | > 90 |
| Works offline | ✅ |

---

## 🐛 Known Limitations

1. **No interactive examples** (yet) - Examples are static
2. **Single package** - Can't document multiple packages
3. **No API search** - Uses Quarto's basic search
4. **New project** - Less battle-tested than pkgdown

---

## 📚 References

- [Quarto Extensions](https://quarto.org/docs/extensions/)
- [quartodoc (Python equivalent)](https://github.com/machow/quartodoc)
- [pkgdown](https://pkgdown.r-lib.org/)
- [altdoc](https://github.com/etiennebacher/altdoc)
