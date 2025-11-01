## 1. Sprint Goal

Build Phase 1 foundation for [joelschaeffer.com](http://joelschaeffer.com) from Payload e-commerce template: Setup project structure, configure Payload CMS with Photography collections, build gallery and artwork detail pages, and deploy working preview to Cloudflare Pages.

**Success Criteria:**

- ✅ New project running locally from template
- ✅ Payload CMS configured with Photography Artworks collection
- ✅ Gallery page displays artwork grid
- ✅ Artwork detail pages render with print info
- ✅ Site deployed to Cloudflare Pages preview URL
- ✅ All core pages accessible and functional

## 2. Sprint Backlog (Committed User Stories & Tasks)

**Total Story Points Committed:** 24 points ⚠️ *Updated after architecture review*

### User Stories:

1. [⚙️ US-JS-001: Project Setup from Template](https://www.notion.so/US-JS-001-Project-Setup-from-Template-56dd79c8d82d4f87b6565a4622fd4ed4?pvs=21) (3 pts) - Copy template, initialize Git, remove e-commerce features
2. [🎨 US-JS-002: Payload CMS + Cloudflare R2 Integration](https://www.notion.so/US-JS-002-Payload-CMS-Cloudflare-R2-Integration-82073f05378a40798c5cce1c27fd968e?pvs=21) (8 pts) ⚠️ *Increased from 5 pts* - Create collections + R2 storage adapter (CRITICAL PATH)
3. **US-JS-003: Gallery Page Build** (5 pts) - Build responsive grid, filters, image optimization
4. **US-JS-004: Artwork Detail Pages** (5 pts) - Dynamic routes, large image display, embedded print options
5. **US-JS-005: Cloudflare Pages Deployment** (3 pts) - Configure build, deploy preview, test

## 3. Team Capacity & Availability

- **Joel:** Full availability (owner/developer)
- **Claude Code:** Standard capacity (AI coding assistant)
- **Estimated Velocity:** 21 story points (reasonable for 2-week sprint with template foundation)

## 4. Risks & Dependencies for this Sprint

**Risks:**

- **Template Complexity:** E-commerce template may have unnecessary features that complicate removal (Mitigation: Surgical removal in US-JS-001, granular git commits for rollback)
- **⚠️ R2 Integration Complexity (ELEVATED):** Cloudflare Pages is stateless - local storage won't work in production. R2 integration is mandatory Phase 1, not optional. (Mitigation: Custom Payload storage adapter required in US-JS-002, adds 3 story points)
- **Auth Simplification:** Template's auth system may be tightly coupled (Mitigation: Keep admin auth only, remove customer auth/registration flows)
- **Sprint Capacity:** 24 points is above typical 21-point sprint (Mitigation: Accept slight overcommit given greenfield project, or defer US-JS-004 to Sprint 2)

**Dependencies:**

- **Template Access:** Must have working copy at `/Users/joelschaeffer/dev/lightwave-workspace/Frontend/lightwave-e-com-template`
- **Cloudflare Account:** Need account access and API tokens for deployment
- **GitHub Repo:** New repo must be created at [`github.com/lightwave-media/joelschaeffer-com`](http://github.com/lightwave-media/joelschaeffer-com)

**Blocked By:**

- None (greenfield project)

## 5. Architecture Decisions (Completed ✅)

**Architecture Review Completed:** 2025-11-01 by v_product_architect

**Key Documents:**

- **System Architecture Document (SAD):** [LWM joelschaeffer.com - SAD - v1.0.0](https://www.notion.so/LWM-joelschaeffer-com-SAD-v1-0-0-9dd05c8ef6874cdbbaf795d30077676b?pvs=21)
- **Product Requirements Document (PRD):** [LWM joelschaeffer.com Photography Site - PRD - v1.0.0](https://www.notion.so/LWM-joelschaeffer-com-Photography-Site-PRD-v1-0-0-482a86b68af14c53afc8677da55da928?pvs=21)

**Key Implementation Notes:**

- R2 integration requires custom Payload storage adapter (@aws-sdk/client-s3)
- Print options stored as embedded array: `printOptions: [{size, priceUSD, available, printType}]`
- Template simplification: Remove cart, checkout, orders, customer auth (keep admin auth)
- Site structure: `/photo/gallery`, `/photo/artwork/[slug]`, `/cinema/*` (future)

## 5. Architecture Decisions (Completed ✅)

**Architecture Review Completed:** 2025-11-01 by v_product_architect

**Key Documents:**

- **System Architecture Document (SAD):** [LWM joelschaeffer.com - SAD - v1.0.0](https://www.notion.so/LWM-joelschaeffer-com-SAD-v1-0-0-9dd05c8ef6874cdbbaf795d30077676b?pvs=21)
- **Product Requirements Document (PRD):** [LWM joelschaeffer.com Photography Site - PRD - v1.0.0](https://www.notion.so/LWM-joelschaeffer-com-Photography-Site-PRD-v1-0-0-482a86b68af14c53afc8677da55da928?pvs=21)

**Architecture Approach:**

This sprint uses a **simplified Payload CMS + Next.js** architecture deployed directly to Cloudflare Pages. This is a departure from the original backend-first plan (see [.agent/tasks/TASK_JOELSCHAEFFER_RESTRUCTURE.md - [TASK] Restructure joelschaeffer.com Site](https://www.notion.so/agent-tasks-TASK_JOELSCHAEFFER_RESTRUCTURE-md-TASK-Restructure-joelschaeffer-com-Site-ad632b3a516046eda8700f2694df8043?pvs=21)).

**Current Decisions:**

- ✅ **Frontend-First:** Build Payload CMS + Next.js site now, defer Django backend to Phase 2
- ✅ **Cloudflare Stack:** Pages (hosting) + R2 (storage) + CDN (delivery)
- ✅ **Admin-Only Auth:** Use Payload's built-in auth, no customer accounts in Phase 1
- ✅ **Embedded Print Pricing:** Store print options in Artworks collection (no separate collection)
- ✅ **R2 Integration (Phase 1):** Custom storage adapter required (Cloudflare Pages is stateless)

**Key Implementation Notes:**

- R2 integration requires custom Payload storage adapter (@aws-sdk/client-s3)
- Print options stored as embedded array: `printOptions: [{size, priceUSD, available, printType}]`
- Template simplification: Remove cart, checkout, orders, customer auth (keep admin auth)
- Site structure: `/photo/gallery`, `/photo/artwork/[slug]`, `/cinema/*` (future)

**Future Backend Integration (Phase 2):**

The original backend-first plan is preserved for future reference. Phase 2 may integrate Django backend for:

- Advanced auth (customer accounts, SSO)
- Order management and fulfillment
- Payment processing
- Analytics and reporting

## 6. Sprint Review Notes (To be filled at end of Sprint)

- **Work Demonstrated:**
    - [To be completed]
- **Stakeholder Feedback:**
    - [To be completed]
- **Product Backlog Items Updated:**
    - [To be completed]

## 7. Sprint Retrospective Notes (To be filled at end of Sprint)

- **What Went Well?**
    - [To be completed]
- **What Could Be Improved?**
    - [To be completed]
- **Action Items for Next Sprint:**
    - [To be completed]