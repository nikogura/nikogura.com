# nikogura.com

Personal website and blog for Nik Ogura — principal engineer, infrastructure architect, and security practitioner.

## Tech Stack

- [Astro](https://astro.build/) 5.x — static site generator
- [Tailwind CSS](https://tailwindcss.com/) 4.x — styling
- Based on the [Dante theme](https://github.com/JustGoodUI/dante-astro-theme) by JustGoodUI
- Deployed to GitHub Pages via GitHub Actions

## Development

```bash
npm install
npm run dev     # Start dev server at localhost:4321
npm run build   # Build for production
npm run preview # Preview production build
```

## Content

- **Blog posts**: `src/content/blog/` — Technical articles on Kubernetes, observability, GitOps, security, and engineering philosophy
- **Projects**: `src/content/projects/` — Open source project showcases
- **Pages**: `src/content/pages/` — About, Resume, Contact

## Deployment

Pushes to `main` trigger the GitHub Actions workflow at `.github/workflows/deploy.yml`, which builds and deploys to GitHub Pages at [nikogura.com](https://nikogura.com).
