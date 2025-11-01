# Implementation Plan: Dual Portfolio + E-commerce
## joelschaeffer.com - Cinematography & Photography

**Date Created:** 2025-11-01
**Status:** Ready to Implement
**Timeline:** 6-8 weeks (staged development, single launch)

---

## Architecture Summary

### Multi-Site Shared Infrastructure

```
                    AWS RDS PostgreSQL (Shared)
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   Payload Sites        Django API          Email
        │                   │                   │
  ┌─────┴─────┐      api.lightwave-     AWS SES
  │           │       media.ltd      @lightwave-media.ltd
  │           │                            │
joel          lightwave-                   │
schaeffer.    media.site              ┌────┴─────┐
com                                   │          │
                                 invoices@   joel.schaeffer@
                              lightwave-   lightwave-
                              media.ltd    media.ltd
```

**Legal Entity:** LightWave Media LLC (backs all commerce)
**Brand Fronts:** joelschaeffer.com (personal) + lightwave-media.site (company)

---

## Site Structure

### joelschaeffer.com

```
joelschaeffer.com
├── HOME (featured work carousel - mix of cinema + photo)
├── CINEMATOGRAPHY
│   ├── Features
│   ├── Commercials
│   ├── Music Videos
│   └── Short Films
│   └── CTAs: "Request Quote" → Invoice system
├── PHOTOGRAPHY
│   ├── Landscape
│   ├── Portrait
│   ├── Architecture
│   └── Abstract
│   └── CTAs: "Buy Print" → Shop product
├── SHOP
│   ├── Photography Prints (linked to portfolio via relatedArtwork field)
│   ├── Consulting Packages (fixed-price services)
│   └── Standard cart/checkout (Stripe)
├── ABOUT (bio, awards, resume PDF)
└── CONTACT

Footer: "© 2025 Joel Schaeffer. Powered by LightWave Media LLC"
```

---

## Key Architectural Decisions

### 1. Unified Artworks Collection (Portfolio Showcase)

**Decision:** Single "Artworks" collection with `type` field differentiation
**Why:** Simpler admin, easier featured work queries, shared fields, future-proof

```typescript
{
  title: "Sunset Over Golden Gate"
  type: "photography" | "cinematography"  // Discriminator
  slug: "sunset-golden-gate"
  mainImage: Upload                       // Both types
  videoEmbed: { platform, videoId }       // Cinematography only (conditional)
  additionalImages: []                    // Photography only (conditional)
  category: Relationship → Categories
  metadata: {
    // Cinematography: director, production
    // Photography: camera, filmStock
    // Both: location, captureDate, awards
  }
  featured: boolean                       // For homepage carousel
  status: "draft" | "published"
}
```

### 2. Products Collection (E-commerce - KEEP EXISTING)

**Decision:** Extend existing Products collection, don't replace
**Why:** E-commerce template already has robust product management

**Add to existing:**
```typescript
{
  // ... existing fields ...
  relatedArtwork: Relationship → Artworks  // NEW: Link prints to portfolio
  type: "print" | "consulting-package"     // NEW: Product categorization
}
```

### 3. Categories Collection (Updated)

**Decision:** Add `type` field to differentiate cinema vs photo categories
**Why:** Single collection, filtered by artwork type

```typescript
{
  name: "Features" | "Landscape" | etc.
  slug: "features" | "landscape"
  type: "cinematography" | "photography"  // NEW
  order: number                           // NEW: Display order
  coverImage: Upload
}
```

**Seed Categories:**
- **Cinematography:** Features, Commercials, Music Videos, Short Films
- **Photography:** Landscape, Portrait, Architecture, Abstract

### 4. Invoice System (NEW - lightwave-media-site)

**Decision:** Invoice collection lives in lightwave-media-site, accessed by joelschaeffer.com via shared database
**Why:** Centralized business operations under LightWave Media LLC

```typescript
// Defined in: lightwave-media-site payload.config.ts
// Accessed by: joelschaeffer.com (shared DB connection)

{
  invoiceNumber: "LWM-2025-001"
  project: "Joel Schaeffer - Commercial DP"
  client: { name, email, company }
  lineItems: [{ description, amount }]
  total: number
  status: "draft" | "sent" | "paid"
  paymentLink: string                     // Stripe payment link
  sentFrom: "joel.schaeffer@lightwave-media.ltd"
  dueDate: date
  createdBy: "joelschaeffer.com" | "lightwave-media.site"
}
```

### 5. Shared Database Strategy

**Decision:** Both Payload sites connect to same AWS RDS PostgreSQL instance
**Why:** Unified invoice system, single business entity, simpler infrastructure

**Connection:**
```typescript
// Both sites use same DATABASE_URL
DATABASE_URL=postgresql://payload_user:PASSWORD@lightwave-db.us-east-1.rds.amazonaws.com:5432/lightwave?schema=payload

// joelschaeffer.com payload.config.ts
db: postgresAdapter({
  pool: { connectionString: process.env.DATABASE_URL },
  schemaName: 'payload'  // Shared schema
})

// lightwave-media-site payload.config.ts
db: postgresAdapter({
  pool: { connectionString: process.env.DATABASE_URL },  // Same DB!
  schemaName: 'payload'  // Same schema!
})
```

**Note:** Template currently uses MongoDB adapter - needs migration to PostgreSQL

### 6. Email Configuration

**Decision:** All business emails from @lightwave-media.ltd domain
**Why:** Professional branding, centralized business communications

**Addresses:**
- `invoices@lightwave-media.ltd` - Invoice notifications
- `accounts@lightwave-media.ltd` - Payment confirmations
- `sales@lightwave-media.ltd` - Sales inquiries
- `info@lightwave-media.ltd` - General contact
- `joel.schaeffer@lightwave-media.ltd` - Joel's personal
- `noreply@lightwave-media.ltd` - System notifications

### 7. Video Hosting

**Decision:** Vimeo/YouTube embeds (NOT self-hosted on R2)
**Why:** Avoid bandwidth costs, better player UX, adaptive streaming

### 8. Navigation Structure

**Decision:** Flat hierarchy with dropdowns (Reed Morano style)
**Why:** Clean, professional, mobile-friendly, work-focused not design-focused

---

## Data Flow Examples

### Photography Purchase Flow
```
1. User browses /photography/landscape
2. Clicks "Sunset Over Golden Gate" artwork
3. Sees portfolio detail page with high-res gallery
4. Clicks "Buy Print" button
5. → Links to Shop product: "Sunset Print - 16x20 Fine Art"
   (Product.relatedArtwork = Artwork ID)
6. Adds to cart, checks out via Stripe
7. Order created in LightWave Media LLC account
```

### Cinematography Quote Flow
```
1. User browses /cinematography/commercials
2. Sees work examples with video embeds
3. Clicks "Request Quote" CTA
4. Fills out inquiry form
5. → Admin receives notification
6. → Admin creates Invoice in Payload (either site)
7. → System generates Stripe payment link
8. → Email sent from invoices@lightwave-media.ltd
9. → Client receives professional invoice email
10. → Client pays via Stripe link
11. → Invoice status updates to "paid"
12. → Confirmation email from accounts@lightwave-media.ltd
```

---

## Implementation Phases

### Phase 1: Core Portfolio (Weeks 1-2)

**Goal:** Dual portfolio showcase (cinematography + photography)

**Collections:**
- ✅ Create Artworks collection (unified with type field)
- ✅ Update Categories collection (add type, order fields)
- ✅ Seed 8 categories (4 cinema, 4 photo)
- ✅ Keep existing Products/Carts/Orders collections

**Frontend Pages:**
- ✅ `/cinematography` - Category grid landing
- ✅ `/cinematography/[category]` - Works in category
- ✅ `/photography` - Category grid landing
- ✅ `/photography/[category]` - Works in category
- ✅ `/work/[slug]` - Universal detail (adapts to type)
- ✅ `/` - Homepage with featured carousel

**Components:**
- ✅ VideoEmbed - Responsive Vimeo/YouTube player
- ✅ PhotoGallery - High-res lightbox
- ✅ CategoryGrid - Reusable category cards
- ✅ ArtworkGrid - Adapts to cinema/photo
- ✅ FeaturedCarousel - Homepage hero

**Navigation:**
- ✅ Update Header with dual dropdowns
- ✅ Mobile hamburger menu

**Keep Existing:**
- ✅ All shop/cart/checkout functionality (no changes)
- ✅ All e-commerce UI components

### Phase 2: E-commerce Integration (Weeks 3-4)

**Goal:** Link portfolio to shop, add consulting packages

**Products Collection Updates:**
- ✅ Add `relatedArtwork` field (prints link to portfolio)
- ✅ Add `type` field (print | consulting-package)

**Frontend:**
- ✅ "Buy Print" CTAs on photography detail pages
- ✅ "Request Quote" CTAs on cinematography pages
- ✅ Shop product pages display linked artwork
- ✅ Cart/checkout fully functional

**Stripe:**
- ✅ Configure for LightWave Media LLC
- ✅ Payment processing for shop products

### Phase 3: Invoice System (Weeks 5-6)

**Goal:** Client payment system for custom projects

**lightwave-media-site:**
- ✅ Create Invoice collection in Payload
- ✅ Invoice admin UI (create, edit, send)
- ✅ Generate Stripe payment links
- ✅ Email templates (professional, no marketing fluff)

**joelschaeffer.com:**
- ✅ "Request Quote" form creates invoice
- ✅ Access to invoice collection (shared DB)
- ✅ Invoices tagged with `createdBy: "joelschaeffer.com"`

**AWS SES Setup:**
- ✅ Verify lightwave-media.ltd domain
- ✅ Create SMTP credentials
- ✅ Configure Payload email adapter (both sites)
- ✅ Set up email aliases

### Phase 4: Infrastructure (Weeks 5-6)

**Goal:** Production-ready shared infrastructure

**AWS RDS PostgreSQL:**
- ✅ Create/configure shared database instance
- ✅ Set up `payload` schema
- ✅ Create database users (payload_user, readonly_user)
- ✅ Store credentials in AWS Secrets Manager
- ✅ Configure both Payload sites to connect

**AWS SES:**
- ✅ Verify lightwave-media.ltd domain
- ✅ Add DNS TXT records
- ✅ Create SMTP credentials for Payload
- ✅ Test email delivery

**Cloudflare R2:**
- ✅ Create bucket for media storage
- ✅ Generate R2 API tokens
- ✅ Configure Payload storage adapter

### Phase 5: Deployment (Weeks 7-8)

**Goal:** Live on Cloudflare Pages

**Git Setup:**
- ✅ Initialize repository (COMPLETED - init-git.sh created)
- ✅ Branch structure: main, develop, feature branches
- ✅ Conventional commits
- ✅ GitHub repository creation

**Cloudflare Pages:**
- ✅ Connect GitHub repository
- ✅ Configure build settings (pnpm build)
- ✅ Add environment variables
- ✅ Deploy to temp URL first
- ✅ Test functionality
- ✅ Configure custom domain (joelschaeffer.com)
- ✅ SSL certificate provisioning

**Testing:**
- ✅ Portfolio showcase (both types)
- ✅ Shop functionality (cart, checkout, Stripe)
- ✅ Invoice creation and payment
- ✅ Email delivery
- ✅ Mobile responsive
- ✅ Performance (Lighthouse 90+)

### Phase 6: Content & Launch (Week 8)

**Goal:** Launch with real content

- ✅ Populate cinematography works (video embeds)
- ✅ Populate photography portfolio
- ✅ Create shop products (prints linked to photos)
- ✅ Create consulting package products
- ✅ Test end-to-end workflows
- ✅ Final QA
- ✅ Launch announcement

---

## Current Status (2025-11-01)

### ✅ Completed
1. Repository renamed: `lightwave-e-com-template` → `lightwave-joelschaeffer-website`
2. package.json updated with new name and description
3. Architecture documented (this file + site research)
4. Git initialization script created (`init-git.sh`)
5. Comprehensive plan approved

### 🚧 In Progress
- Git repository initialization (blocked by bash session issue)

### ⏳ Next Steps
1. **Run init-git.sh script** to initialize git with proper branch structure
2. **Create GitHub repository** (`lightwave-media/lightwave-joelschaeffer-website`)
3. **Deploy to Cloudflare Pages** (temp URL for testing)
4. **Set up AWS infrastructure** (RDS, SES, R2)
5. **Begin Phase 1 implementation** (Artworks collection + frontend pages)

---

## Git Conventions (LightWave)

### Branch Structure
- `main` - Production code (protected)
- `develop` - Main integration branch (protected)
- `feature/portfolio/task-001-dual-portfolio-setup` - Current work

### Branch Naming
```
feature/{{domain}}/{{task-id}}-{{slug}}
fix/{{domain}}/{{task-id}}-{{slug}}
hotfix/v{{semver}}-{{slug}}
```

### Commit Format (Conventional Commits)
```
{{type}}({{scope}}): {{description}}

[optional body]

Relates: {{task-id}}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types:** feat, fix, build, chore, ci, docs, perf, refactor, revert, style, test

---

## Tech Stack Summary

**Frontend:**
- Next.js 15 + Payload CMS 3.x
- TypeScript, Tailwind CSS
- Hosting: Cloudflare Pages

**Database:**
- AWS RDS PostgreSQL (shared)
- Schema: `payload` (both sites)
- Migration: MongoDB → PostgreSQL needed

**Email:**
- AWS SES (@lightwave-media.ltd)
- Nodemailer adapter in Payload

**Storage:**
- Cloudflare R2 (S3-compatible)
- Images for both sites

**Payments:**
- Stripe (LightWave Media LLC account)
- Products + Invoices

**Backend (Phase 2+):**
- Django REST API
- Hosting: AWS ECS Fargate
- Domain: api.lightwave-media.ltd

---

## Important Notes

### What to KEEP from E-commerce Template
- ✅ **ALL product/cart/order collections** - Used for shop
- ✅ **ALL shop pages** - Fully functional e-commerce
- ✅ **Stripe integration** - Payment processing
- ✅ **Product management** - Print sales + packages
- ✅ **Navigation links** - Shop stays in main nav

### What to ADD
- ✅ **Artworks collection** - Portfolio showcase
- ✅ **Dual categories** - Cinema + photo types
- ✅ **Portfolio pages** - `/cinematography`, `/photography`
- ✅ **Video embeds** - Vimeo/YouTube support
- ✅ **Shared database connection** - Multi-site infrastructure
- ✅ **Invoice system access** - Client payment flow

### What to CHANGE
- ✅ **Database adapter** - MongoDB → PostgreSQL
- ✅ **Email configuration** - @lightwave-media.ltd domain
- ✅ **Footer branding** - Add "Powered by LightWave Media LLC"
- ✅ **Categories** - Add `type` and `order` fields

---

## Success Criteria

- ✅ Dual portfolio showcases cinematography (videos) + photography (galleries)
- ✅ Shop sells photography prints (linked to portfolio) + consulting packages
- ✅ Invoice system sends payment links for custom projects
- ✅ Clean navigation: Cinema | Photo | Shop | About | Contact
- ✅ All e-commerce functionality works (cart, checkout, Stripe)
- ✅ Emails sent from @lightwave-media.ltd domain
- ✅ Shared database works seamlessly with lightwave-media-site
- ✅ Mobile responsive, fast performance (Lighthouse 90+)
- ✅ Deployed to joelschaeffer.com with SSL
- ✅ Ready to accept clients and sell prints

---

## Reference Documents

**Project Context:**
- `00-project-overview.md` - Original 3-phase plan (needs update)
- `01-architecture-sad.md` - System architecture (needs update)
- `08-phase-1-implementation.md` - Original Phase 1 guide (superseded by this doc)
- `09-implementation-plan-dual-portfolio.md` - **THIS FILE** (current plan)

**Workspace:**
- `/Users/joelschaeffer/dev/lightwave-workspace/CLAUDE.md` - Workspace conventions
- `.agent/metadata/naming_conventions.yaml` - Git/naming conventions
- `.claude/ONBOARDING.md` - Session startup checklist

**Site Research:**
- www.joelschaeffer.com (current Wix site)
- reedmorano.com (cinematography inspiration)
- lik.com (photography inspiration)

---

**Status:** Ready for Implementation
**Next Chat:** Run `init-git.sh` to initialize repository, then begin Phase 1
**Maintained By:** Joel Schaeffer + Claude Code
