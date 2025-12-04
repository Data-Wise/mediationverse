# GitHub Setup Instructions

The mediationverse package is ready to be pushed to GitHub.

## Steps to Create GitHub Repository

1.  **Go to GitHub**:
    <https://github.com/organizations/data-wise/repositories/new>

2.  **Repository Settings**:

    - Repository name: `mediationverse`
    - Description:
      `Meta-package for the mediation analysis ecosystem in R`
    - Visibility: Public
    - **DO NOT** initialize with README, .gitignore, or license (we
      already have these)

3.  **Push to GitHub**:

    ``` bash
    cd ~/packages/mediationverse
    git remote add origin https://github.com/data-wise/mediationverse.git
    git branch -M main
    git push -u origin main
    ```

4.  **Set up GitHub Pages** (for pkgdown):

    ``` r
    usethis::use_pkgdown_github_pages()
    ```

5.  **Add to README.md** in data-wise organization:

    - Add mediationverse to the list of repositories
    - Link to <https://github.com/data-wise/mediationverse>

## Local Repository Status

- ✅ Git initialized
- ✅ Initial commit made (1279be5)
- ✅ All files tracked
- ⏳ Remote repository needs to be created manually
- ⏳ Push to GitHub pending

## Repository Location

**Local**: `~/packages/mediationverse/` **GitHub**:
<https://github.com/data-wise/mediationverse> (to be created)
