# quarto-rdocs Roadmap

> **One-liner**: Build the best R package documentation tool for Quarto.

---

## 🗺️ The Big Picture

```mermaid
timeline
    title quarto-rdocs Development Timeline

    section Phase 1
        MVP : Basic .Rd to .qmd
            : Section grouping
            : Sidebar generation

    section Phase 2
        Polish : Cross-references
               : Source links
               : Better styling

    section Phase 3
        Performance : Example caching
                    : Incremental builds
                    : Parallel processing

    section Phase 4
        Advanced : Version support
                 : S7/R6 classes
                 : Custom themes
```

---

## ✅ Phase 1: MVP (CURRENT)

**Goal**: Basic working extension

```mermaid
flowchart LR
    subgraph Done["✅ Done"]
        A[Rd Parser]
        B[Qmd Generator]
        C[Pre-render Script]
        D[Basic Styling]
        E[Section Config]
    end

    subgraph Todo["📋 Todo"]
        F[Pattern Matching]
        G[Index Page]
        H[Testing]
    end

    Done --> Todo
```

### Checklist

- [x] Parse `.Rd` files with `tools::parse_Rd()`
- [x] Convert Rd tags to Markdown
- [x] Generate function `.qmd` pages
- [x] Generate sidebar YAML
- [x] Basic SCSS styling
- [x] Section grouping in config
- [ ] `starts_with()` / `ends_with()` patterns
- [ ] Generate `index.qmd` with function table
- [ ] Unit tests

---

## 🔧 Phase 2: Polish

**Goal**: Feature parity with pkgdown basics

```mermaid
flowchart TB
    subgraph Features["Features to Add"]
        CR["Cross-references<br/>via downlit"]
        SL["Source links<br/>to GitHub"]
        DM["Dark mode<br/>improvements"]
        ST["Better styling<br/>for tables"]
    end

    subgraph Integration
        Q["Quarto<br/>native features"]
        GH["GitHub<br/>integration"]
    end

    Features --> Integration
```

### Checklist

- [ ] downlit integration for cross-package links
- [ ] Source code links (GitHub line numbers)
- [ ] Improve dark mode styling
- [ ] Better argument tables
- [ ] Value section formatting
- [ ] See Also section with proper links
- [ ] References/citations formatting

---

## ⚡ Phase 3: Performance

**Goal**: Fast builds for large packages

```mermaid
flowchart LR
    subgraph Current["😴 Current"]
        C1["Full rebuild<br/>every time"]
        C2["Sequential<br/>processing"]
    end

    subgraph Target["🚀 Target"]
        T1["Only changed<br/>files rebuild"]
        T2["Parallel<br/>processing"]
        T3["Cached<br/>examples"]
    end

    Current --> Target

    style Target fill:#e8f5e9
```

### Checklist

- [ ] Freeze support for evaluated examples
- [ ] Incremental builds (hash .Rd files)
- [ ] Parallel processing with `future`
- [ ] Skip unchanged files
- [ ] Build time reporting

### Performance Targets

| Package Size | Current | Target |
|--------------|---------|--------|
| 10 functions | ~5s | ~2s |
| 50 functions | ~25s | ~5s |
| 100 functions | ~50s | ~10s |

---

## 🎓 Phase 4: Advanced

**Goal**: Full-featured documentation platform

```mermaid
mindmap
  root((Phase 4))
    Versioning
      mike integration
      Version dropdown
      Old docs preserved
    Classes
      S7 support
      R6 support
      Method docs
      Inheritance trees
    Theming
      Custom themes
      Brand colors
      Logo support
    Ecosystem
      Multi-package
      Cross-linking
      Unified search
```

### Checklist

- [ ] Version support via mike
- [ ] S7 class documentation
- [ ] R6 class documentation
- [ ] Class inheritance diagrams
- [ ] Custom theme support
- [ ] Multi-package documentation
- [ ] Unified ecosystem search

---

## 🎯 Milestones

```mermaid
gantt
    title Development Milestones
    dateFormat  YYYY-MM-DD
    section Phase 1
    MVP Complete           :done,    m1, 2025-12-16, 1d
    Pattern Matching       :active,  m2, after m1, 3d
    Testing & Docs         :         m3, after m2, 2d

    section Phase 2
    Cross-references       :         m4, after m3, 5d
    Source Links           :         m5, after m4, 3d
    Styling Polish         :         m6, after m5, 3d

    section Phase 3
    Freeze/Caching         :         m7, after m6, 5d
    Incremental Builds     :         m8, after m7, 5d

    section Phase 4
    Versioning             :         m9, after m8, 7d
    Class Support          :         m10, after m9, 7d
```

---

## 🏆 Success Criteria

### Phase 1 ✓
> Can generate docs for mediationverse

### Phase 2
> Docs look as good as pkgdown

### Phase 3
> Builds are 5x faster than initial

### Phase 4
> Complete replacement for pkgdown

---

## 🤔 Open Questions

1. **Versioning**: Use mike or build our own?
2. **Search**: Quarto native or Algolia/Pagefind?
3. **Multi-package**: Single site or linked sites?
4. **Themes**: Port pkgdown themes or create new?

---

## 📝 Notes

### Why Not Just Use pkgdown?

| Reason | Details |
|--------|---------|
| **Quarto native** | Use all Quarto features (callouts, tabs, etc.) |
| **Single config** | Everything in `_quarto.yml` |
| **Extensible** | Compose with other Quarto extensions |
| **Modern** | Better dark mode, accessibility |

### Why Not Just Use altdoc?

| Reason | Details |
|--------|---------|
| **Simpler config** | No separate `altdoc/` folder |
| **Pattern matching** | pkgdown-style `starts_with()` |
| **Native integration** | Not a wrapper, uses pre-render |

---

## 🔗 Related Resources

- [Quarto Project Types](https://quarto.org/docs/extensions/project-types.html)
- [quartodoc for Python](https://machow.github.io/quartodoc/)
- [pkgdown source](https://github.com/r-lib/pkgdown)
- [altdoc source](https://github.com/etiennebacher/altdoc)
