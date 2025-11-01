# Non-Functional Requirements: [joelschaeffer.com](http://joelschaeffer.com) Photography Portfolio

**Version:** 1.0.0

**Date:** 2025-11-01

**Author:** v_product_architect

**Status:** Approved

**Related Documents:** SAD v1.0.0, PRD v1.0.0

---

## Table of Contents

1. Introduction
2. Performance Requirements
3. Scalability Requirements
4. Availability & Reliability
5. Security Requirements
6. Usability Requirements
7. Maintainability Requirements
8. Compatibility Requirements
9. Monitoring & Observability
10. Compliance & Legal
11. Cost Constraints
12. Acceptance Criteria

---

## 1. Introduction

### 1.1 Purpose

This document defines the non-functional requirements (NFRs) for [joelschaeffer.com](http://joelschaeffer.com), a photography portfolio website with integrated print shop functionality. These requirements specify **how well** the system must perform, not **what** it does (which is covered in the PRD).

### 1.2 Scope

These NFRs apply to:

- **Phase 1 MVP:** Photography portfolio + basic print information (no e-commerce checkout)
- **Foundation:** All architectural decisions must support future Phase 2 expansion

### 1.3 Priority Levels

- **P0 (Critical):** Must be met for MVP launch
- **P1 (High):** Should be met for MVP, can be addressed in hotfix
- **P2 (Medium):** Nice to have for MVP, can be deferred to Phase 2
- **P3 (Low):** Future enhancement, not required for initial launch

---

## 2. Performance Requirements

### 2.1 Page Load Performance (P0)

**Requirement:** All pages must meet Core Web Vitals "Good" thresholds on 75th percentile.

**Metrics:**

- **Largest Contentful Paint (LCP):** ≤ 2.5 seconds
- **First Input Delay (FID):** ≤ 100 milliseconds
- **Cumulative Layout Shift (CLS):** ≤ 0.1
- **First Contentful Paint (FCP):** ≤ 1.8 seconds
- **Time to Interactive (TTI):** ≤ 3.5 seconds

**Measurement:**

- Test on Cloudflare Analytics and Google PageSpeed Insights
- Test conditions: Desktop (Fast 3G), Mobile (4G)
- Measured from global edge locations (US, Europe, Asia)

**Acceptance:**

- Homepage: LCP < 2.0s, CLS < 0.05
- Gallery page: LCP < 2.5s, CLS < 0.1
- Artwork detail: LCP < 2.0s, CLS < 0.05

---

### 2.2 Image Delivery Performance (P0)

**Requirement:** Images must load progressively with modern format delivery.

**Metrics:**

- Thumbnail images (400x300): < 50KB each
- Card images (768x1024): < 150KB each
- Tablet images (1024xAuto): < 250KB each
- Original images: < 3MB (with progressive JPEG encoding)

**Implementation:**

- Serve WebP to supporting browsers (90%+ of traffic)
- Fallback to optimized JPEG for older browsers
- Lazy load images below the fold
- Use `loading="lazy"` attribute on `<img>` tags
- Implement blur-up placeholder (LQIP) for smooth loading

**Acceptance:**

- Gallery grid with 20 images loads in < 3 seconds (P95)
- Individual artwork image loads in < 1.5 seconds (P95)

---

### 2.3 API Response Time (P0)

**Requirement:** API endpoints must respond quickly under normal load.

**Metrics (P95):**

- `GET /api/artworks` (list): ≤ 300ms
- `GET /api/artworks/slug/:slug` (detail): ≤ 200ms
- `POST /api/artworks` (create, admin): ≤ 500ms
- `POST /api/media` (upload, admin): ≤ 3s for 10MB file

**Measurement:**

- Measured from API gateway (Cloudflare Edge)
- Normal load: < 10 concurrent requests
- Database query time should be < 50ms for indexed queries

**Acceptance:**

- 95% of API requests complete within target times
- No timeout errors (30s limit) under normal conditions

---

### 2.4 Build & Deployment Performance (P1)

**Requirement:** Fast iteration cycle for content updates.

**Metrics:**

- Full site build (Next.js): ≤ 3 minutes
- Incremental build (ISR): ≤ 30 seconds per page
- Cloudflare Pages deployment: ≤ 5 minutes total
- Cache invalidation: ≤ 30 seconds global propagation

**Acceptance:**

- Artwork publish → live on site: < 10 minutes end-to-end
- Critical hotfix deploy: < 15 minutes from commit to live

---

## 3. Scalability Requirements

### 3.1 Traffic Scalability (P0)

**Requirement:** System must handle traffic spikes without degradation.

**Load Targets:**

- **Normal traffic:** 100 concurrent users, 1,000 pageviews/hour
- **Peak traffic (social media spike):** 1,000 concurrent users, 10,000 pageviews/hour
- **Sustained peak:** Maintain peak for 2+ hours without failure

**Auto-Scaling:**

- Cloudflare CDN handles unlimited edge requests
- Cloudflare Pages serverless scales automatically (no config needed)
- Neon PostgreSQL auto-scales compute (0.25 - 4 CU range)

**Acceptance:**

- No 503/504 errors during 10x traffic spike
- API response times remain within P95 targets under peak load
- Page load times increase < 20% under peak load

---

### 3.2 Content Scalability (P1)

**Requirement:** System must handle large artwork catalog efficiently.

**Capacity Targets (Phase 1):**

- **Artworks:** Support up to 500 published artworks
- **Images:** Support up to 2,000 images (4 per artwork avg)
- **Storage:** Support up to 100GB of image data
- **Database:** Support up to 10GB of metadata

**Capacity Targets (Phase 2+):**

- **Artworks:** Support up to 5,000 artworks
- **Images:** Support up to 20,000 images
- **Storage:** Support up to 1TB of image data

**Performance at Scale:**

- Gallery page load time must remain < 3s with 500 artworks (paginated)
- Database queries must remain < 100ms with 5,000 artworks
- Image upload processing must remain < 10s per image

**Acceptance:**

- Test with 500 artworks: gallery loads in < 2.5s
- Test with 100 concurrent uploads: all complete successfully

---

### 3.3 Database Scalability (P1)

**Requirement:** Database must scale with content growth.

**Query Performance:**

- Indexed queries (by slug, status, category): < 50ms
- Full-text search (future): < 200ms
- Complex joins (artwork + media): < 100ms
- Pagination queries: < 50ms per page

**Connection Pooling:**

- Neon serverless handles connection pooling automatically
- Max connections: 100 concurrent (default)
- Connection timeout: 30 seconds

**Acceptance:**

- All queries remain under target times with 5,000 artworks
- No connection pool exhaustion under peak load

---

## 4. Availability & Reliability

### 4.1 Uptime (P0)

**Requirement:** Site must be highly available to users.

**Target SLA:**

- **Uptime:** 99.9% monthly (max 43 minutes downtime/month)
- **Planned maintenance:** < 1 hour/month, scheduled during low-traffic windows
- **Emergency hotfix:** < 15 minutes to deploy critical security fix

**Dependencies:**

- Cloudflare Pages SLA: 99.99%
- Neon PostgreSQL SLA: 99.95%
- Cloudflare R2 SLA: 99.9%

**Acceptance:**

- No single point of failure in architecture
- Cloudflare edge redundancy across 200+ locations
- Automated health checks every 5 minutes

---

### 4.2 Error Rate (P0)

**Requirement:** System must minimize errors for users.

**Target Error Rates:**

- **Client errors (4xx):** < 1% of requests
- **Server errors (5xx):** < 0.1% of requests
- **Failed image loads:** < 0.5% of image requests
- **Failed API calls:** < 0.5% of API requests

**Error Handling:**

- Graceful degradation for missing images (placeholder)
- User-friendly error messages (no stack traces)
- Automatic retry for transient failures (3 attempts, exponential backoff)

**Acceptance:**

- All error rates remain below targets for 30 consecutive days
- No user-reported "site down" incidents

---

### 4.3 Data Durability (P0)

**Requirement:** User data (images, metadata) must not be lost.

**Backup Strategy:**

- **PostgreSQL (Neon):** Daily automated backups, 7-day retention
- **Cloudflare R2:** Enable versioning for accidental deletion recovery
- **Git:** All code and config in version control

**Recovery Targets:**

- **Recovery Point Objective (RPO):** < 24 hours (max data loss)
- **Recovery Time Objective (RTO):** < 2 hours (max downtime)

**Disaster Recovery:**

- Database: Point-in-time recovery available (Neon)
- Images: R2 versioning allows undelete within 30 days
- Code: Git history allows rollback to any previous commit

**Acceptance:**

- Successful backup restoration test before launch
- Document recovery procedures in runbook

---

### 4.4 Graceful Degradation (P1)

**Requirement:** Site must remain functional if dependencies fail.

**Fallback Behaviors:**

- **R2 unavailable:** Show cached images, display placeholder for new requests
- **Database unavailable:** Serve cached pages, show maintenance message for admin
- **API timeout:** Show cached data, display "try again" message
- **JavaScript disabled:** Core content still readable (progressive enhancement)

**Acceptance:**

- Gallery page loads with cached data if API times out
- Artwork pages display with stale data if database is slow

---

## 5. Security Requirements

### 5.1 Authentication & Authorization (P0)

**Requirement:** Admin access must be secure, public access unrestricted.

**Admin Authentication:**

- JWT-based authentication (Payload default)
- Secure password requirements: min 12 chars, uppercase, lowercase, number, symbol
- Session timeout: 24 hours of inactivity
- HTTP-only cookies (prevent XSS token theft)
- Bcrypt password hashing (cost factor 12)

**Authorization:**

- Admin-only: Create, update, delete artworks/pages/media
- Public: Read published artworks and pages
- No anonymous write access (except contact form in Phase 2)

**Acceptance:**

- Penetration test shows no auth bypass vulnerabilities
- Admin session expires after 24 hours
- Failed login attempts rate-limited (5 attempts/15 minutes)

---

### 5.2 Data Protection (P0)

**Requirement:** Data must be encrypted in transit and at rest.

**Encryption in Transit:**

- HTTPS/TLS 1.3 for all connections (enforced by Cloudflare)
- HSTS header with 1-year max-age
- No mixed content (all resources served over HTTPS)

**Encryption at Rest:**

- PostgreSQL: AES-256 encryption (Neon default)
- R2: Server-side encryption enabled (AES-256)
- Admin passwords: Bcrypt hashed (never plaintext)

**Acceptance:**

- SSL Labs test: A+ rating
- No plaintext credentials in logs or config files
- All environment variables encrypted (Cloudflare secrets)

---

### 5.3 Input Validation (P0)

**Requirement:** All user inputs must be validated and sanitized.

**File Upload Validation:**

- File type whitelist: JPEG, PNG, WebP, GIF only
- Max file size: 20MB per upload
- Image dimensions: Max 10,000px width or height
- Filename sanitization: Remove special chars, max 255 chars

**API Input Validation:**

- Payload schema validation for all fields
- TypeScript type checking at compile time
- SQL injection prevention (parameterized queries via ORM)
- XSS prevention (sanitize rich text, escape output)

**Rate Limiting:**

- Unauthenticated API: 60 requests/minute per IP
- Authenticated API: 300 requests/minute per user
- File upload: 10 uploads/hour per admin user

**Acceptance:**

- OWASP Top 10 vulnerabilities tested and mitigated
- No SQL injection, XSS, or CSRF vulnerabilities found

---

### 5.4 DDoS Protection (P0)

**Requirement:** Site must resist denial-of-service attacks.

**Cloudflare Protection:**

- DDoS mitigation at edge (built-in, always on)
- Bot detection and challenge (automatic)
- Rate limiting for suspicious traffic patterns
- Geographic blocking if needed (configurable)

**Acceptance:**

- Site remains accessible during simulated DDoS (load test)
- Cloudflare blocks malicious traffic before reaching origin

---

### 5.5 Security Headers (P1)

**Requirement:** HTTP security headers must be configured.

**Required Headers:**

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
Content-Security-Policy: (see below)
```

**Content Security Policy:**

```
default-src 'self';
img-src 'self' https://cdn.joelschaeffer.com https://r2.cloudflarestorage.com;
script-src 'self' 'unsafe-inline' 'unsafe-eval';
style-src 'self' 'unsafe-inline';
font-src 'self';
connect-src 'self' https://api.joelschaeffer.com;
```

**Acceptance:**

- Security Headers scan: A+ rating ([securityheaders.com](http://securityheaders.com))

---

## 6. Usability Requirements

### 6.1 Responsive Design (P0)

**Requirement:** Site must work seamlessly on all device sizes.

**Breakpoints:**

- **Mobile:** 320px - 767px (portrait phones)
- **Tablet:** 768px - 1023px (tablets, landscape phones)
- **Desktop:** 1024px - 1919px (laptops, desktops)
- **Large Desktop:** 1920px+ (large monitors)

**Mobile-First:**

- Touch-friendly tap targets (min 44x44px)
- No horizontal scrolling required
- Readable text without zooming (min 16px font)
- Gallery grid: 1 column mobile, 2 tablet, 3-4 desktop

**Acceptance:**

- Manual testing on iPhone 14, iPad, MacBook, 4K monitor
- Google Mobile-Friendly Test: Pass
- No layout breaking at any viewport width 320px - 2560px

---

### 6.2 Accessibility (P1)

**Requirement:** Site must be usable by people with disabilities.

**WCAG 2.1 Level AA Compliance:**

- **Perceivable:** Alt text for all images, color contrast ratio ≥ 4.5:1
- **Operable:** Keyboard navigation, focus indicators, skip links
- **Understandable:** Clear labels, error messages, consistent navigation
- **Robust:** Valid HTML, ARIA landmarks, semantic structure

**Specific Requirements:**

- All images have descriptive alt text (never "image" or filename)
- All interactive elements keyboard accessible (tab order)
- Focus visible with 2px outline on interactive elements
- No content triggered by hover only (must have click/tap alternative)
- Headings follow semantic hierarchy (h1 → h2 → h3)

**Acceptance:**

- WAVE accessibility checker: Zero errors
- Lighthouse accessibility score: ≥ 90
- Screen reader test (VoiceOver/NVDA): All content accessible

---

### 6.3 Browser Compatibility (P0)

**Requirement:** Site must work on modern browsers.

**Supported Browsers:**

- **Desktop:** Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- **Mobile:** iOS Safari 14+, Chrome Android 90+
- **Market Coverage:** ≥ 95% of global browser usage

**Progressive Enhancement:**

- Core content accessible without JavaScript
- Enhanced features (image zoom, filtering) require JavaScript
- No IE11 support (< 1% market share)

**Acceptance:**

- BrowserStack testing: All features work on target browsers
- Graceful degradation on unsupported browsers (show message)

---

### 6.4 Admin UX (P1)

**Requirement:** Admin interface must be intuitive for non-technical user.

**Payload CMS Usability:**

- Single-click image upload with drag-and-drop
- Preview artwork before publishing
- Bulk actions (publish multiple artworks)
- Clear validation error messages
- Auto-save drafts every 30 seconds

**Acceptance:**

- Joel can upload and publish artwork in < 5 minutes (no training)
- No confusion or support requests during first week of use

---

## 7. Maintainability Requirements

### 7.1 Code Quality (P1)

**Requirement:** Codebase must be clean, documented, and testable.

**Standards:**

- **TypeScript:** 100% coverage (no `any` types)
- **Linting:** ESLint with Airbnb config, zero warnings
- **Formatting:** Prettier with consistent style
- **Naming:** PascalCase components, camelCase functions, UPPER_SNAKE env vars

**Documentation:**

- README with setup instructions, architecture overview
- Inline comments for complex logic (not obvious code)
- JSDoc comments for public functions/components
- API documentation (this document)

**Acceptance:**

- New developer can set up local environment in < 30 minutes
- All exported functions have TypeScript types
- ESLint/Prettier pass with zero errors

---

### 7.2 Testing (P2)

**Requirement:** Critical functionality must have automated tests.

**Test Coverage (Future):**

- **Unit tests:** Key utility functions, data transforms
- **Component tests:** React components in isolation
- **Integration tests:** API endpoints, database queries
- **E2E tests:** Critical user flows (view gallery, view artwork)

**Target Coverage (Phase 2):**

- Unit: ≥ 80% line coverage
- E2E: 100% of critical user paths

**Acceptance (Phase 1):**

- Manual smoke test checklist documented
- At least one E2E test for gallery page (Playwright)

---

### 7.3 Deployment (P0)

**Requirement:** Deployments must be safe, fast, and reversible.

**CI/CD Pipeline:**

- Auto-deploy on merge to `main` branch
- Linting and type-checking in CI (GitHub Actions)
- Preview deploy for every PR
- Atomic deploys (all-or-nothing, no partial updates)
- One-click rollback to previous version

**Zero-Downtime Deployment:**

- Cloudflare Pages deploys new version alongside old
- Traffic switches to new version atomically
- Old version remains accessible for rollback

**Acceptance:**

- Deploy completes in < 5 minutes (commit to live)
- Zero downtime observed during deployment
- Rollback completes in < 2 minutes

---

### 7.4 Monitoring & Logging (P1)

**Requirement:** System health must be observable.

**Metrics to Track:**

- **Application:** Page views, API requests, error rate, response time
- **Infrastructure:** CDN cache hit rate, database connections, R2 storage used
- **Business:** Artwork views, print inquiries (Phase 2), conversion rate

**Logging:**

- Server errors logged to Cloudflare Workers logs
- Database slow queries logged (> 1s)
- Failed uploads logged with error details
- Admin actions audit log (create, update, delete)

**Alerting (Phase 2):**

- Email/SMS for critical errors (5xx rate > 1%)
- Email for site down (uptime check fails)

**Acceptance:**

- Cloudflare Analytics dashboard shows all key metrics
- Error logs accessible and searchable

---

## 8. Compatibility Requirements

### 8.1 Device Compatibility (P0)

**Requirement:** Site must work on common devices.

**Tested Devices:**

- **Phones:** iPhone 14 Pro, Samsung Galaxy S23, Google Pixel 7
- **Tablets:** iPad Pro 12.9", iPad Air, Samsung Galaxy Tab
- **Laptops:** MacBook Air M2, Dell XPS 13, Lenovo ThinkPad
- **Desktops:** iMac 27", Windows desktop with 4K monitor

**Acceptance:**

- All layouts work correctly on tested devices
- Images load and display properly on all devices
- Touch gestures work on mobile/tablet (pinch zoom, swipe)

---

### 8.2 Network Compatibility (P1)

**Requirement:** Site must be usable on slow connections.

**Network Conditions:**

- **Fast:** 4G LTE, Cable/Fiber (10+ Mbps)
- **Moderate:** 3G, Slow 4G (1-5 Mbps)
- **Slow:** Slow 3G, Edge (< 1 Mbps)

**Performance Targets:**

- **Fast:** Full gallery loads in < 2s
- **Moderate:** Full gallery loads in < 5s
- **Slow:** Critical content (hero image) loads in < 8s

**Acceptance:**

- Chrome DevTools network throttling test passes
- Lighthouse test with "Slow 4G" setting: score ≥ 70

---

## 9. Monitoring & Observability

### 9.1 Real User Monitoring (P1)

**Requirement:** Track actual user experience metrics.

**Tools:**

- Cloudflare Web Analytics (privacy-first, no cookies)
- Google Analytics 4 (optional, with cookie consent)

**Metrics to Track:**

- Page views, unique visitors, session duration
- Core Web Vitals (LCP, FID, CLS) from real users
- Top pages, entry pages, exit pages
- Device breakdown (mobile vs desktop)
- Geographic distribution (country, city)

**Acceptance:**

- Analytics dashboard accessible to Joel
- Data retention: 90 days minimum

---

### 9.2 Error Tracking (P2)

**Requirement:** Capture and diagnose runtime errors.

**Error Tracking (Phase 2):**

- Tool: Sentry or similar
- Capture: Client-side JavaScript errors, API errors
- Context: User agent, URL, stack trace, breadcrumbs
- Notifications: Email for high-priority errors

**Acceptance (Phase 2):**

- All uncaught errors reported to Sentry
- Error reports include full context for debugging

---

## 10. Compliance & Legal

### 10.1 Privacy (P1)

**Requirement:** Comply with privacy regulations.

**Data Collection (Phase 1):**

- No personal data collected from public visitors
- Admin email/password stored securely (encrypted)
- Cloudflare Analytics: Privacy-first, no cookies, GDPR-compliant

**Privacy Policy (Phase 2):**

- Required when adding contact form or checkout
- Must disclose: What data collected, how used, who has access
- GDPR compliance: Right to access, delete, export data

**Acceptance:**

- No cookies set for public visitors (confirm in DevTools)
- Admin password never logged or transmitted unencrypted

---

### 10.2 Copyright & Licensing (P0)

**Requirement:** Respect intellectual property rights.

**Image Rights:**

- All images owned by Joel Schaeffer (copyright holder)
- Copyright notice in footer: "© 2025 Joel Schaeffer. All rights reserved."
- DMCA compliance: Takedown procedure documented

**Third-Party Code:**

- All dependencies open-source with compatible licenses (MIT, Apache 2.0)
- License file in repository (MIT license for project)

**Acceptance:**

- Copyright notice visible on all pages
- No unlicensed third-party code in production

---

## 11. Cost Constraints

### 11.1 Infrastructure Costs (P0)

**Requirement:** Keep monthly costs under budget.

**Budget (Phase 1):**

- **Total:** < $50/month
- **Breakdown:**
    - Cloudflare Pages: $0 (free tier sufficient)
    - Cloudflare R2: ~$5/month (100GB storage + 1TB egress free)
    - Neon PostgreSQL: $0-$19/month (free tier → Pro if needed)
    - Domain: $12/year (already owned)

**Cost Scaling:**

- R2: $0.015/GB/month storage, $0 egress (Cloudflare CDN)
- Neon: $19/month Pro (3 projects, 200GB storage, autoscaling compute)
- Pages: Free for unlimited requests (no bandwidth charges)

**Acceptance:**

- First month bill: < $10
- Projected costs at 10x traffic: < $50/month

---

## 12. Acceptance Criteria

### 12.1 Launch Readiness Checklist

**P0 Requirements (Must Pass):**

- [ ]  LCP < 2.5s on gallery page (P95)
- [ ]  All images load correctly in gallery and detail pages
- [ ]  Admin can upload and publish artwork successfully
- [ ]  Site accessible on mobile, tablet, desktop
- [ ]  HTTPS enforced with valid SSL certificate
- [ ]  No JavaScript console errors on public pages
- [ ]  Gallery pagination works (if >50 artworks)
- [ ]  Artwork detail pages have correct meta tags (SEO)
- [ ]  Copyright notice displayed in footer
- [ ]  Admin authentication works (login, logout, session)

**P1 Requirements (Should Pass):**

- [ ]  Lighthouse score ≥ 85 (Performance, Accessibility, Best Practices, SEO)
- [ ]  WAVE accessibility check: Zero critical errors
- [ ]  Mobile-friendly test: Pass
- [ ]  SSL Labs: A rating or higher
- [ ]  API response times < 300ms (P95)
- [ ]  Cloudflare Analytics installed and tracking

**P2 Requirements (Nice to Have):**

- [ ]  One E2E test for critical path (gallery view)
- [ ]  Error tracking (Sentry) configured
- [ ]  Automated backup restoration tested

---

### 12.2 Performance Benchmarks

**Baseline Measurements (Before Launch):**

| Metric | Target | Actual | Status |
| --- | --- | --- | --- |
| Gallery LCP | < 2.5s | TBD | ⏳ |
| Artwork LCP | < 2.0s | TBD | ⏳ |
| API Response (list) | < 300ms | TBD | ⏳ |
| API Response (detail) | < 200ms | TBD | ⏳ |
| Lighthouse Performance | ≥ 85 | TBD | ⏳ |
| Lighthouse Accessibility | ≥ 90 | TBD | ⏳ |
| Image Upload Time (10MB) | < 3s | TBD | ⏳ |

**Post-Launch Monitoring:**

- Track all metrics weekly for first month
- Alert if any metric degrades > 20% from baseline
- Monthly review and optimization if needed

---

## Document Metadata

**Related Documents:**

- PRD: LWM [joelschaeffer.com](http://joelschaeffer.com) Photography Site - PRD - v1.0.0
- SAD: LWM [joelschaeffer.com](http://joelschaeffer.com) - SAD - v1.0.0
- DDD: LWM [joelschaeffer.com](http://joelschaeffer.com) - DDD: Payload CMS + Cloudflare R2 Integration - v1.0.0
- API Spec: LWM [joelschaeffer.com](http://joelschaeffer.com) - API Spec - v1.0.0
- Sprint: Sprint 1: [joelschaeffer.com](http://joelschaeffer.com) Foundation Build

**Review Cycle:** Quarterly or before major architecture changes

**Maintained By:** v_product_architect + Joel Schaeffer

**Last Updated:** 2025-11-01

**Status:** Approved for Sprint 1 execution