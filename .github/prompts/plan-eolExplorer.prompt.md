# Plan: EOL Explorer — Single-File Vanilla Web App

## Overview
Single `index.html` (no build step). Calls the endoflife.date v1 API. Three views behind a hash router: Dashboard, Product Detail, and Expiry Timeline. localStorage for pinned products and API response caching. Auto dark/light via `prefers-color-scheme`.

---

## API Summary
- Base: `https://endoflife.date/api/v1`
- `GET /products` → array of {name, label, category, tags, aliases}; 445 products
- `GET /products/{name}` → full product with `releases[]` array
- Release fields: name, label, releaseDate, isLts, ltsFrom, isEoas, eoasFrom, isEol, eolFrom, isMaintained, latest{name, date, link}
- Categories: os, lang, database, framework, server-app, app, service, device, standard

## Status Logic
From a product's releases, find releases where `isEol: false` (still supported):
- None found → product badge = "EOL" (red)
- Most recent such release's `eolFrom` < today+12mo → "EOL Soon" (amber)
- Otherwise → "Active" (green)

---

## Phase 1 — HTML Skeleton & CSS (independent)

1. **HTML structure**: `<header>` with app name, view nav tabs (Dashboard, Timeline). `<aside>` filter sidebar. `<main id="root">` content area.
2. **CSS custom properties**: Define `--color-bg`, `--color-surface`, `--color-text`, `--color-border`, `--color-accent` etc. under `:root` with `@media (prefers-color-scheme: dark)` override.
3. **Status badge colors**: `--status-active` (green), `--status-soon` (amber), `--status-eol` (red), `--status-unknown` (grey).
4. **Card grid**: `display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr))`.
5. **Sidebar layout**: Fixed-width aside on desktop, collapsible on mobile.
6. **Timeline CSS**: flex row with overflow-x scroll; `.gantt-bar` positioned with `left` + `width` percentages inside a relative container.

---

## Phase 2 — JS Infrastructure (sequential, builds base for all views)

7. **State object**: `{ currentView, searchText, selectedCategory, selectedStatus, showPinnedOnly, pinnedProducts: Set, detailCache: Map }`.
8. **localStorage helpers**:
   - `loadPins()` / `savePins()` — persist Set of pinned product names.
   - `loadCache(name)` / `saveCache(name, data)` — per-product JSON cache (no TTL; fresh enough for this use).
9. **Hash router**: `window.addEventListener('hashchange', route)`. Routes: `#dashboard` (default), `#product/{name}`, `#timeline`.
10. **API fetch wrapper** `fetchProduct(name)`: checks `loadCache(name)` first; if miss, fetches `https://endoflife.date/api/v1/products/{name}`, saves to cache, returns data. Rejects gracefully on 404/429.
11. **Products list fetch**: `fetchProductList()` — fetches `/products`, saves to sessionStorage (session-only, no need to persist across loads).

---

## Phase 3 — Dashboard View (depends on Phase 2)

12. **Render grid**: Load product list → filter by `searchText`, `selectedCategory`, `selectedStatus`, `showPinnedOnly` → render product cards.
13. **Product card**: shows label, category badge (colour per category), status badge (grey "?" until loaded), pin ★ toggle button; click → navigate to `#product/{name}`.
14. **Filter sidebar**: live-search `<input>`, category `<select>` (populated from unique categories), status button group (All / Active / EOL Soon / EOL), "Pinned only" toggle.
15. **Pinned-first startup**: on page load, immediately `fetchProduct(name)` for all pinned products, compute status, apply coloured badge.
16. **Lazy status for others**: `IntersectionObserver` on each card → trigger `fetchProduct` → compute status badge → update DOM.
17. **Status filter interaction**: status filter only operates on products whose status has been resolved; "unknown" cards are shown when filter is "All".

---

## Phase 4 — Product Detail View (depends on Phase 2)

18. **Header**: product label, category badge, tags, external link (endoflife.date/html page), pin/unpin button, back arrow → `#dashboard`.
19. **Releases table**: columns — Version, LTS, Released, Active Support Ends, EOL Date, Status, Latest. Sorted newest-first. Status badge per row using same logic.
20. **Row colour coding**: EOL rows visually de-emphasised (muted opacity), EOL Soon rows highlighted amber.

---

## Phase 5 — Expiry Timeline View (depends on Phase 2)

21. **Load data**: fetch details for all pinned products (from cache or API). Show spinner while loading.
22. **Time window**: compute min(releaseDate) across all active releases to max(eolFrom) + 30 days padding. Or fix to today-1yr → today+3yr for readability.
23. **Gantt layout**: each non-EOL release cycle = one row. Rows grouped by product (product name as section header). Bar width/position computed from time window as percentages.
24. **Today line**: absolutely-positioned vertical red line at today's position within the time window.
25. **Bar colours**: active (green), EOL soon <6mo (amber), already EOL (red, faded).
26. **Axis**: month/year ticks above the chart, auto-spaced.
27. **Click bar** → navigate to `#product/{name}`.
28. **Empty state**: "Pin products on the Dashboard to see them here."

---

## Phase 6 — Polish (can be done in parallel with phases 3–5)

29. **Loading skeleton**: cards with animated shimmer placeholder while data loads.
30. **Empty states**: no search results, no pins, API error/offline message.
31. **Responsive**: sidebar collapses to a hamburger/bottom drawer on narrow screens.
32. **Smooth view transitions**: fade-out/in on hash change (CSS class toggle).
33. **Product count**: "Showing X of 445 products" label beneath filters.

---

## Key Files
- `index.html` — the entire app (inline `<style>` + `<script>`)

## Relevant API Endpoints
- List: `https://endoflife.date/api/v1/products`
- Detail: `https://endoflife.date/api/v1/products/{name}`

## Scope
**Included**: Dashboard filtering, detail view, Gantt timeline, pinning, localStorage caching, auto dark/light.
**Excluded**: Server-side anything, build tooling, categories/tags filter (kept to category only per user request), identifier/purl browsing.

## Decisions
- Single HTML file; all CSS/JS inline — no dependencies, no bundler.
- Per-product localStorage caching (no TTL) keeps repeated visits fast.
- Product list fetched fresh each session (sessionStorage) to see new additions.
- Timeline limited to **pinned products only** — avoids loading hundreds of product details.
- EOL Soon threshold: 12 months from today.
