# Phase 1 Kickoff Prompt: joelschaeffer.com Gallery Portfolio

**Copy this entire message and paste it into a new Claude Code chat to begin Phase 1 implementation.**

---

## Project Context

I'm starting Phase 1 implementation of **joelschaeffer.com**, a photography portfolio website that will evolve into an e-commerce platform through a 3-phase architecture.

**Current Repository**: `/Users/joelschaeffer/dev/lightwave-workspace/Frontend/lightwave-e-com-template`

**Note**: This repository will be renamed to `lightwave-joelschaeffer-website` during Phase 1.

## Phase 1 Goals (2-week timeline)

Launch a working photography gallery with:
- ✅ Photography gallery display
- ✅ Payload CMS for content management
- ✅ AWS RDS PostgreSQL database (direct connection)
- ✅ AWS SES email (direct connection)
- ✅ Cloudflare R2 for photo storage
- ✅ Deployed to Cloudflare Pages

**No backend yet** - that comes in Phase 2. Phase 1 is frontend-only with direct AWS integrations.

## Technical Architecture

**Tech Stack**:
- Frontend: Next.js 15 + Payload CMS 3.x
- Database: AWS RDS PostgreSQL (`payload` schema only)
- Email: AWS SES (direct SMTP from Payload)
- Storage: Cloudflare R2 (S3-compatible)
- Deployment: Cloudflare Pages (serverless)

**Key Decision**: Using AWS RDS PostgreSQL (not Neon, not MongoDB) because:
- Already paying for AWS infrastructure ($0 additional cost)
- Integrates with future Django backend (Phase 2)
- Schema separation strategy (`payload` vs `django` schemas)

## Documentation Available

**You have complete documentation for Phase 1**:

1. **Project Overview**:
   - File: `/Users/joelschaeffer/dev/lightwave-workspace/Frontend/lightwave-e-com-template/.claude/project-context/00-project-overview.md`
   - Contains: 3-phase roadmap, tech stack summary, database strategy, environment variables

2. **System Architecture**:
   - File: `/Users/joelschaeffer/dev/lightwave-workspace/Frontend/lightwave-e-com-template/.claude/project-context/01-architecture-sad.md`
   - Contains: Complete Phase 1/2/3 architecture diagrams, integration points, deployment strategy

3. **Phase 1 Implementation Guide**:
   - File: `/Users/joelschaeffer/dev/lightwave-workspace/Frontend/lightwave-e-com-template/.claude/project-context/08-phase-1-implementation.md`
   - Contains: Step-by-step setup instructions, infrastructure creation, testing checklist

4. **Workspace Context**:
   - File: `/Users/joelschaeffer/dev/lightwave-workspace/CLAUDE.md`
   - Contains: Workspace structure, active projects overview, multi-repo workflow

## What I Need You To Do

**Start by reading these files in order**:

1. Read `.claude/ONBOARDING.md` (mandatory workspace onboarding)
2. Read the 3 project documentation files listed above
3. Review the Phase 1 implementation checklist

**Then, let's begin Phase 1 implementation**:

### Step 1: Infrastructure Setup
- Create or configure AWS RDS PostgreSQL instance
- Create `payload` schema and database users
- Store credentials in AWS Secrets Manager
- Configure AWS SES for email sending
- Create Cloudflare R2 bucket for photo storage

### Step 2: Application Setup
- Rename repository from `lightwave-e-com-template` to `lightwave-joelschaeffer-website`
- Remove e-commerce code (Products, Carts, Orders, Stripe integration)
- Create Artworks and Categories collections
- Configure Payload with PostgreSQL adapter
- Configure AWS SES email transport
- Configure Cloudflare R2 storage adapter

### Step 3: Testing & Deployment
- Test Payload admin locally
- Upload test photos to R2
- Create test artworks
- Test email sending via AWS SES
- Deploy to Cloudflare Pages
- Configure custom domain (joelschaeffer.com)
- Post-deployment verification

## Important Reminders

**Before starting**:
- Set AWS profile: `export AWS_PROFILE=lightwave-admin-new`
- Verify you're in the correct directory: `pwd` should show `Frontend/lightwave-e-com-template`
- Check that all documentation files exist before reading them

**During implementation**:
- Follow the Phase 1 implementation guide step-by-step
- Use AWS Secrets Manager for all credentials (never commit secrets)
- Test each component before moving to the next step
- Keep Phase 2/3 architecture in mind, but don't implement them yet

**Phase 1 scope boundaries**:
- ❌ No Django backend (that's Phase 2)
- ❌ No e-commerce/cart/checkout (that's Phase 3)
- ✅ Only: Gallery display + Payload CMS + direct AWS integrations

## Success Criteria

Phase 1 is complete when:
- [ ] joelschaeffer.com is live on Cloudflare Pages
- [ ] Admin can login to /admin
- [ ] Admin can upload photos to R2 via Payload
- [ ] Photos display correctly in gallery
- [ ] Email sending works (password reset emails)
- [ ] AWS RDS PostgreSQL is connected and stable
- [ ] All environment variables are in AWS Secrets Manager
- [ ] Site scores 90+ on Lighthouse performance

## Questions To Ask Me

Before you start implementation, please:

1. **Confirm you've read the mandatory files**:
   - [ ] `.claude/ONBOARDING.md`
   - [ ] `00-project-overview.md`
   - [ ] `01-architecture-sad.md`
   - [ ] `08-phase-1-implementation.md`

2. **Verify infrastructure decisions**:
   - Do I have an existing AWS RDS instance we can use?
   - Do I have AWS SES configured for joelschaeffer.com domain?
   - Do I have a Cloudflare account with Pages access?

3. **Clarify any assumptions**:
   - Are there any specific Payload collections besides Artworks/Categories?
   - Should we keep any code from the e-commerce template?
   - What's the priority: speed of launch or feature completeness?

## Ready To Start?

Once you've read the documentation and confirmed the prerequisites, let's begin with **Infrastructure Setup (Step 1)** from the Phase 1 implementation guide.

Start by checking if I have an existing AWS RDS instance we can use, or if we need to create a new one.

---

**Last Updated**: 2025-11-01
**Phase**: Phase 1 - Gallery Portfolio (2 weeks)
**Project**: joelschaeffer.com Photography Website
