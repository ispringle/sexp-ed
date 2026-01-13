# sexp-ed

A curated collection of resources to learn Lisp and its many dialects.

**Live site:** [sexp-ed.com](https://sexp-ed.com)

## About

sexp-ed is a single-page static website listing learning resources for:

- **Common Lisp** - The industrial-strength Lisp
- **Scheme** - The minimalist, elegant Lisp
- **Racket** - The language-oriented programming language
- **Clojure** - Modern Lisp for the JVM
- **Emacs Lisp** - Power your editor with Lisp
- **Janet** - Lightweight, embeddable Lisp
- And more: Fennel, Hy, LFE, Carp, Arc, Bel...

## Tech Stack

- **[Haunt](https://dthompson.us/projects/haunt.html)** - Static site generator written in Guile Scheme
- **SXML** - HTML templates using S-expressions (very Lispy!)
- **Docker** - Containerized build environment

## Development

### Prerequisites

Docker and Docker Compose are required. No need to install Guile or Haunt locally.

### Build the site

```bash
docker compose run --rm build
```

This generates the static site in the `site/` directory.

### Serve locally

```bash
docker compose up serve
```

Visit [http://localhost:8080](http://localhost:8080) to preview the site.

### Without Docker

If you have Guile and Haunt installed locally:

```bash
# Build
haunt build

# Serve
haunt serve
```

## Project Structure

```
sexp-ed/
├── haunt.scm              # Site configuration
├── Dockerfile             # Build environment
├── docker-compose.yml     # Build/serve commands
├── assets/
│   └── css/
│       └── style.css      # Playful, parentheses-inspired design
├── templates/
│   └── base.scm           # HTML template (navigation, footer)
├── pages/
│   └── index.scm          # All content and resources
└── site/                  # Generated output (gitignored)
```

## Deployment

The site automatically deploys to Cloudflare Pages when you push to `main`.

### Setup (one-time)

1. Create a Cloudflare Pages project named `sexp-ed`
2. In your GitHub repo, add these secrets (Settings → Secrets → Actions):
   - `CLOUDFLARE_API_TOKEN` - Create at [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens) with "Cloudflare Pages: Edit" permission
   - `CLOUDFLARE_ACCOUNT_ID` - Found in your Cloudflare dashboard URL or account settings

3. (Optional) Add custom domain `sexp-ed.com` in Cloudflare Pages settings

### Manual deploy

You can also trigger a deploy manually from the Actions tab using "Run workflow".

## Contributing

Contributions welcome! To add a resource:

1. Edit `pages/index.scm`
2. Add a `resource-card` to the appropriate section
3. Test locally with `docker compose up serve`
4. Submit a pull request

## License

Content is available under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).  
Code is available under the [MIT License](LICENSE).

---

*Made with ♥ and lots of parentheses*

