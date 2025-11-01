# System Architecture Document: joelschaeffer.com Photography Portfolio

**Version:** 2.0.0

**Date:** 2025-11-01

**Author:** v_product_architect + software-architect + infrastructure-ops-auditor (reviewed by Joel Schaeffer)

**Status:** Approved - 3-Phase Architecture

**Related PRD:** LWM joelschaeffer.com Photography Site - PRD - v2.0.0

---

## Table of Contents

1. Introduction & Architectural Goals
2. 3-Phase Architecture Strategy
3. Architectural Principles
4. Phase 1: Gallery Portfolio (Current)
5. Phase 2: Django Backend Integration
6. Phase 3: E-commerce with Stripe
7. Technology Stack (All Phases)
8. Component Architecture
9. Data Architecture & Schema Strategy
10. Security Architecture
11. Deployment Architecture
12. Integration Points
13. Performance & Scalability
14. Key Architectural Decisions
15. Migration Strategy Between Phases
16. Open Questions & Future Considerations

---

## 1. Introduction & Architectural Goals

### 1.1 Introduction

joelschaeffer.com is a professional photography portfolio website that will evolve into a full e-commerce platform for print sales. The system is designed as a **phased implementation** to enable rapid launch while building toward comprehensive business functionality.

**Primary Purpose:**
- **Phase 1:** Showcase photography work with professional gallery
- **Phase 2:** Add analytics, email service, business logic layer
- **Phase 3:** Enable direct print sales with payment processing

**Target Users:**
- Fine art print collectors browsing and purchasing prints
- Commercial photography clients evaluating portfolio work
- Site administrator (Joel) managing artwork catalog

### 1.2 Why 3-Phase Architecture?

**Business Requirement:** Launch portfolio gallery IMMEDIATELY (2 weeks) while planning for future e-commerce.

**Challenge:** Traditional approach would require building entire stack before launch.

**Solution:** Phased architecture allows:
1. **Phase 1:** Payload frontend-only launch with direct AWS integrations (2 weeks)
2. **Phase 2:** Add Django backend layer without disrupting frontend (4 weeks)
3. **Phase 3:** Add e-commerce without rewriting existing systems (6 weeks)

**Key Insight:** Each phase is **production-ready** and **fully functional**, not "temporary" or "MVP" that gets thrown away.

### 1.3 Architectural Goals

**Fast Time-to-Market:**
- Launch Phase 1 in 2 weeks (gallery only, no backend)
- Phase 2 adds business logic without frontend changes
- Phase 3 adds e-commerce without rewriting Phases 1-2

**Cost Efficiency:**
- **Phase 1:** Minimize infrastructure (Cloudflare Pages + AWS RDS + SES only)
- **Phase 2:** Add backend only when analytics/email service needed
- **Phase 3:** Add payment processing only when ready to sell

**Technical Flexibility:**
- Frontend (Payload/Next.js) and backend (Django) remain decoupled
- Each phase can be developed/deployed independently
- Rollback to previous phase always possible

**Maintainability:**
- Clear boundaries between systems (schema separation)
- Independent migrations (Payload vs Django)
- Simple integration contracts (REST APIs)

---

## 2. 3-Phase Architecture Strategy

### 2.1 Phase Timeline

| Phase | Duration | Cumulative | Status |
|-------|----------|------------|--------|
| **Phase 1: Gallery Portfolio** | 2 weeks | 2 weeks | CURRENT |
| **Phase 2: Django Backend** | 4 weeks | 6 weeks | Planned |
| **Phase 3: E-commerce** | 6 weeks | 12 weeks | Planned |

### 2.2 Phase Comparison Table

| Layer | Phase 1 (Now) | Phase 2 (+4 weeks) | Phase 3 (+6 weeks) |
|-------|---------------|--------------------|--------------------|
| **Frontend** | Next.js 15 + Payload CMS | Same | Same |
| **Database** | AWS RDS PostgreSQL (`payload` schema) | AWS RDS (`payload` + `django` schemas) | Same (shared) |
| **Backend** | None | Django REST API on AWS ECS | Same |
| **Email** | Payload → AWS SES (direct) | Django → AWS SES | Same |
| **Storage** | Cloudflare R2 | Same | Same |
| **Payments** | None | None | Django → Stripe |
| **Deployment** | Cloudflare Pages | + AWS ECS (Django) | Same |

### 2.3 Phase Dependencies

```
Phase 1 (Standalone)
  └─ Can launch independently
  └─ Direct AWS integrations (RDS, SES)

Phase 2 (Additive)
  └─ Requires Phase 1 to be live
  └─ Adds Django backend (new schema in existing RDS)
  └─ Frontend changes: Update email config to call Django API

Phase 3 (Additive)
  └─ Requires Phase 2 to be live
  └─ Adds e-commerce tables in `django` schema
  └─ Frontend changes: Add cart, checkout, payment flows
```

---

## 3. Architectural Principles

### 3.1 Core Principles

**Phased Delivery Over Big Bang:**
- Each phase delivers working software to production
- No "throw-away" prototypes or MVPs
- Clean upgrade paths between phases

**Shared Database, Separate Schemas:**
- One AWS RDS instance across all phases
- `payload` schema owned by Payload CMS
- `django` schema owned by Django backend (Phases 2+)
- No foreign key constraints across schemas (loose coupling)

**API-First Integration:**
- Frontend and backend communicate via REST APIs
- Clear contracts enable independent development
- Versioned APIs prevent breaking changes

**Infrastructure Reuse:**
- AWS RDS created in Phase 1, reused in Phases 2-3
- AWS SES configured in Phase 1, migrated to Django in Phase 2
- Cloudflare R2 used consistently across all phases

**Type Safety End-to-End:**
- TypeScript (frontend + Payload)
- Python with type hints (Django backend)
- Generated types for API contracts

---

## 4. Phase 1: Gallery Portfolio (Current)

### 4.1 Phase 1 Goals

**Launch Requirements:**
- ✅ Photography gallery display
- ✅ Payload CMS for content management
- ✅ AWS RDS PostgreSQL database (direct connection)
- ✅ AWS SES email (direct connection)
- ✅ Cloudflare R2 for photo storage
- ✅ Deployed to Cloudflare Pages
- ❌ No print shop yet
- ❌ No Django backend yet

**Timeline:** 2 weeks

### 4.2 Phase 1 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL USERS                                │
│       (Portfolio Viewers, Commercial Clients, Collectors)        │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   CLOUDFLARE EDGE NETWORK                        │
│  - SSL Termination                                               │
│  - DDoS Protection                                               │
│  - CDN Caching (HTML, CSS, JS)                                   │
└────────────┬───────────────────────────┬────────────────────────┘
             │                           │
             │ Static Assets             │ API Requests
             ▼                           ▼
┌──────────────────────┐      ┌──────────────────────────────────┐
│  CLOUDFLARE PAGES    │      │   PAYLOAD CMS + NEXT.JS          │
│  (Static Site Host)  │      │   (Serverless Functions)         │
│  - Pre-rendered HTML │      │   - Admin UI (/admin)            │
│  - Next.js Build     │      │   - REST/GraphQL APIs            │
└──────────────────────┘      │   - Server-side rendering        │
                              └────────────┬─────────────────────┘
                                           │
                         ┌─────────────────┼─────────────────┐
                         │                 │                 │
                         ▼                 ▼                 ▼
                  ┌──────────┐     ┌──────────┐     ┌──────────┐
                  │ AWS RDS  │     │ AWS SES  │     │Cloudflare│
                  │PostgreSQL│     │  Email   │     │    R2    │
                  │ (payload │     │ (Direct) │     │ (Photos) │
                  │  schema) │     └──────────┘     └──────────┘
                  └──────────┘
```

### 4.3 Phase 1 Technology Stack

**Frontend:** Next.js 15 + Payload CMS 3.x
**Database:** AWS RDS PostgreSQL (payload schema only)
**Email:** AWS SES (direct SMTP connection from Payload)
**Storage:** Cloudflare R2 (S3-compatible object storage)
**Hosting:** Cloudflare Pages (serverless, edge network)

### 4.4 Phase 1 Database Schema

```sql
-- AWS RDS PostgreSQL instance: joelschaeffer-db

-- Phase 1: Create payload schema
CREATE SCHEMA payload;

-- Payload owns:
payload.artworks          -- Photography portfolio items
payload.categories        -- Portfolio categories (landscape, portrait, etc.)
payload.media             -- Uploaded photos metadata
payload.pages             -- Content pages (About, Contact)
payload.users             -- Admin users
payload.payload_migrations -- Migration tracking
```

### 4.5 Phase 1 Environment Variables

```env
# Database - AWS RDS PostgreSQL
DATABASE_URL=postgresql://payload_user:PASSWORD@joelschaeffer-db.xyz.us-east-1.rds.amazonaws.com:5432/joelschaeffer?schema=payload

# AWS SES Email (Direct Connection)
AWS_SES_SMTP_USER=AKIAIOSFODNN7EXAMPLE
AWS_SES_SMTP_PASSWORD=your-ses-smtp-password
AWS_SES_REGION=us-east-1
EMAIL_FROM=noreply@joelschaeffer.com

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

### 4.6 Phase 1 Request Flow

**Public Gallery Request:**
```
1. User visits joelschaeffer.com/gallery
2. Cloudflare CDN serves cached HTML (if available)
3. If cache miss:
   a. Cloudflare Pages serves pre-rendered HTML
   b. Browser fetches images from R2 CDN
   c. Next.js hydrates page with React
4. Gallery displays with optimized images
```

**Admin Workflow:**
```
1. Admin logs into /admin (Payload UI)
2. Uploads image via Payload admin interface
3. Payload validates file (type, size)
4. R2 storage adapter:
   a. Generates image variants (thumbnail, card, full)
   b. Uploads all variants to Cloudflare R2
   c. Returns public URLs
5. Payload saves metadata to AWS RDS (payload schema)
6. Admin sees uploaded artwork in collection
```

---

## 5. Phase 2: Django Backend Integration

### 5.1 Phase 2 Goals

**New Capabilities:**
- ✅ Django REST API on AWS ECS Fargate
- ✅ Shared AWS RDS (separate `django` schema)
- ✅ Email service moves to Django (better templates, logging, queuing)
- ✅ Analytics and reporting (page views, popular artworks)
- ✅ API layer for future features
- ❌ Still no print shop (comes in Phase 3)

**Timeline:** +4 weeks after Phase 1 launch

### 5.2 Phase 2 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                   CLOUDFLARE EDGE NETWORK                        │
└────────────┬───────────────────────────┬────────────────────────┘
             │                           │
             ▼                           ▼
┌──────────────────────┐      ┌──────────────────────────────────┐
│  CLOUDFLARE PAGES    │      │   PAYLOAD CMS + NEXT.JS          │
│  (Frontend)          │      │   - Admin UI                     │
│                      │      │   - Gallery pages                │
└──────────────────────┘      └────────────┬─────────────────────┘
                                           │
                                           │ REST API
                                           ▼
                              ┌─────────────────────────────────┐
                              │   DJANGO BACKEND (NEW)          │
                              │   AWS ECS Fargate               │
                              │   - Email service               │
                              │   - Analytics API               │
                              │   - Business logic              │
                              └────────────┬────────────────────┘
                                           │
                         ┌─────────────────┼─────────────────┐
                         │                 │                 │
                         ▼                 ▼                 ▼
                  ┌──────────┐     ┌──────────┐     ┌──────────┐
                  │ AWS RDS  │     │ AWS SES  │     │Cloudflare│
                  │PostgreSQL│     │  Email   │     │    R2    │
                  │ SHARED:  │     │ (via     │     │          │
                  │ payload  │     │ Django)  │     └──────────┘
                  │ + django │     └──────────┘
                  │ schemas  │
                  └──────────┘
```

### 5.3 Phase 2 Database Schema

```sql
-- Same AWS RDS instance, new schema

-- Phase 2: Create django schema
CREATE SCHEMA django;

-- Django owns:
django.email_logs              -- Email sending history
django.email_templates         -- HTML email templates
django.analytics_events        -- Page views, clicks
django.api_users               -- Django API users (future)
django.django_migrations       -- Django migration tracking
django.sessions                -- Django sessions
django.celery_results          -- Background task results (if using Celery)

-- Django can READ from payload schema (analytics only):
-- SELECT * FROM payload.artworks (read-only, no foreign keys)

-- No cross-schema foreign keys:
-- django.analytics_events.artwork_id references payload.artworks.id
-- BUT: No FK constraint, just stored as integer
```

### 5.4 Phase 2 Integration Points

**Email Migration:**

**Before (Phase 1):**
```typescript
// Payload config
email: nodemailerAdapter({
  transport: {
    host: 'email-smtp.us-east-1.amazonaws.com',
    port: 587,
    auth: {
      user: process.env.AWS_SES_SMTP_USER,
      pass: process.env.AWS_SES_SMTP_PASSWORD,
    },
  },
}),
```

**After (Phase 2):**
```typescript
// Payload config
email: nodemailerAdapter({
  transport: {
    // Calls Django email service API
    host: process.env.DJANGO_API_URL,
    port: 443,
    auth: {
      user: process.env.DJANGO_API_KEY,
      pass: '',
    },
  },
}),
```

**Django Email Service:**
```python
# Django app/services/email.py
from django.core.mail import send_mail
import boto3

def send_email(to, subject, html_body):
    """
    Send email via AWS SES with logging and retry logic
    """
    # Log to django.email_logs table
    email_log = EmailLog.objects.create(
        to=to,
        subject=subject,
        body=html_body,
        status='pending'
    )

    try:
        send_mail(
            subject=subject,
            message='',
            html_message=html_body,
            from_email='noreply@joelschaeffer.com',
            recipient_list=[to],
        )
        email_log.status = 'sent'
    except Exception as e:
        email_log.status = 'failed'
        email_log.error = str(e)
    finally:
        email_log.save()
```

### 5.5 Phase 2 Environment Variables

**Payload (Updated):**
```env
# Add Django API connection
DJANGO_API_URL=https://api.joelschaeffer.com
DJANGO_API_KEY=secret-api-key-from-secrets-manager

# Remove direct AWS SES credentials (now via Django)
# AWS_SES_SMTP_USER=(removed)
# AWS_SES_SMTP_PASSWORD=(removed)
```

**Django (New):**
```env
# Database - Django schema
DATABASE_URL=postgresql://django_user:PASSWORD@joelschaeffer-db.xyz.us-east-1.rds.amazonaws.com:5432/joelschaeffer?schema=django

# AWS SES (Django now owns email)
AWS_SES_SMTP_USER=AKIAIOSFODNN7EXAMPLE
AWS_SES_SMTP_PASSWORD=your-ses-smtp-password
AWS_SES_REGION=us-east-1

# Django Configuration
SECRET_KEY=django-secret-key
ALLOWED_HOSTS=api.joelschaeffer.com
CORS_ALLOWED_ORIGINS=https://joelschaeffer.com

# Read-only access to payload schema (analytics)
PAYLOAD_DB_URL=postgresql://readonly_user:PASSWORD@joelschaeffer-db.xyz.us-east-1.rds.amazonaws.com:5432/joelschaeffer?schema=payload
```

---

## 6. Phase 3: E-commerce with Stripe

### 6.1 Phase 3 Goals

**New Capabilities:**
- ✅ Print shop checkout flow (cart → checkout → payment)
- ✅ Stripe payments (via Django backend)
- ✅ Order management (Django owns orders)
- ✅ Customer accounts (optional)
- ✅ Email notifications for orders

**Timeline:** +6 weeks after Phase 2 launch

### 6.2 Phase 3 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                   CLOUDFLARE EDGE NETWORK                        │
└────────────┬───────────────────────────┬────────────────────────┘
             │                           │
             ▼                           ▼
┌──────────────────────┐      ┌──────────────────────────────────┐
│  CLOUDFLARE PAGES    │      │   PAYLOAD CMS + NEXT.JS          │
│  (Frontend)          │      │   - Admin UI                     │
│  - Gallery           │      │   - Gallery pages                │
│  - Cart (NEW)        │      │   - Cart page (NEW)              │
│  - Checkout (NEW)    │      │   - Checkout flow (NEW)          │
└──────────────────────┘      └────────────┬─────────────────────┘
                                           │
                                           │ REST API
                                           ▼
                              ┌─────────────────────────────────┐
                              │   DJANGO BACKEND                │
                              │   AWS ECS Fargate               │
                              │   - Email service               │
                              │   - Analytics API               │
                              │   - Order API (NEW)             │
                              │   - Payment processing (NEW)    │
                              └────────────┬────────────────────┘
                                           │
                         ┌─────────────────┼─────────────────┬──────────┐
                         │                 │                 │          │
                         ▼                 ▼                 ▼          ▼
                  ┌──────────┐     ┌──────────┐     ┌──────────┐  ┌────────┐
                  │ AWS RDS  │     │ AWS SES  │     │Cloudflare│  │ Stripe │
                  │PostgreSQL│     │  Email   │     │    R2    │  │  API   │
                  │ SHARED:  │     │          │     │          │  │ (NEW)  │
                  │ payload  │     └──────────┘     └──────────┘  └────────┘
                  │ + django │
                  │ schemas  │
                  └──────────┘
```

### 6.3 Phase 3 Database Schema

```sql
-- Same AWS RDS instance, add e-commerce tables to django schema

-- Phase 3: Add to django schema
django.orders                  -- Customer orders
django.order_items             -- Line items (artwork_id, size, quantity, price)
django.transactions            -- Stripe payment records
django.stripe_webhooks         -- Webhook event log
django.customers               -- Customer accounts (optional)
django.shipping_addresses      -- Delivery addresses

-- Order references payload.artworks:
-- django.order_items.artwork_id references payload.artworks.id
-- (No FK constraint, just stored as integer with application-level integrity)
```

### 6.4 Phase 3 API Contract

**Django Order API:**

```python
# POST /api/v1/orders/create
{
  "customer_email": "buyer@example.com",
  "items": [
    {
      "artwork_id": 123,           # References payload.artworks.id
      "artwork_slug": "sunset-1",  # For display purposes
      "size": "16x20",
      "print_type": "fine-art",
      "quantity": 1,
      "price_usd": 250.00
    }
  ],
  "shipping_address": {
    "name": "John Doe",
    "line1": "123 Main St",
    "city": "San Francisco",
    "state": "CA",
    "postal_code": "94102",
    "country": "US"
  },
  "payment_method_id": "pm_stripe_token_here"
}

# Response
{
  "order_id": "ORD-2025-00001",
  "status": "processing",
  "total_usd": 250.00,
  "stripe_payment_intent_id": "pi_xxx",
  "confirmation_url": "https://joelschaeffer.com/orders/ORD-2025-00001"
}
```

### 6.5 Phase 3 Frontend Changes

**New Next.js Pages:**
```
/app/(pages)/cart/page.tsx               # Shopping cart
/app/(pages)/checkout/page.tsx           # Checkout flow
/app/(pages)/orders/[orderId]/page.tsx   # Order confirmation
/app/(pages)/account/orders/page.tsx     # Order history (if customer accounts)
```

**New API Routes:**
```
/app/api/cart/route.ts                   # Cart management (localStorage or session)
/app/api/checkout/route.ts               # Proxy to Django order API
/app/api/stripe/webhook/route.ts         # Stripe webhook handler (proxies to Django)
```

---

## 7. Technology Stack (All Phases)

### 7.1 Frontend (All Phases)

**Framework:** Next.js 15.x (App Router)
**Language:** TypeScript 5.x
**CMS:** Payload CMS 3.x
**Styling:** Tailwind CSS 4.x
**State Management:** React Context + Zustand (cart state in Phase 3)
**Form Handling:** React Hook Form
**Hosting:** Cloudflare Pages

### 7.2 Backend (Phases 2-3)

**Framework:** Django 5.0+
**Language:** Python 3.11+
**API:** Django REST Framework
**Task Queue:** Celery (optional, for async email/analytics)
**Hosting:** AWS ECS Fargate (containerized)

### 7.3 Database (All Phases)

**Database:** AWS RDS PostgreSQL 15+
**Adapter (Payload):** `@payloadcms/db-postgres` with `schemaName: 'payload'`
**Adapter (Django):** `psycopg2` with `options='-c search_path=django'`
**Backup Strategy:** Daily automated snapshots (AWS RDS), 7-day retention

### 7.4 Storage (All Phases)

**Object Storage:** Cloudflare R2 (S3-compatible)
**CDN:** Cloudflare CDN (built into Pages + R2)
**Image Optimization:** Next.js Image component + Cloudflare image transforms

### 7.5 Email (All Phases)

**Service:** AWS SES
- Phase 1: Direct SMTP connection from Payload
- Phases 2-3: Via Django email service

### 7.6 Payments (Phase 3 Only)

**Provider:** Stripe
**Integration:** Django backend (server-side only, no Stripe.js in frontend)
**Webhook Handling:** Django receives webhooks, updates order status

---

## 8. Component Architecture

### 8.1 Frontend Components (Payload/Next.js)

**Directory Structure:**
```
/app
  /(pages)
    /gallery                # Gallery grid view
    /artwork/[slug]         # Artwork detail
    /cart                   # Phase 3: Shopping cart
    /checkout               # Phase 3: Checkout flow
    /orders/[orderId]       # Phase 3: Order confirmation
  /(admin)
    /[[...route]]           # Payload admin UI
  /api
    /cart                   # Phase 3: Cart API
    /checkout               # Phase 3: Checkout proxy to Django
    /payload                # Payload API routes

/components
  /gallery
    ArtworkCard.tsx         # Grid item
    GalleryGrid.tsx         # Responsive grid
    FilterBar.tsx           # Category filters
  /artwork
    ArtworkImage.tsx        # Large image display
    PrintOptions.tsx        # Print size/price list (Phase 3: Add to cart)
  /cart                     # Phase 3: Cart components
    CartItem.tsx
    CartSummary.tsx
  /checkout                 # Phase 3: Checkout components
    CheckoutForm.tsx
    PaymentForm.tsx
  /layout
    Header.tsx              # Site header/nav
    Footer.tsx              # Site footer
```

### 8.2 Backend Components (Django - Phases 2-3)

**Django Project Structure:**
```
backend/
  apps/
    email/                  # Phase 2: Email service
      models.py             # EmailLog, EmailTemplate
      services.py           # send_email()
      views.py              # Email API endpoints
    analytics/              # Phase 2: Analytics
      models.py             # AnalyticsEvent
      services.py           # track_page_view()
      views.py              # Analytics API
    orders/                 # Phase 3: Order management
      models.py             # Order, OrderItem, Transaction
      services.py           # create_order(), process_payment()
      views.py              # Order API
    payments/               # Phase 3: Stripe integration
      services.py           # StripeService
      webhooks.py           # Stripe webhook handlers
```

### 8.3 Payload Collections

**Artworks Collection:**
```typescript
{
  slug: 'artworks',
  fields: [
    { name: 'title', type: 'text', required: true },
    { name: 'slug', type: 'text', unique: true },
    { name: 'description', type: 'richText' },
    { name: 'mainImage', type: 'upload', relationTo: 'media' },
    { name: 'category', type: 'relationship', relationTo: 'categories' },
    {
      name: 'printOptions',       // Phase 3: Used for cart/checkout
      type: 'array',
      fields: [
        { name: 'size', type: 'text' },         // "8x10", "16x20"
        { name: 'priceUSD', type: 'number' },
        { name: 'available', type: 'checkbox' },
        { name: 'printType', type: 'select' }   // fine-art, canvas, metal
      ]
    },
    { name: 'metadata', type: 'group', fields: [
      { name: 'camera', type: 'text' },
      { name: 'filmStock', type: 'text' },
      { name: 'location', type: 'text' },
      { name: 'captureDate', type: 'date' }
    ]},
    { name: 'featured', type: 'checkbox' },
    { name: 'status', type: 'select', options: ['draft', 'published'] }
  ]
}
```

---

## 9. Data Architecture & Schema Strategy

### 9.1 Multi-Schema Strategy

**Why Separate Schemas?**
1. **Clear Ownership:** Payload owns `payload.*`, Django owns `django.*`
2. **Independent Migrations:** No migration conflicts between systems
3. **Safe Reads:** Django can read `payload.artworks` without risk of writes
4. **Easy Phase Transitions:** Adding Django doesn't change Payload tables

**Schema Boundaries:**
```sql
-- Payload Schema (Phase 1+)
payload.artworks          -- Source of truth for artwork catalog
payload.categories        -- Portfolio categories
payload.media             -- Photo uploads metadata
payload.pages             -- Content pages
payload.users             -- Admin users

-- Django Schema (Phase 2+)
django.email_logs         -- Email history
django.analytics_events   -- Analytics data
django.api_users          -- Django API users

-- Django Schema (Phase 3+)
django.orders             -- Customer orders
django.order_items        -- Line items (references payload.artworks.id as integer)
django.transactions       -- Payment records
```

**Cross-Schema Reads (Django Only):**
```python
# Django can read payload.artworks for analytics
from django.db import connection

def get_artwork_by_id(artwork_id):
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT id, title, slug
            FROM payload.artworks
            WHERE id = %s AND status = 'published'
        """, [artwork_id])
        return cursor.fetchone()
```

**No Cross-Schema Foreign Keys:**
```sql
-- ❌ Bad: Foreign key constraint across schemas
ALTER TABLE django.order_items
ADD CONSTRAINT fk_artwork
FOREIGN KEY (artwork_id) REFERENCES payload.artworks(id);

-- ✅ Good: Store as integer, validate in application code
-- django.order_items.artwork_id: integer (no FK constraint)
-- Application validates artwork exists in payload.artworks before order creation
```

### 9.2 Data Storage Strategy

**PostgreSQL (Metadata):**
- Artwork records (title, slug, description, category, status)
- Print options (embedded as JSON/JSONB in artwork records)
- Page content (About, Contact)
- Media metadata (filenames, URLs, alt text)
- Admin users and sessions
- **Phase 2:** Email logs, analytics events
- **Phase 3:** Orders, transactions, customer accounts

**Cloudflare R2 (Binary Objects):**
- Original uploaded images
- Generated image sizes (thumbnail, card, full)
- Organized by Payload's upload directory structure

**Cloudflare CDN (Cache):**
- Pre-rendered HTML pages (gallery, artwork details)
- Static assets (CSS, JS bundles)
- Cached image responses

### 9.3 Database Connection Strategy

**Phase 1: Single Connection (Payload Only)**
```typescript
// Payload config
db: postgresAdapter({
  pool: {
    connectionString: process.env.DATABASE_URL,
  },
  schemaName: 'payload',
})
```

**Phase 2-3: Multiple Connections**

Payload:
```typescript
db: postgresAdapter({
  pool: {
    connectionString: process.env.DATABASE_URL,  // schema=payload
  },
  schemaName: 'payload',
})
```

Django:
```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'joelschaeffer',
        'USER': 'django_user',
        'PASSWORD': os.environ['DB_PASSWORD'],
        'HOST': 'joelschaeffer-db.xyz.us-east-1.rds.amazonaws.com',
        'PORT': '5432',
        'OPTIONS': {
            'options': '-c search_path=django'  # Django schema
        }
    },
    'payload_readonly': {  # Read-only connection for analytics
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'joelschaeffer',
        'USER': 'readonly_user',
        'PASSWORD': os.environ['PAYLOAD_DB_PASSWORD'],
        'HOST': 'joelschaeffer-db.xyz.us-east-1.rds.amazonaws.com',
        'PORT': '5432',
        'OPTIONS': {
            'options': '-c search_path=payload'  # Payload schema (read-only)
        }
    }
}
```

---

## 10. Security Architecture

### 10.1 Authentication & Authorization

**Phase 1:**
- Payload JWT-based authentication (admin only)
- No customer accounts

**Phases 2-3:**
- Django JWT authentication for API access
- Optional customer accounts (email/password or OAuth)

**Access Control:**
```typescript
// Payload collections
access: {
  read: () => true,                          // Public read
  create: ({ req: { user } }) => !!user,     // Admin only
  update: ({ req: { user } }) => !!user,     // Admin only
  delete: ({ req: { user } }) => !!user,     // Admin only
}
```

### 10.2 Data Protection

**In Transit:**
- HTTPS everywhere (enforced by Cloudflare)
- TLS 1.3 for all connections
- HSTS headers (force HTTPS)

**At Rest:**
- AWS RDS: Encryption at rest enabled (AWS managed keys)
- R2: Server-side encryption enabled by default
- Passwords: Hashed with bcrypt (Payload) / PBKDF2 (Django)

**Secrets Management:**
- AWS Secrets Manager for production credentials
- Never commit secrets to git
- Environment variables for configuration

### 10.3 API Security

**Rate Limiting:**
- Cloudflare DDoS protection at edge
- Django rate limiting per IP (100 req/min)

**Input Validation:**
- File type whitelist (images: jpg, png, webp, gif)
- File size limits (20MB max per upload)
- Payload schema validation for all fields
- Django REST Framework serializer validation

**CORS Configuration:**
```python
# Django settings.py
CORS_ALLOWED_ORIGINS = [
    'https://joelschaeffer.com',
    'https://preview.joelschaeffer.pages.dev',  # Preview deployments
]
```

---

## 11. Deployment Architecture

### 11.1 Phase 1 Deployment

**Cloudflare Pages:**
```yaml
Build command: pnpm build
Build output directory: .next
Node version: 20.x

Environment Variables:
  DATABASE_URL: (AWS RDS connection string, schema=payload)
  AWS_SES_SMTP_USER: (from AWS Secrets Manager)
  AWS_SES_SMTP_PASSWORD: (from AWS Secrets Manager)
  CLOUDFLARE_R2_*: (R2 credentials)
  PAYLOAD_SECRET: (from AWS Secrets Manager)
```

**AWS RDS:**
- Instance: `db.t4g.micro` (can scale up later)
- PostgreSQL 15.x
- Multi-AZ for production
- Automated backups (7-day retention)

**Cloudflare R2:**
- Bucket: `joelschaeffer-photos`
- Public access via CDN domain

### 11.2 Phase 2 Deployment

**Add Django Backend on AWS ECS:**

```yaml
# docker-compose.yml (for ECS)
services:
  backend:
    image: ghcr.io/lightwave-media/joelschaeffer-backend:latest
    environment:
      - DATABASE_URL=(schema=django)
      - AWS_SES_SMTP_USER=...
      - DJANGO_SECRET_KEY=...
    ports:
      - "8000:8000"
    deploy:
      replicas: 1  # Scale as needed
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

**ECS Task Definition:**
- Fargate launch type (serverless)
- ALB for load balancing
- Service Auto Scaling (CPU/memory targets)

### 11.3 Environment Strategy

| Environment | Frontend | Backend | Database | Usage |
|-------------|----------|---------|----------|-------|
| **Local Dev** | localhost:3000 | localhost:8000 (Phase 2+) | Local PG or RDS dev | Development |
| **Preview** | *.pages.dev | ECS dev (Phase 2+) | RDS dev (read-only) | PR reviews |
| **Production** | joelschaeffer.com | api.joelschaeffer.com | RDS prod | Live site |

---

## 12. Integration Points

### 12.1 External Services

**AWS RDS PostgreSQL:**
- Purpose: Primary database
- Connection: Direct via `DATABASE_URL`
- Credentials: AWS Secrets Manager

**AWS SES:**
- Purpose: Email sending
- Integration:
  - Phase 1: Direct SMTP from Payload
  - Phases 2-3: Via Django email service
- Credentials: AWS IAM user

**Cloudflare R2:**
- Purpose: Image storage
- Integration: Payload custom storage adapter (S3-compatible API)
- Credentials: R2 access keys

**Stripe (Phase 3):**
- Purpose: Payment processing
- Integration: Django backend only (server-side)
- Credentials: Stripe secret key (live and test)

### 12.2 Internal APIs

**Payload REST API:**
```
GET  /api/artworks?status=published        # List published artworks
GET  /api/artworks/:id                     # Get artwork by ID
GET  /api/artworks/slug/:slug              # Get artwork by slug
POST /api/artworks                         # Create artwork (admin)
PUT  /api/artworks/:id                     # Update artwork (admin)
DEL  /api/artworks/:id                     # Delete artwork (admin)
```

**Django REST API (Phases 2-3):**
```
# Phase 2
POST /api/v1/email/send                    # Send email
POST /api/v1/analytics/track               # Track event
GET  /api/v1/analytics/popular-artworks    # Get popular artworks

# Phase 3
POST /api/v1/orders/create                 # Create order
GET  /api/v1/orders/:orderId               # Get order details
POST /api/v1/payments/stripe-webhook       # Stripe webhook handler
```

---

## 13. Performance & Scalability

### 13.1 Performance Targets (All Phases)

**Page Load Times:**
- First Contentful Paint (FCP): < 1.0s
- Largest Contentful Paint (LCP): < 2.5s
- Time to Interactive (TTI): < 3.0s
- Cumulative Layout Shift (CLS): < 0.1

**API Response Times:**
- Gallery listing: < 200ms (P95)
- Artwork detail: < 150ms (P95)
- Image delivery: < 100ms (P95, edge cache hit)

### 13.2 Caching Strategy

**Edge Caching (Cloudflare CDN):**
```
/gallery              → Cache for 5 minutes (s-maxage=300)
/artwork/[slug]       → Cache for 1 hour (s-maxage=3600)
/about, /contact      → Cache for 1 day (s-maxage=86400)
/media/*              → Cache for 1 year (immutable)
```

**Cache Invalidation:**
- On artwork publish: Purge `/gallery` cache
- On artwork update: Purge `/artwork/[slug]` cache
- Cloudflare API for programmatic purging

---

## 14. Key Architectural Decisions

| Decision | Options Considered | Choice Made | Rationale | Phase |
|----------|-------------------|-------------|-----------|-------|
| **Phased vs Big Bang** | Launch all at once, Phased delivery | **3-Phase Architecture** | Fast time-to-market, risk reduction, working software each phase | All |
| **Database Platform** | Neon, Supabase, AWS RDS | **AWS RDS PostgreSQL** | Existing infrastructure, cost ($0 additional), integrates with future Django backend | Phase 1 |
| **Schema Strategy** | Single schema, Multiple databases, Schema separation | **Separate Schemas (payload + django)** | Clear ownership, independent migrations, safe reads | Phase 2 |
| **Email Strategy** | Always via Django, Always direct SES, Phased migration | **Phase 1: Direct SES → Phase 2: Django** | Simple Phase 1 launch, better email service in Phase 2 | All |
| **CMS Platform** | WordPress, Contentful, Strapi, Payload | **Payload CMS** | TypeScript-native, flexible, self-hosted, no vendor lock-in | Phase 1 |
| **Frontend Framework** | Next.js, Gatsby, Astro, SvelteKit | **Next.js 15** | Industry standard, React ecosystem, image optimization, SSG/SSR | Phase 1 |
| **Hosting** | Vercel, Netlify, Cloudflare Pages | **Cloudflare Pages** | Cost (free tier), R2 integration, edge network, serverless | Phase 1 |
| **Image Storage** | Local FS, S3, Cloudflare R2, Cloudinary | **Cloudflare R2** | Stateless hosting requires object storage, R2 cheapest + CDN | Phase 1 |
| **Backend Platform** | Node.js, Django, FastAPI | **Django REST Framework** | Mature e-commerce ecosystem, ORM, admin, Python type safety | Phase 2 |
| **Payment Provider** | Stripe, Square, PayPal | **Stripe** | Best developer experience, comprehensive API, webhooks | Phase 3 |

---

## 15. Migration Strategy Between Phases

### 15.1 Phase 1 → Phase 2 Migration

**Prerequisites:**
- Phase 1 must be deployed and stable
- Django backend infrastructure provisioned (AWS ECS, ALB, etc.)

**Migration Steps:**

1. **Create Django Schema:**
```sql
-- Connect to AWS RDS
CREATE SCHEMA django;
CREATE USER django_user WITH PASSWORD 'secure-password';
GRANT ALL PRIVILEGES ON SCHEMA django TO django_user;
```

2. **Deploy Django Backend:**
```bash
# Build Docker image
docker build -t joelschaeffer-backend:v1 .

# Push to GHCR
docker push ghcr.io/lightwave-media/joelschaeffer-backend:v1

# Deploy to ECS
aws ecs update-service --cluster prod --service backend --force-new-deployment
```

3. **Update Payload Environment Variables:**
```env
# Add Django API connection
DJANGO_API_URL=https://api.joelschaeffer.com
DJANGO_API_KEY=secret-api-key
```

4. **Update Payload Email Config:**
```typescript
// Change email transport to call Django API instead of direct SES
email: djangoEmailAdapter({
  apiUrl: process.env.DJANGO_API_URL,
  apiKey: process.env.DJANGO_API_KEY,
})
```

5. **Test Email Sending:**
```bash
# Send test email via Payload admin
# Verify email log appears in django.email_logs table
```

6. **Monitor & Rollback Plan:**
- Monitor Django API logs for errors
- Monitor AWS SES sending metrics
- If issues: Revert Payload config to direct SES (no data loss)

### 15.2 Phase 2 → Phase 3 Migration

**Prerequisites:**
- Phase 2 must be deployed and stable
- Stripe account configured (test and live modes)

**Migration Steps:**

1. **Add E-commerce Tables:**
```sql
-- Django migrations will create these tables
python manage.py migrate orders
python manage.py migrate payments
```

2. **Deploy Updated Django Backend:**
```bash
# Update Docker image with order/payment code
docker build -t joelschaeffer-backend:v2 .
docker push ghcr.io/lightwave-media/joelschaeffer-backend:v2
aws ecs update-service --cluster prod --service backend --force-new-deployment
```

3. **Deploy Frontend with Cart/Checkout Pages:**
```bash
# Deploy to Cloudflare Pages (git push to main)
git add app/(pages)/cart app/(pages)/checkout
git commit -m "feat: add cart and checkout pages"
git push origin main
```

4. **Configure Stripe Webhooks:**
```bash
# Point Stripe webhook to Django endpoint
stripe listen --forward-to https://api.joelschaeffer.com/api/v1/payments/stripe-webhook
```

5. **Test Order Flow:**
- Add item to cart
- Complete checkout with Stripe test card
- Verify order created in `django.orders` table
- Verify payment recorded in `django.transactions` table
- Verify email confirmation sent

---

## 16. Open Questions & Future Considerations

### 16.1 Open Questions

1. **AWS RDS Instance Size:** Start with `db.t4g.micro` or `db.t4g.small`?
   - **Recommendation:** Start with micro, scale up if needed

2. **Django Deployment:** Single ECS task or multiple?
   - **Recommendation:** Start with 1 task, add auto-scaling in Phase 2

3. **Customer Accounts:** Required for Phase 3 or optional?
   - **Recommendation:** Optional (guest checkout supported)

4. **Image CDN Domain:** Use custom `cdn.joelschaeffer.com` or direct R2 URLs?
   - **Recommendation:** Custom domain for branding

### 16.2 Future Architectural Enhancements

**Phase 4+ (Long-term):**
- Mobile app (React Native consuming APIs)
- Cinematography portfolio (`/cinema` section with video embeds)
- Advanced search & filtering
- Analytics dashboard (Payload admin widgets)
- Print fulfillment integration (Printful API)
- Subscription service (monthly print club)

### 16.3 Technical Debt to Monitor

**Schema Migration:**
- Ensure Django migrations are tracked in git
- Ensure Payload migrations are tracked separately
- Document any manual schema changes

**Type Safety:**
- Generate TypeScript types from Django API (OpenAPI spec)
- Keep Payload TypeScript types synchronized

**Test Coverage:**
- Add E2E tests for critical flows (Playwright)
- Add API tests for Django endpoints (pytest)

---

## 17. Document Metadata

**Related Documents:**
- PRD: LWM joelschaeffer.com Photography Site - PRD - v2.0.0
- Project Overview: 00-project-overview.md (3-phase roadmap)
- Phase 1 Implementation Guide: 08-phase-1-implementation.md

**Review Cycle:** Before each phase transition

**Maintained By:** v_product_architect + software-architect + infrastructure-ops-auditor + Joel Schaeffer

**Last Updated:** 2025-11-01

**Status:** Approved - 3-Phase Architecture (Phase 1 Current)
