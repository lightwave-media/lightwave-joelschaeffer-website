## 1. Introduction

This PRD defines the product requirements for [joelschaeffer.com](http://joelschaeffer.com), a professional photography portfolio website with integrated print shop. The site will serve as Joel Schaeffer's primary digital presence for photography work, enabling both portfolio showcasing and direct print sales to collectors and commercial clients.

**Product:** [joelschaeffer.com](http://joelschaeffer.com) photography section

**Target Launch:** Phase 1 foundation by November 15, 2025

**Related Epic:** [www.joelschaeffer.com/photo](http://www.joelschaeffer.com/photo) Website Launch 2026

## 2. Goals & Objectives

**Primary Goals:**

- Establish professional online presence for photography work
- Create revenue stream through direct print sales
- Organize and monetize existing photography archive
- Provide portfolio showcase for attracting commercial clients

**Measurable Objectives:**

- Launch Phase 1 foundation (gallery + CMS) within 2-week sprint (Nov 4-15, 2025)
- Achieve 10-15 finalized artworks ready for display by launch
- Enable admin to manage artwork catalog independently via Payload CMS
- Deploy to Cloudflare Pages with CDN-optimized image delivery

## 3. Target Audience / User Personas

**Persona 1: Fine Art Print Collector**

- **Demographics:** Age 30-65, disposable income, appreciates photography as art
- **Needs:** High-quality image previews, clear print options and pricing, secure ordering
- **Pain Points:** Difficulty finding unique photography prints, concerns about print quality
- **Motivations:** Curating personal art collection, supporting artists directly

**Persona 2: Commercial Photography Client**

- **Demographics:** Creative director, brand manager, editorial buyer
- **Needs:** Portfolio showcasing style and technical skill, easy contact, range of work
- **Pain Points:** Time-consuming photographer vetting, unclear capabilities
- **Motivations:** Finding right photographer for project, assessing fit quickly

**Persona 3: Joel (Site Administrator)**

- **Needs:** Fast artwork uploads, easy metadata management, print option configuration
- **Pain Points:** Complex CMSs, slow image processing, manual deployment workflows
- **Motivations:** Minimal maintenance overhead, focus on photography not tech

## 4. Problem Statement

Joel Schaeffer has years of accumulated photography work that is currently disorganized across multiple storage locations, making it impossible to effectively market or monetize. Without a professional web presence, potential print buyers and commercial clients have no way to discover or purchase his work. Existing platforms (Instagram, stock sites) don't provide the control, branding, or margins needed for a sustainable photography business.

## 5. Proposed Solution Overview

A custom-built photography portfolio website using Payload CMS and Next.js 15, deployed on Cloudflare Pages with R2 storage for CDN-optimized image delivery. The site will feature:

**Core Capabilities:**

- Responsive photography gallery with category filtering
- Individual artwork detail pages with large image display and embedded print options
- Payload CMS for artwork catalog management (title, description, images, print sizes/pricing)
- Cloudflare R2 integration for production-grade image storage and delivery
- Admin-only authentication (no customer accounts in Phase 1)
- Separate URL structure for future cinematography portfolio expansion

**Technical Foundation:**

- Built from Payload e-commerce template (simplified for Phase 1)
- Next.js 15.x + Payload CMS 2.x
- Cloudflare Pages (hosting) + Cloudflare R2 (storage)
- Embedded print pricing model (sizes/prices stored in artwork records)

## 6. Scope (High-Level)

### 6.1. Core Functionality (Phase 1 - Sprint 1)

**Must-Haves:**

- Photography Artworks collection in Payload CMS
- Gallery page displaying artwork grid (/photo/gallery)
- Artwork detail pages with print information (/photo/artwork/[slug])
- Cloudflare R2 custom storage adapter for Payload
- Pages collection for About/Contact content
- Admin authentication for CMS access
- Cloudflare Pages deployment with preview URLs
- Responsive design (mobile-first)

**Technical Deliverables:**

- Project setup from template with e-commerce features removed
- Payload collections schema (Artworks, Pages, Media)
- Custom R2 storage adapter (@aws-sdk/client-s3)
- Gallery component with image optimization
- Dynamic artwork detail routes
- Production deployment pipeline

### 6.2. Future Considerations (Phase 2+)

**Nice-to-Haves:**

- Shopping cart and checkout flow for print orders
- Customer account creation and order history
- Cinematography portfolio section (/cinema)
- Advanced filtering (price range, size, medium)
- Wishlist/favorites functionality
- Print preview tool (frame visualization)
- Email marketing integration
- Analytics dashboard for sales tracking
- Multi-currency support

## 7. Success Metrics

**Phase 1 (Foundation) Metrics:**

- ✅ Sprint completed on time (by Nov 15, 2025)
- ✅ All 5 user stories delivered (24 story points)
- ✅ Site deployed to Cloudflare Pages with working preview URL
- ✅ 10-15 artworks uploaded and displayable in gallery
- ✅ All acceptance criteria met per user story
- ✅ Admin can create/edit artwork entries independently

**Post-Launch Metrics (Phase 2+):**

- Gallery page views per month
- Artwork detail page engagement (time on page, image interactions)
- Contact form submissions from commercial clients
- Print inquiry volume
- SEO ranking for "[Joel Schaeffer] photography"
- Site performance (Lighthouse scores: 90+ across all categories)

## 8. Assumptions & Constraints

**Assumptions:**

- Payload e-commerce template is compatible with Next.js 15 and Cloudflare Pages
- Cloudflare R2 is S3-compatible and works with custom Payload storage adapters
- Template's e-commerce features can be cleanly removed without breaking core functionality
- 10-15 finalized artworks will be ready for upload by sprint end
- Admin-only auth is sufficient for Phase 1 (no customer accounts needed)
- Manual print fulfillment is acceptable initially (no automated order processing)

**Technical Constraints:**

- Must use Cloudflare Pages (stateless, serverless architecture)
- Cannot use local filesystem storage in production (requires R2 integration)
- Sprint timeline: 2 weeks (Nov 4-15, 2025) with 24 story points
- Single developer (Joel) + Claude Code capacity
- Template architecture may have coupling that complicates feature removal

**Business Constraints:**

- No e-commerce checkout in Phase 1 (prints are inquiry-based, not transactional)
- Domain currently on Squarespace DNS, needs migration to Cloudflare
- Email remains on [lightwave-media.ltd](http://lightwave-media.ltd) (no migration risk)
- Budget for Cloudflare R2 storage and bandwidth

## 9. Open Questions & Risks

**Open Questions:**

1. What print sizes should be offered initially? (Standard: 8x10, 11x14, 16x20, 24x36?)
2. What print types to support? (Fine art paper, canvas, metal, all three?)
3. How to price prints competitively while maintaining margins?
4. Should prints be offered immediately or after initial gallery validation?
5. When to add cinematography portfolio section? (Phase 2 timing)
6. Domain migration timeline - can we do DNS cutover during sprint or post-launch?

**Risks:**

**High Priority:**

- **Template Coupling:** E-commerce features may be tightly integrated, making removal difficult
    - *Mitigation:* Surgical removal with granular git commits for rollback
- **R2 Integration Complexity:** Custom storage adapter required, adds scope to US-JS-002
    - *Mitigation:* 8 story points allocated (up from 5), separate adapter testing
- **Sprint Capacity:** 24 points exceeds typical 21-point velocity
    - *Mitigation:* Accept slight overcommit for greenfield project, or defer detail pages to Sprint 2

**Medium Priority:**

- **Image Quality:** Need to balance file size vs. print-quality resolution
    - *Mitigation:* Use Next.js Image optimization + R2 CDN
- **Cloudflare Pages Build:** Next.js 15 + Payload CMS may have compatibility issues
    - *Mitigation:* Early deployment testing in US-JS-005

**Low Priority:**

- **SEO Competition:** Photography portfolio sites are highly competitive
    - *Mitigation:* Strong metadata, alt text, structured data for images

---

**Related Documents:**

- Epic: [www.joelschaeffer.com/photo](http://www.joelschaeffer.com/photo) Website Launch 2026
- Sprint: Sprint 1: [joelschaeffer.com](http://joelschaeffer.com) Foundation Build
- Architecture Review: v_product_architect review (2025-11-01)
- User Stories: US-JS-001 through US-JS-005