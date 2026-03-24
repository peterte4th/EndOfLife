# EOL Explorer

A simple, attractive, single-file web app for exploring software lifecycle data from the endoflife.date API.

## What It Does

- Browses products from endoflife.date
- Filters by search text, category, status, and pinned-only mode
- Shows lifecycle status badges (Active, EOL Soon, EOL)
- Lets you pin products and keep those pins in local storage
- Provides a detailed product view with release/support lifecycle rows
- Provides a timeline view for pinned products
- Shows rich hover tooltips in timeline bars (release date, support milestones, latest release)

## Tech Stack

- Plain HTML, CSS, and JavaScript
- No build system
- No runtime dependencies

## Data Source

This project reads from:

- https://endoflife.date/api/v1/products
- https://endoflife.date/api/v1/products/{product}

## Project Files

- index.html: Main application (UI + logic)
- serve.sh: Start local static server using Ruby
- stop.sh: Stop server process by port

## Run Locally

1. Start server (default port 8080):

   ./serve.sh

2. Open in browser:

   http://localhost:8080/index.html

3. Stop server:

   ./stop.sh

### Custom Port

- Start on another port:

  ./serve.sh 9090

- Stop that port:

  ./stop.sh 9090

## Notes on Local vs file://

Serving over localhost is recommended instead of opening index.html via file://.

Why:

- Browser security behavior for API calls is more reliable over HTTP
- Storage/caching behavior is more consistent
- It matches deployment conditions

## Status Logic

EOL status is calculated from release lifecycle fields:

- Active: supported and not close to EOL
- EOL Soon: EOL date within the soon threshold
- EOL: release is past end-of-life

The current EOL Soon threshold is 12 months.

## Persistence and Caching

- Pinned products: localStorage
- Product detail responses: localStorage cache per product
- Product list response: sessionStorage

## Deployment

Because this is a static app, it can be deployed directly to static hosting:

- GitHub Pages
- Netlify
- Cloudflare Pages

## Known Constraints

- Timeline view focuses on pinned products for performance
- API availability/rate limiting can affect loading behavior

## License

No explicit license file is included yet.