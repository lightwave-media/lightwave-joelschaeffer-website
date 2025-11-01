# Joel Schaeffer Photography Website - Quick Reference

**Project**: Joel Schaeffer Photography Website (adapted from Payload E-commerce Template)
**Purpose**: Photography portfolio with integrated print shop
**Status**: Phase 1 Implementation - Gallery Only
**Repository**: lightwave-workspace/Frontend/lightwave-e-com-template → lightwave-joelschaeffer-website
**Domain**: https://joelschaeffer.com

---

## 🎯 3-Phase Development Roadmap

### Phase 1: Gallery Portfolio (CURRENT - 2 weeks)
**Goal**: Launch photography gallery with admin CMS

- ✅ Photography gallery display
- ✅ Payload CMS for content management
- ✅ AWS RDS PostgreSQL database (direct connection)
- ✅ AWS SES email (direct connection)
- ✅ Cloudflare R2 for photo storage
- ✅ Deployed to Cloudflare Pages
- ❌ No print shop yet
- ❌ No Django backend yet

### Phase 2: Add Django Backend (+4 weeks)
**Goal**: Backend API for analytics, email service

- ✅ Django REST API on AWS ECS
- ✅ Shared AWS RDS (separate schemas)
- ✅ Email service moves to Django
- ✅ Analytics and reporting
- ❌ Still no print shop

### Phase 3: Print Shop E-commerce (+6 weeks)
**Goal**: Full e-commerce with Stripe integration

- ✅ Print shop checkout flow
- ✅ Stripe payments (via Django backend)
- ✅ Order management
- ✅ Customer accounts

---

## Tech Stack Summary

| Layer | Phase 1 (Now) | Phase 2 (Backend) | Phase 3 (E-commerce) |
|-------|---------------|-------------------|----------------------|
| **Frontend** | Next.js 15 + Payload CMS | Same | Same |
| **Database** | AWS RDS PostgreSQL (`payload` schema) | AWS RDS (`payload` + `django` schemas) | Same (shared) |
| **Backend** | None | Django on AWS ECS | Same |
| **Email** | Payload → AWS SES (direct) | Django → AWS SES | Same |
| **Storage** | Cloudflare R2 | Same | Same |
| **Payments** | None | None | Django → Stripe |
| **Deployment** | Cloudflare Pages | + AWS ECS | Same |

---

## Current Architecture (Phase 1)

```
┌─────────────────────────────────────┐
│  Cloudflare Pages                   │
│  ┌──────────────────────────────┐   │
│  │ Payload CMS + Next.js        │   │
│  │ (joelschaeffer.com)          │   │
│  └───────┬──────────────┬───────┘   │
└──────────┼──────────────┼───────────┘
           │              │
           ↓              ↓
    ┌──────────┐   ┌──────────┐
    │ AWS RDS  │   │ AWS SES  │
    │PostgreSQL│   │  Email   │
    │ (payload │   └──────────┘
    │  schema) │
    └──────────┘
```

---

## Project Structure

```
lightwave-joelschaeffer-website/
├── src/
│   ├── app/                      # Next.js App Router pages
│   │   ├── (pages)/              # Public pages
│   │   │   ├── gallery/          # Photography gallery
│   │   │   ├── artwork/[slug]/   # Individual artwork pages
│   │   │   └── about/            # About page
│   │   ├── (admin)/              # Payload admin UI
│   │   └── api/                  # API routes
│   ├── blocks/                   # Payload layout builder blocks
│   │   ├── Hero/                 # Hero sections
│   │   ├── Gallery/              # Gallery grids
│   │   └── ArtworkDetail/        # Artwork detail blocks
│   ├── collections/              # Payload collections
│   │   ├── Artworks/             # Photography artworks (MAIN)
│   │   ├── Categories/           # Portfolio categories
│   │   ├── Pages/                # Content pages
│   │   ├── Media/                # Photo uploads
│   │   └── Users/                # Admin users
│   └── payload.config.ts         # Payload configuration
├── .env.local                    # Local development
└── .env.production              # Production (Cloudflare Pages)
```

---

## Development Commands

```bash
# Install dependencies
pnpm install

# Start local development
pnpm dev

# Build for production
pnpm build

# Run tests
pnpm test

# Generate Payload types
pnpm payload generate:types

# Run database migrations
pnpm payload migrate
```

---

## Environment Variables (Phase 1)

```env
# Database - AWS RDS PostgreSQL
DATABASE_URL=postgresql://payload_user:PASSWORD@your-rds.us-east-1.rds.amazonaws.com:5432/joelschaeffer?schema=payload

# AWS SES Email
AWS_SES_SMTP_USER=AKIAIOSFODNN7EXAMPLE
AWS_SES_SMTP_PASSWORD=your-ses-smtp-password

# Cloudflare R2 Storage
CLOUDFLARE_R2_BUCKET=joelschaeffer-photos
CLOUDFLARE_R2_ENDPOINT=https://your-account-id.r2.cloudflarestorage.com
CLOUDFLARE_R2_ACCESS_KEY_ID=your-r2-access-key
CLOUDFLARE_R2_SECRET_ACCESS_KEY=your-r2-secret-key

# Payload Configuration
PAYLOAD_SECRET=your-payload-secret-from-secrets-manager
NEXT_PUBLIC_SERVER_URL=https://joelschaeffer.com
PAYLOAD_PUBLIC_SERVER_URL=https://joelschaeffer.com
```

---

## Database Strategy (All Phases)

### Phase 1: Payload Only
```sql
-- AWS RDS PostgreSQL instance
CREATE SCHEMA payload;

-- Payload owns:
payload.artworks
payload.media
payload.users
payload.pages
payload.categories
payload.payload_migrations
```

### Phase 2: Add Django Backend
```sql
-- Same RDS, new schema
CREATE SCHEMA django;

-- Django owns:
django.email_logs
django.analytics_events
django.api_users
django.django_migrations

-- Django can READ payload.artworks (analytics only)
```

### Phase 3: E-commerce
```sql
-- Django adds:
django.orders
django.order_items
django.transactions
django.stripe_webhooks

-- Orders reference payload.artworks.id
-- No foreign key constraints across schemas
```

---

## Collections Overview

### Artworks Collection (Primary)
```typescript
{
  title: string
  slug: string (unique)
  description: richText
  mainImage: relationship → Media
  category: relationship → Categories
  metadata: {
    camera: string
    filmStock: string
    location: string
    captureDate: date
  }
  printOptions: {
    available: boolean
    sizes: ['8x10', '11x14', '16x20', '20x30']
  }
  featured: boolean
  status: 'draft' | 'published'
}
```

### Categories Collection
```typescript
{
  name: string
  slug: string
  description: text
  coverImage: relationship → Media
}
```

### Media Collection
```typescript
{
  filename: string
  mimeType: string
  filesize: number
  width: number
  height: number
  url: string (Cloudflare R2)
  alt: string
}
```

---

## Key Architectural Decisions

### Why AWS RDS Instead of Neon?
- **Integration**: Shared with future Django backend (same database, different schemas)
- **Cost**: Already paying for AWS RDS for other LightWave services
- **E-commerce Ready**: PostgreSQL transactions needed for Phase 3 print shop
- **Consistency**: Matches lightwave-media-site choice of staying within existing infrastructure

### Why Separate Schemas (payload vs django)?
- **Clear Ownership**: Payload owns payload.*, Django owns django.*
- **Independent Migrations**: No migration conflicts between systems
- **Safe Reads**: Django can read payload data without risk of writes
- **Easy Phase Transitions**: Adding Django doesn't change Payload tables

### Why Email Strategy Changes?
- **Phase 1**: Payload → AWS SES direct (simplest for MVP)
- **Phase 2**: Django email service (better templates, logging, queuing)
- **Migration**: Simple config change in Payload to call Django API

---

## Phase 1 Implementation Checklist

### Infrastructure Setup
- [ ] Create or use existing AWS RDS PostgreSQL instance
- [ ] Create `payload` schema in RDS
- [ ] Create `payload_user` database user with schema permissions
- [ ] Store credentials in AWS Secrets Manager
- [ ] Configure AWS SES for joelschaeffer.com domain
- [ ] Create SES SMTP credentials
- [ ] Set up Cloudflare R2 bucket for photos

### Application Configuration
- [ ] Rename repo: `lightwave-e-com-template` → `lightwave-joelschaeffer-website`
- [ ] Remove MongoDB adapter, add PostgreSQL adapter
- [ ] Configure Payload to use AWS RDS (`payload` schema)
- [ ] Configure Payload email with AWS SES
- [ ] Remove e-commerce collections (Products, Carts, Orders)
- [ ] Create Artworks collection
- [ ] Create Categories collection
- [ ] Configure Cloudflare R2 storage adapter

### Testing & Deployment
- [ ] Test Payload admin login locally
- [ ] Test email sending (password reset)
- [ ] Upload test photos to R2
- [ ] Run Payload migrations
- [ ] Deploy to Cloudflare Pages
- [ ] Set environment variables in Cloudflare
- [ ] Test production deployment

---

## Migration from Template

### What to Remove
```bash
# Collections to delete:
src/collections/Products/
src/collections/Carts/
src/collections/Orders/
src/collections/Transactions/
src/collections/Addresses/

# Stripe integration:
src/app/api/stripe/

# E-commerce pages:
src/app/(pages)/cart/
src/app/(pages)/checkout/
src/app/(pages)/products/
```

### What to Keep
```bash
# Core Payload setup
src/payload.config.ts (modified)
src/collections/Users/
src/collections/Media/
src/collections/Pages/

# Layout system
src/blocks/
src/components/
```

### What to Add
```bash
# New collections
src/collections/Artworks/
src/collections/Categories/

# New pages
src/app/(pages)/gallery/
src/app/(pages)/artwork/[slug]/

# New blocks
src/blocks/GalleryGrid/
src/blocks/ArtworkDetail/
```

---

## Quick Links

### Documentation
- **Architecture**: `.claude/project-context/01-architecture-sad.md` - Full system architecture
- **Phase 1 Guide**: `.claude/project-context/08-phase-1-implementation.md` - Step-by-step setup
- **Database Schema**: `.claude/project-context/04-database-strategy.md` - Multi-schema strategy

### Workspace Context
- **Workspace CLAUDE.md**: `../../CLAUDE.md` - LightWave workspace overview
- **AWS Profile**: `lightwave-admin-new` (set before any AWS commands)
- **Secrets Map**: `../../.claude/reference/SECRETS_MAP.md` - Where all credentials live

---

## Related Projects

### lightwave-media-site
- **URL**: https://lightwave-media.site
- **Tech**: Cloudflare D1 SQLite + Cloudflare R2
- **Purpose**: LightWave Media blog/portfolio
- **Note**: Different stack (D1 SQLite) because it's content-only, no e-commerce

### Django Backend (Future)
- **Deployment**: AWS ECS
- **Database**: AWS RDS PostgreSQL (`django` schema)
- **Purpose**: Business logic, email service, Stripe integration

---

**Last Updated**: 2025-11-01
**Current Phase**: Phase 1 - Gallery Portfolio
**Next Milestone**: Production deployment with gallery
**Team**: Joel Schaeffer + Claude Code
