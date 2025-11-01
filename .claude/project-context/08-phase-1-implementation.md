# Phase 1 Implementation Guide: Gallery Portfolio

**Project:** joelschaeffer.com Photography Website
**Phase:** Phase 1 - Gallery Portfolio (2 weeks)
**Date:** 2025-11-01
**Version:** 1.0.0

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Infrastructure Setup](#infrastructure-setup)
4. [Application Setup](#application-setup)
5. [Configuration](#configuration)
6. [Database Setup](#database-setup)
7. [Testing Checklist](#testing-checklist)
8. [Deployment](#deployment)
9. [Post-Deployment Verification](#post-deployment-verification)
10. [Troubleshooting](#troubleshooting)

---

## Overview

### Phase 1 Goals

Launch a working photography portfolio with:
- ✅ Photography gallery display
- ✅ Payload CMS for content management
- ✅ AWS RDS PostgreSQL database (direct connection)
- ✅ AWS SES email (direct connection)
- ✅ Cloudflare R2 for photo storage
- ✅ Deployed to Cloudflare Pages

### Timeline

**Target:** 2 weeks from start to production deployment

### What You'll Build

```
Cloudflare Pages (Frontend)
  ↓
Payload CMS + Next.js 15
  ↓
AWS RDS PostgreSQL (payload schema)
AWS SES (email)
Cloudflare R2 (photos)
```

---

## Prerequisites

### Tools Required

- **Node.js:** 20.x or later
- **pnpm:** 9.x or later (package manager)
- **Git:** For version control
- **AWS CLI:** Configured with `lightwave-admin-new` profile
- **Wrangler CLI:** For Cloudflare operations (`npm install -g wrangler`)

### Accounts Required

- **AWS Account:** With `lightwave-admin-new` profile configured
- **Cloudflare Account:** With Pages access
- **GitHub Account:** For repository hosting

### Check Prerequisites

```bash
# Verify Node.js version
node --version  # Should be 20.x+

# Verify pnpm
pnpm --version  # Should be 9.x+

# Verify AWS profile
export AWS_PROFILE=lightwave-admin-new
aws sts get-caller-identity  # Should return your identity

# Verify Wrangler
wrangler --version

# Verify git
git --version
```

---

## Infrastructure Setup

### Step 1: Create AWS RDS PostgreSQL Instance

**Option A: Use Existing RDS Instance (Recommended)**

If you already have an AWS RDS PostgreSQL instance:

```bash
# Set AWS profile
export AWS_PROFILE=lightwave-admin-new

# Check existing RDS instances
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus]'

# Note your instance endpoint:
# Example: your-instance.xyz.us-east-1.rds.amazonaws.com
```

**Option B: Create New RDS Instance**

```bash
# Set AWS profile
export AWS_PROFILE=lightwave-admin-new

# Create PostgreSQL instance (adjust parameters as needed)
aws rds create-db-instance \
  --db-instance-identifier joelschaeffer-db \
  --db-instance-class db.t4g.micro \
  --engine postgres \
  --engine-version 15.4 \
  --master-username postgres \
  --master-user-password 'YOUR-SECURE-PASSWORD' \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-xxxxx \
  --db-subnet-group-name default \
  --backup-retention-period 7 \
  --preferred-backup-window "03:00-04:00" \
  --preferred-maintenance-window "mon:04:00-mon:05:00" \
  --multi-az \
  --storage-encrypted \
  --region us-east-1

# Wait for instance to be available (takes ~10-15 minutes)
aws rds wait db-instance-available --db-instance-identifier joelschaeffer-db

# Get the endpoint
aws rds describe-db-instances \
  --db-instance-identifier joelschaeffer-db \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text
```

### Step 2: Create Database Schema and Users

Connect to your RDS instance:

```bash
# Using psql (adjust endpoint and password)
psql "postgresql://postgres:YOUR-PASSWORD@your-instance.xyz.us-east-1.rds.amazonaws.com:5432/postgres"
```

Run the following SQL:

```sql
-- Create database (if not exists)
CREATE DATABASE joelschaeffer;

-- Connect to the database
\c joelschaeffer

-- Create payload schema
CREATE SCHEMA payload;

-- Create payload user
CREATE USER payload_user WITH PASSWORD 'secure-payload-password';

-- Grant privileges
GRANT ALL PRIVILEGES ON SCHEMA payload TO payload_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA payload TO payload_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA payload TO payload_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA payload GRANT ALL ON TABLES TO payload_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA payload GRANT ALL ON SEQUENCES TO payload_user;

-- Create readonly user (for future Django analytics)
CREATE USER readonly_user WITH PASSWORD 'secure-readonly-password';
GRANT USAGE ON SCHEMA payload TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA payload TO readonly_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA payload GRANT SELECT ON TABLES TO readonly_user;

-- Verify
\dn  -- List schemas
\du  -- List users
```

### Step 3: Store Credentials in AWS Secrets Manager

```bash
# Set AWS profile
export AWS_PROFILE=lightwave-admin-new

# Create Payload database secret
aws secretsmanager create-secret \
  --name joelschaeffer/database/payload \
  --description "Payload database connection for joelschaeffer.com" \
  --secret-string '{
    "username": "payload_user",
    "password": "secure-payload-password",
    "host": "your-instance.xyz.us-east-1.rds.amazonaws.com",
    "port": 5432,
    "database": "joelschaeffer",
    "schema": "payload"
  }' \
  --region us-east-1

# Create Payload secret (for JWT signing)
aws secretsmanager create-secret \
  --name joelschaeffer/payload/secret \
  --description "Payload JWT secret for joelschaeffer.com" \
  --secret-string "$(openssl rand -hex 32)" \
  --region us-east-1
```

### Step 4: Configure AWS SES

**Verify Domain:**

```bash
# Verify your domain with SES
aws ses verify-domain-identity \
  --domain joelschaeffer.com \
  --region us-east-1

# Add DNS records (output will show TXT record to add)
# Go to your DNS provider and add the verification TXT record
```

**Create SMTP Credentials:**

```bash
# Create IAM user for SES SMTP
aws iam create-user \
  --user-name joelschaeffer-ses-smtp \
  --region us-east-1

# Attach SES sending policy
aws iam attach-user-policy \
  --user-name joelschaeffer-ses-smtp \
  --policy-arn arn:aws:iam::aws:policy/AmazonSESFullAccess \
  --region us-east-1

# Create access key
aws iam create-access-key \
  --user-name joelschaeffer-ses-smtp \
  --region us-east-1 \
  --query 'AccessKey.{AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}' \
  --output table

# Note: Save AccessKeyId and SecretAccessKey
# Convert to SMTP credentials using AWS documentation:
# https://docs.aws.amazon.com/ses/latest/dg/smtp-credentials.html
```

**Store SES Credentials:**

```bash
# Store in AWS Secrets Manager
aws secretsmanager create-secret \
  --name joelschaeffer/ses/smtp \
  --description "AWS SES SMTP credentials for joelschaeffer.com" \
  --secret-string '{
    "smtp_user": "AKIAIOSFODNN7EXAMPLE",
    "smtp_password": "your-smtp-password",
    "region": "us-east-1"
  }' \
  --region us-east-1
```

### Step 5: Create Cloudflare R2 Bucket

**Using Wrangler:**

```bash
# Login to Cloudflare
wrangler login

# Create R2 bucket
wrangler r2 bucket create joelschaeffer-photos

# List buckets to verify
wrangler r2 bucket list
```

**Create R2 API Token:**

1. Go to Cloudflare Dashboard → R2 → Manage R2 API Tokens
2. Create API token with permissions:
   - Object Read & Write
   - Bucket: `joelschaeffer-photos`
3. Note the Access Key ID and Secret Access Key

**Store R2 Credentials:**

```bash
# Store in AWS Secrets Manager
aws secretsmanager create-secret \
  --name joelschaeffer/cloudflare/r2 \
  --description "Cloudflare R2 credentials for joelschaeffer.com" \
  --secret-string '{
    "bucket": "joelschaeffer-photos",
    "endpoint": "https://your-account-id.r2.cloudflarestorage.com",
    "access_key_id": "your-r2-access-key",
    "secret_access_key": "your-r2-secret-key",
    "public_url": "https://pub-xxxxx.r2.dev"
  }' \
  --region us-east-1
```

---

## Application Setup

### Step 1: Clone and Rename Repository

```bash
# Clone the template repository
cd /Users/joelschaeffer/dev/lightwave-workspace/Frontend
git clone <template-repo-url> lightwave-joelschaeffer-website
cd lightwave-joelschaeffer-website

# Remove old git history and reinitialize
rm -rf .git
git init
git branch -M main

# Update package.json
# Change name to "joelschaeffer-website"
```

### Step 2: Install Dependencies

```bash
# Install all dependencies
pnpm install

# Verify installation
pnpm list --depth=0
```

### Step 3: Remove E-commerce Code

**Delete E-commerce Collections:**

```bash
# Remove e-commerce collections
rm -rf src/collections/Products
rm -rf src/collections/Carts
rm -rf src/collections/Orders
rm -rf src/collections/Transactions
rm -rf src/collections/Addresses

# Remove Stripe integration
rm -rf src/app/api/stripe

# Remove e-commerce pages
rm -rf src/app/(pages)/cart
rm -rf src/app/(pages)/checkout
rm -rf src/app/(pages)/products
```

### Step 4: Create Photography Collections

**Create Artworks Collection:**

```bash
mkdir -p src/collections/Artworks
touch src/collections/Artworks/index.ts
```

Add to `src/collections/Artworks/index.ts`:

```typescript
import type { CollectionConfig } from 'payload'

export const Artworks: CollectionConfig = {
  slug: 'artworks',
  admin: {
    useAsTitle: 'title',
    defaultColumns: ['title', 'category', 'featured', 'status'],
  },
  access: {
    read: () => true,
    create: ({ req: { user } }) => !!user,
    update: ({ req: { user } }) => !!user,
    delete: ({ req: { user } }) => !!user,
  },
  fields: [
    {
      name: 'title',
      type: 'text',
      required: true,
    },
    {
      name: 'slug',
      type: 'text',
      required: true,
      unique: true,
      admin: {
        description: 'URL-friendly version of title',
      },
    },
    {
      name: 'description',
      type: 'richText',
      required: false,
    },
    {
      name: 'mainImage',
      type: 'upload',
      relationTo: 'media',
      required: true,
    },
    {
      name: 'category',
      type: 'relationship',
      relationTo: 'categories',
      required: false,
    },
    {
      name: 'metadata',
      type: 'group',
      fields: [
        { name: 'camera', type: 'text' },
        { name: 'filmStock', type: 'text' },
        { name: 'location', type: 'text' },
        { name: 'captureDate', type: 'date' },
      ],
    },
    {
      name: 'printOptions',
      type: 'array',
      label: 'Print Options (Future E-commerce)',
      fields: [
        {
          name: 'size',
          type: 'text',
          required: true,
        },
        {
          name: 'priceUSD',
          type: 'number',
          required: true,
        },
        {
          name: 'available',
          type: 'checkbox',
          defaultValue: true,
        },
        {
          name: 'printType',
          type: 'select',
          options: ['fine-art', 'canvas', 'metal'],
          defaultValue: 'fine-art',
        },
      ],
    },
    {
      name: 'featured',
      type: 'checkbox',
      defaultValue: false,
      admin: {
        description: 'Feature this artwork on the homepage',
      },
    },
    {
      name: 'status',
      type: 'select',
      options: ['draft', 'published'],
      defaultValue: 'draft',
      required: true,
    },
  ],
}
```

**Create Categories Collection:**

```bash
mkdir -p src/collections/Categories
touch src/collections/Categories/index.ts
```

Add to `src/collections/Categories/index.ts`:

```typescript
import type { CollectionConfig } from 'payload'

export const Categories: CollectionConfig = {
  slug: 'categories',
  admin: {
    useAsTitle: 'name',
  },
  access: {
    read: () => true,
    create: ({ req: { user } }) => !!user,
    update: ({ req: { user } }) => !!user,
    delete: ({ req: { user } }) => !!user,
  },
  fields: [
    {
      name: 'name',
      type: 'text',
      required: true,
    },
    {
      name: 'slug',
      type: 'text',
      required: true,
      unique: true,
    },
    {
      name: 'description',
      type: 'textarea',
    },
    {
      name: 'coverImage',
      type: 'upload',
      relationTo: 'media',
    },
  ],
}
```

---

## Configuration

### Step 1: Configure Environment Variables

Create `.env.local`:

```env
# Database - AWS RDS PostgreSQL
DATABASE_URL=postgresql://payload_user:secure-payload-password@your-instance.xyz.us-east-1.rds.amazonaws.com:5432/joelschaeffer?schema=payload

# AWS SES Email
AWS_SES_SMTP_USER=AKIAIOSFODNN7EXAMPLE
AWS_SES_SMTP_PASSWORD=your-smtp-password
AWS_SES_REGION=us-east-1
EMAIL_FROM=noreply@joelschaeffer.com

# Cloudflare R2 Storage
CLOUDFLARE_R2_BUCKET=joelschaeffer-photos
CLOUDFLARE_R2_ENDPOINT=https://your-account-id.r2.cloudflarestorage.com
CLOUDFLARE_R2_ACCESS_KEY_ID=your-r2-access-key
CLOUDFLARE_R2_SECRET_ACCESS_KEY=your-r2-secret-key
CLOUDFLARE_R2_PUBLIC_URL=https://pub-xxxxx.r2.dev

# Payload Configuration
PAYLOAD_SECRET=your-64-character-random-string
NEXT_PUBLIC_SERVER_URL=http://localhost:3000
PAYLOAD_PUBLIC_SERVER_URL=http://localhost:3000

# Node Environment
NODE_ENV=development
```

### Step 2: Update Payload Config

Edit `src/payload.config.ts`:

```typescript
import { buildConfig } from 'payload'
import { postgresAdapter } from '@payloadcms/db-postgres'
import { lexicalEditor } from '@payloadcms/richtext-lexical'
import { s3Storage } from '@payloadcms/storage-s3'
import { nodemailerAdapter } from '@payloadcms/email-nodemailer'

// Import collections
import { Users } from './collections/Users'
import { Media } from './collections/Media'
import { Pages } from './collections/Pages'
import { Artworks } from './collections/Artworks'
import { Categories } from './collections/Categories'

export default buildConfig({
  serverURL: process.env.PAYLOAD_PUBLIC_SERVER_URL || '',
  collections: [
    Users,
    Media,
    Pages,
    Artworks,
    Categories,
  ],
  editor: lexicalEditor({}),
  db: postgresAdapter({
    pool: {
      connectionString: process.env.DATABASE_URL,
    },
    schemaName: 'payload',
  }),
  email: nodemailerAdapter({
    defaultFromAddress: process.env.EMAIL_FROM || 'noreply@joelschaeffer.com',
    defaultFromName: 'Joel Schaeffer Photography',
    transport: {
      host: `email-smtp.${process.env.AWS_SES_REGION}.amazonaws.com`,
      port: 587,
      auth: {
        user: process.env.AWS_SES_SMTP_USER,
        pass: process.env.AWS_SES_SMTP_PASSWORD,
      },
    },
  }),
  plugins: [
    s3Storage({
      collections: {
        media: {
          prefix: 'media',
        },
      },
      bucket: process.env.CLOUDFLARE_R2_BUCKET || '',
      config: {
        endpoint: process.env.CLOUDFLARE_R2_ENDPOINT || '',
        region: 'auto',
        credentials: {
          accessKeyId: process.env.CLOUDFLARE_R2_ACCESS_KEY_ID || '',
          secretAccessKey: process.env.CLOUDFLARE_R2_SECRET_ACCESS_KEY || '',
        },
      },
    }),
  ],
  secret: process.env.PAYLOAD_SECRET || '',
  typescript: {
    outputFile: './payload-types.ts',
  },
})
```

---

## Database Setup

### Step 1: Run Payload Migrations

```bash
# Generate Payload types
pnpm payload generate:types

# Run database migrations
pnpm payload migrate

# Verify migration
# Connect to database and check tables:
# psql "postgresql://payload_user:PASSWORD@your-instance/joelschaeffer?schema=payload"
# \dt payload.*
```

### Step 2: Create Admin User

```bash
# Start dev server
pnpm dev

# Navigate to http://localhost:3000/admin
# Complete the setup wizard to create your admin user
```

---

## Testing Checklist

### Local Testing

- [ ] **Payload Admin Login**
  ```bash
  # Open browser
  open http://localhost:3000/admin
  # Login with admin credentials
  ```

- [ ] **Upload Test Photo**
  - Login to Payload admin
  - Navigate to Media collection
  - Upload a test image
  - Verify upload appears in Cloudflare R2

- [ ] **Create Test Artwork**
  - Navigate to Artworks collection
  - Create new artwork with uploaded image
  - Set status to "published"
  - Verify artwork appears in database

- [ ] **Test Email Sending**
  - In Payload admin, use "Forgot Password" feature
  - Verify email is sent via AWS SES
  - Check AWS SES console for sending metrics

- [ ] **Test Gallery Page**
  - Create gallery page component
  - Verify artworks display correctly
  - Test image loading from R2 CDN

### Database Verification

```bash
# Connect to database
psql "postgresql://payload_user:PASSWORD@your-instance.xyz.us-east-1.rds.amazonaws.com:5432/joelschaeffer?schema=payload"

# Check tables
\dt payload.*

# Check artworks
SELECT id, title, status FROM payload.artworks;

# Check media
SELECT id, filename, url FROM payload.media;
```

---

## Deployment

### Step 1: Create GitHub Repository

```bash
# Create repository on GitHub (via web interface or gh CLI)
gh repo create lightwave-joelschaeffer-website --public

# Add remote and push
git remote add origin https://github.com/lightwave-media/lightwave-joelschaeffer-website.git
git add .
git commit -m "feat: initial Phase 1 implementation"
git push -u origin main
```

### Step 2: Configure Cloudflare Pages

**Via Cloudflare Dashboard:**

1. Go to Pages → Create a project
2. Connect to GitHub repository
3. Configure build settings:
   - **Build command:** `pnpm build`
   - **Build output directory:** `.next`
   - **Root directory:** `/`
   - **Node version:** `20.x`

4. Add environment variables:
   ```
   DATABASE_URL=postgresql://payload_user:PASSWORD@...
   AWS_SES_SMTP_USER=...
   AWS_SES_SMTP_PASSWORD=...
   AWS_SES_REGION=us-east-1
   EMAIL_FROM=noreply@joelschaeffer.com
   CLOUDFLARE_R2_BUCKET=joelschaeffer-photos
   CLOUDFLARE_R2_ENDPOINT=https://...
   CLOUDFLARE_R2_ACCESS_KEY_ID=...
   CLOUDFLARE_R2_SECRET_ACCESS_KEY=...
   CLOUDFLARE_R2_PUBLIC_URL=https://...
   PAYLOAD_SECRET=your-secret
   NEXT_PUBLIC_SERVER_URL=https://joelschaeffer.com
   PAYLOAD_PUBLIC_SERVER_URL=https://joelschaeffer.com
   NODE_ENV=production
   ```

5. Save and deploy

**Via Wrangler (Alternative):**

```bash
# Login to Cloudflare
wrangler login

# Deploy
wrangler pages deploy .next \
  --project-name joelschaeffer-website \
  --branch main
```

### Step 3: Configure Custom Domain

1. Go to Cloudflare Pages → joelschaeffer-website → Custom domains
2. Add domain: `joelschaeffer.com`
3. Cloudflare will automatically configure DNS records
4. Wait for SSL certificate provisioning (~5 minutes)

### Step 4: Verify Production Deployment

- [ ] **Visit Production URL**
  ```
  https://joelschaeffer.com
  ```

- [ ] **Test Admin Login**
  ```
  https://joelschaeffer.com/admin
  ```

- [ ] **Upload Production Photo**
  - Login to admin
  - Upload test photo
  - Verify appears in R2
  - Verify displays on site

- [ ] **Test Email in Production**
  - Use "Forgot Password"
  - Verify email received

---

## Post-Deployment Verification

### Performance Check

```bash
# Check Lighthouse scores
npx lighthouse https://joelschaeffer.com --view

# Target scores:
# - Performance: 90+
# - Accessibility: 95+
# - Best Practices: 95+
# - SEO: 90+
```

### Security Check

- [ ] **HTTPS Enabled:** All requests redirect to HTTPS
- [ ] **Security Headers:** Check via [securityheaders.com](https://securityheaders.com)
- [ ] **SSL Certificate:** Valid and trusted
- [ ] **CORS:** Only allows expected origins

### Database Check

```bash
# Verify database connectivity from production
# Check RDS CloudWatch metrics for connections
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=joelschaeffer-db \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average \
  --region us-east-1
```

---

## Troubleshooting

### Database Connection Issues

**Problem:** "Could not connect to database"

**Solutions:**

1. Verify RDS security group allows inbound connections:
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier joelschaeffer-db \
     --query 'DBInstances[0].VpcSecurityGroups'
   ```

2. Check DATABASE_URL format:
   ```
   postgresql://payload_user:PASSWORD@host:5432/joelschaeffer?schema=payload
   ```

3. Test direct connection:
   ```bash
   psql "postgresql://payload_user:PASSWORD@host:5432/joelschaeffer?schema=payload"
   ```

### Email Not Sending

**Problem:** AWS SES emails not delivering

**Solutions:**

1. Verify domain is verified in SES:
   ```bash
   aws ses get-identity-verification-attributes \
     --identities joelschaeffer.com \
     --region us-east-1
   ```

2. Check if SES is in sandbox mode:
   ```bash
   aws ses get-account-sending-enabled --region us-east-1
   ```

3. Verify SMTP credentials are correct

4. Check AWS SES sending limits and bounce rates

### R2 Upload Failures

**Problem:** Images not uploading to Cloudflare R2

**Solutions:**

1. Verify R2 bucket exists:
   ```bash
   wrangler r2 bucket list
   ```

2. Check R2 API token permissions

3. Verify R2 credentials in environment variables

4. Test R2 connection with AWS CLI:
   ```bash
   aws s3 ls s3://joelschaeffer-photos \
     --endpoint-url=https://your-account-id.r2.cloudflarestorage.com
   ```

### Build Failures on Cloudflare Pages

**Problem:** Build fails during deployment

**Solutions:**

1. Check build logs in Cloudflare Pages dashboard

2. Verify Node.js version matches local (20.x)

3. Ensure all environment variables are set

4. Test build locally:
   ```bash
   NODE_ENV=production pnpm build
   ```

---

## Next Steps

Once Phase 1 is deployed and verified:

1. **Monitor Performance:**
   - Set up Cloudflare Web Analytics
   - Monitor AWS RDS CloudWatch metrics
   - Track Payload API response times

2. **Content Population:**
   - Upload photography portfolio
   - Create About and Contact pages
   - Optimize images for web

3. **Plan Phase 2:**
   - Review Phase 2 requirements (Django backend)
   - Plan Django infrastructure (AWS ECS)
   - Design analytics and email service APIs

---

## Related Documents

- **Project Overview:** `00-project-overview.md` - 3-phase roadmap
- **Architecture:** `01-architecture-sad.md` - Full system architecture
- **Database Strategy:** `04-database-strategy.md` - Multi-schema approach

---

**Last Updated:** 2025-11-01
**Phase:** Phase 1 - Gallery Portfolio
**Status:** Implementation Guide
**Maintained By:** Joel Schaeffer + Claude Code
