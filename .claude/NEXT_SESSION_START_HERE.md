# 🚀 Next Session: Start Here

**Last Updated:** 2025-11-01
**Status:** Git initialization blocked - needs fresh bash session

---

## What Happened This Session

✅ **Completed:**
1. Renamed repository: `lightwave-e-com-template` → `lightwave-joelschaeffer-website`
2. Updated `package.json` with new name
3. Researched site architectures (joelschaeffer.com, reedmorano.com, lik.com)
4. Created comprehensive implementation plan
5. Made key architectural decisions
6. Created git initialization script

❌ **Blocked:**
- Git initialization - bash session stuck on old directory path

---

## First Steps in New Session

### 1. Initialize Git Repository

**Run this ONE command:**
```bash
chmod +x /Users/joelschaeffer/dev/lightwave-workspace/Frontend/lightwave-joelschaeffer-website/init-git.sh && /Users/joelschaeffer/dev/lightwave-workspace/Frontend/lightwave-joelschaeffer-website/init-git.sh
```

This will:
- Initialize git with `main` branch
- Commit baseline template code
- Create `develop` branch
- Create `feature/portfolio/task-001-dual-portfolio-setup` branch
- Checkout feature branch

**Verify it worked:**
```bash
cd /Users/joelschaeffer/dev/lightwave-workspace/Frontend/lightwave-joelschaeffer-website
git branch -a
# Should show: main, develop, feature/portfolio/task-001-dual-portfolio-setup
```

### 2. Create GitHub Repository

```bash
gh repo create lightwave-media/lightwave-joelschaeffer-website --public --description "Joel Schaeffer Photography & Cinematography Portfolio with E-commerce - Powered by LightWave Media LLC"
```

### 3. Push to GitHub

```bash
git remote add origin https://github.com/lightwave-media/lightwave-joelschaeffer-website.git
git push -u origin main
git push origin develop
git push origin feature/portfolio/task-001-dual-portfolio-setup
```

### 4. Deploy to Cloudflare Pages (Temp URL)

**Goal:** Get the template live ASAP to verify deployment works

**Via Cloudflare Dashboard:**
1. Go to Pages → Create a project
2. Connect to GitHub: `lightwave-media/lightwave-joelschaeffer-website`
3. Build settings:
   - Build command: `pnpm build`
   - Build output: `.next`
   - Node version: `20.x`
4. Add environment variables (MongoDB for now):
   ```
   DATABASE_URI=<MongoDB connection string>
   PAYLOAD_SECRET=<random 64-char string>
   NEXT_PUBLIC_SERVER_URL=https://temp-url.pages.dev
   PAYLOAD_PUBLIC_SERVER_URL=https://temp-url.pages.dev
   NODE_ENV=production
   ```
5. Deploy!

**Test deployment:**
- Visit temp URL (e.g., `joelschaeffer-website-abc.pages.dev`)
- Should see e-commerce template homepage
- Verify `/admin` works
- Verify shop pages work

---

## Then: Phase 1 Implementation

Once deployed to temp URL, start Phase 1:

### Collections Update

1. **Create Artworks collection** (`src/collections/Artworks.ts`)
   - Unified collection with `type` field
   - Conditional fields based on type
   - See: `09-implementation-plan-dual-portfolio.md` for schema

2. **Update Categories collection** (`src/collections/Categories.ts`)
   - Add `type` field (cinematography | photography)
   - Add `order` field for sorting

3. **Update Products collection** (`src/collections/Products/index.ts`)
   - Add `relatedArtwork` field (relationship to Artworks)
   - Add `type` field (print | consulting-package)

4. **Update payload.config.ts**
   - Import Artworks collection
   - Add to collections array
   - Keep all existing collections (Products, Carts, Orders, etc.)

### Frontend Pages

5. **Create portfolio pages:**
   - `app/(pages)/cinematography/page.tsx`
   - `app/(pages)/cinematography/[category]/page.tsx`
   - `app/(pages)/photography/page.tsx`
   - `app/(pages)/photography/[category]/page.tsx`
   - `app/(pages)/work/[slug]/page.tsx`

6. **Create components:**
   - `components/VideoEmbed.tsx` (Vimeo/YouTube)
   - `components/PhotoGallery.tsx` (lightbox)
   - `components/CategoryGrid.tsx` (reusable)
   - `components/ArtworkGrid.tsx` (adapts to type)
   - `components/FeaturedCarousel.tsx` (homepage)

7. **Update navigation:**
   - Update `components/Header/index.tsx` with dual dropdowns

---

## Infrastructure (After Frontend Working)

### AWS RDS PostgreSQL

**Note:** Template uses MongoDB adapter currently - migration needed

1. Create AWS RDS instance (or use existing)
2. Create `payload` schema
3. Create database users
4. Store credentials in AWS Secrets Manager
5. Update both sites to use PostgreSQL adapter

### AWS SES

1. Verify lightwave-media.ltd domain
2. Add DNS TXT records
3. Create SMTP credentials
4. Update Payload email config

### Cloudflare R2

1. Create bucket: `joelschaeffer-photos`
2. Generate API tokens
3. Update Payload storage adapter

---

## Key Decisions Already Made

✅ **Unified Artworks collection** (not separate collections)
✅ **Shared database** (both Payload sites connect to same RDS)
✅ **Invoice system in lightwave-media-site** (accessed by joelschaeffer.com)
✅ **Vimeo/YouTube embeds** (not self-hosted video)
✅ **Keep ALL e-commerce code** (shop launches with portfolio)
✅ **Email from @lightwave-media.ltd** (business email domain)
✅ **PostgreSQL not MongoDB** (for shared infrastructure)

---

## Files to Read

**Implementation Plan:**
- `.claude/project-context/09-implementation-plan-dual-portfolio.md` - **COMPLETE PLAN**

**Original Plans (reference only):**
- `.claude/project-context/00-project-overview.md` - Original 3-phase (needs update)
- `.claude/project-context/01-architecture-sad.md` - Architecture docs (needs update)
- `.claude/project-context/08-phase-1-implementation.md` - Old Phase 1 (superseded)

**Workspace:**
- `/Users/joelschaeffer/dev/lightwave-workspace/CLAUDE.md` - Workspace guide
- `.agent/metadata/naming_conventions.yaml` - Git conventions

---

## Quick Commands Reference

**Git:**
```bash
git status
git branch -a
git checkout feature/portfolio/task-001-dual-portfolio-setup
```

**Development:**
```bash
pnpm install
pnpm dev  # Starts on port 3000 (or 3001 if 3000 busy)
pnpm build
```

**Deployment:**
```bash
git add .
git commit -m "feat(portfolio): implement dual portfolio collections"
git push origin feature/portfolio/task-001-dual-portfolio-setup
```

---

## Remember

1. **Set AWS profile:** `export AWS_PROFILE=lightwave-admin-new`
2. **Read onboarding:** `.claude/ONBOARDING.md` (every session)
3. **Check git branch:** Make sure you're on feature branch
4. **MongoDB for now:** PostgreSQL migration comes later
5. **Test locally first:** Before pushing to production

---

**Ready!** Start new chat → Initialize git → Deploy to Cloudflare → Begin Phase 1
