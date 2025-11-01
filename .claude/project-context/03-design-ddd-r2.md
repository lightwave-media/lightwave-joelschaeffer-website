**Version:** 1.0.0

**Date:** 2025-11-01

**Author(s):** v_product_architect (reviewed by Joel Schaeffer)

**Status:** Approved

**Related User Story:** US-JS-002: Payload CMS + Cloudflare R2 Integration

**Related Sprint:** Sprint 1: [joelschaeffer.com](http://joelschaeffer.com) Foundation Build

**Related PRD:** LWM [joelschaeffer.com](http://joelschaeffer.com) Photography Site - PRD - v1.0.0

---

## 1. Introduction & Purpose

This Detailed Design Document specifies the technical implementation for integrating Payload CMS with Cloudflare R2 object storage for the [joelschaeffer.com](http://joelschaeffer.com) photography website. The design addresses the critical requirement that Cloudflare Pages (the deployment target) is stateless and cannot use local filesystem storage.

**Problem Solved:** Enable production-ready image uploads and storage for Payload CMS on a serverless, stateless hosting platform.

**Scope:** Covers custom Payload storage adapter implementation, Cloudflare R2 bucket configuration, collection schema design, and upload workflow.

---

## 2. Requirements Addressed

**From US-JS-002 Acceptance Criteria:**

- ✅ Photography Artworks collection with embedded printOptions array
- ✅ Cloudflare R2 bucket configured with public access
- ✅ Custom Payload storage adapter (R2 upload/delete/generateURL)
- ✅ Media uploads working to R2 with sample image testing
- ✅ Pages collection for About/Contact content
- ✅ All collections accessible in Payload admin

**From Architecture Review:**

- Admin-only authentication (no customer accounts)
- Embedded print pricing model (array in Artworks, not separate collection)
- Separate /photo and /cinema URL structure
- R2 integration mandatory for Phase 1 (not optional)

---

## 3. Proposed Design

### 3.1. Overview & Architecture

**High-Level Flow:**

```
Payload Admin UI → Payload API → Custom R2 Adapter → Cloudflare R2 Bucket → Cloudflare CDN → User Browser
```

**Key Components:**

1. **Payload CMS Collections** - Define data models (Artworks, Pages, Media)
2. **Custom Storage Adapter** - Abstracts R2 API calls for Payload
3. **Cloudflare R2 Bucket** - Stores uploaded images with public access
4. **Cloudflare CDN** - Delivers images via custom domain ([cdn.joelschaeffer.com](http://cdn.joelschaeffer.com))

**Architecture Diagram (Text):**

```
┌─────────────────┐
│  Payload Admin  │
└────────┬────────┘
         │ Upload Image
         ▼
┌─────────────────────────┐
│   Payload API Server    │
│  (Next.js API Routes)   │
└────────┬────────────────┘
         │ Calls adapter methods
         ▼
┌─────────────────────────┐
│  Custom R2 Adapter      │
│  - handleUpload()       │
│  - handleDelete()       │
│  - generateURL()        │
└────────┬────────────────┘
         │ AWS SDK S3 Client
         ▼
┌─────────────────────────┐
│   Cloudflare R2 Bucket  │
│   (S3-compatible API)   │
└────────┬────────────────┘
         │ Public Access Policy
         ▼
┌─────────────────────────┐
│    Cloudflare CDN       │
│  [cdn.joelschaeffer.com](http://cdn.joelschaeffer.com)  │
└─────────────────────────┘
```

---

### 3.2. Data Model / Database Schema Changes

**Collection: Photography Artworks**

```tsx
// src/collections/Artworks.ts
export const Artworks: CollectionConfig = {
  slug: 'artworks',
  admin: {
    useAsTitle: 'title',
    defaultColumns: ['title', 'category', 'featured', 'status'],
  },
  access: {
    read: () => true, // Public read for gallery display
    create: ({ req: { user } }) => !!user, // Admin only
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
      unique: true,
      admin: {
        position: 'sidebar',
      },
      hooks: {
        beforeValidate: [
          ({ value, operation, data }) => {
            if (operation === 'create' || !value) {
              return formatSlug(data?.title || '');
            }
            return value;
          },
        ],
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
      relationTo: 'media', // References Media collection
      required: true,
    },
    {
      name: 'printOptions', // EMBEDDED array model
      type: 'array',
      fields: [
        {
          name: 'size',
          type: 'text',
          required: true,
          admin: {
            placeholder: '8x10, 16x20, 24x36',
          },
        },
        {
          name: 'priceUSD',
          type: 'number',
          required: true,
          min: 0,
        },
        {
          name: 'available',
          type: 'checkbox',
          defaultValue: true,
        },
        {
          name: 'printType',
          type: 'select',
          options: [
            { label: 'Fine Art Print', value: 'fine-art' },
            { label: 'Canvas', value: 'canvas' },
            { label: 'Metal Print', value: 'metal' },
          ],
          required: true,
        },
      ],
    },
    {
      name: 'category',
      type: 'select',
      options: [
        { label: 'Landscape', value: 'landscape' },
        { label: 'Portrait', value: 'portrait' },
        { label: 'Abstract', value: 'abstract' },
        { label: 'Street', value: 'street' },
      ],
      required: true,
    },
    {
      name: 'featured',
      type: 'checkbox',
      defaultValue: false,
      admin: {
        description: 'Display on homepage/featured gallery',
      },
    },
    {
      name: 'status',
      type: 'select',
      options: [
        { label: 'Draft', value: 'draft' },
        { label: 'Published', value: 'published' },
      ],
      defaultValue: 'draft',
      required: true,
    },
    {
      name: 'seo',
      type: 'group',
      fields: [
        {
          name: 'metaTitle',
          type: 'text',
        },
        {
          name: 'metaDescription',
          type: 'textarea',
          maxLength: 160,
        },
      ],
    },
  ],
};
```

**Collection: Media (R2 Storage)**

```tsx
// src/collections/Media.ts
import { r2Adapter } from '../lib/r2-adapter';

export const Media: CollectionConfig = {
  slug: 'media',
  upload: {
    staticURL: '/media',
    staticDir: 'media', // Ignored in production, required by Payload
    adminThumbnail: 'thumbnail',
    imageSizes: [
      {
        name: 'thumbnail',
        width: 400,
        height: 300,
        position: 'centre',
      },
      {
        name: 'card',
        width: 768,
        height: 1024,
        position: 'centre',
      },
      {
        name: 'tablet',
        width: 1024,
        undefined: true, // Maintain aspect ratio
        position: 'centre',
      },
    ],
    // Custom R2 adapter
    adapter: r2Adapter({
      bucket: process.env.CLOUDFLARE_R2_BUCKET!,
      config: {
        region: 'auto',
        endpoint: process.env.CLOUDFLARE_R2_ENDPOINT!,
        credentials: {
          accessKeyId: process.env.CLOUDFLARE_R2_ACCESS_KEY_ID!,
          secretAccessKey: process.env.CLOUDFLARE_R2_SECRET_ACCESS_KEY!,
        },
      },
    }),
  },
  access: {
    read: () => true, // Public read for images
    create: ({ req: { user } }) => !!user,
    update: ({ req: { user } }) => !!user,
    delete: ({ req: { user } }) => !!user,
  },
  fields: [
    {
      name: 'alt',
      type: 'text',
      required: true,
    },
  ],
};
```

**Collection: Pages**

```tsx
// src/collections/Pages.ts
export const Pages: CollectionConfig = {
  slug: 'pages',
  admin: {
    useAsTitle: 'title',
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
      unique: true,
      required: true,
    },
    {
      name: 'content',
      type: 'richText',
      required: true,
    },
    {
      name: 'seo',
      type: 'group',
      fields: [
        { name: 'metaTitle', type: 'text' },
        { name: 'metaDescription', type: 'textarea', maxLength: 160 },
      ],
    },
  ],
};
```

---

### 3.3. API Design (Custom R2 Adapter)

**Adapter Interface (Payload 2.x):**

```tsx
// src/lib/r2-adapter.ts
import { S3Client, PutObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import type { Adapter } from 'payload/dist/uploads/types';

interface R2AdapterArgs {
  bucket: string;
  config: {
    region: string;
    endpoint: string;
    credentials: {
      accessKeyId: string;
      secretAccessKey: string;
    };
  };
}

export const r2Adapter = ({ bucket, config }: R2AdapterArgs): Adapter => {
  const s3Client = new S3Client(config);

  return {
    name: 'cloudflare-r2-adapter',

    // Generate public URL for uploaded file
    generateURL: ({ filename, prefix = '' }: { filename: string; prefix?: string }): string => {
      const cdnDomain = process.env.CLOUDFLARE_CDN_DOMAIN || `${bucket}.[r2.cloudflarestorage.com](http://r2.cloudflarestorage.com)`;
      const path = prefix ? `${prefix}/${filename}` : filename;
      return `https://${cdnDomain}/${path}`;
    },

    // Upload file to R2
    handleUpload: async ({ data, filename }: { data: Buffer; filename: string }): Promise<{ filename: string }> => {
      const key = filename;

      const command = new PutObjectCommand({
        Bucket: bucket,
        Key: key,
        Body: data,
        ContentType: getContentType(filename),
      });

      await s3Client.send(command);

      return { filename: key };
    },

    // Delete file from R2
    handleDelete: async ({ filename }: { filename: string }): Promise<void> => {
      const command = new DeleteObjectCommand({
        Bucket: bucket,
        Key: filename,
      });

      await s3Client.send(command);
    },
  };
};

// Helper: Determine content type from filename
function getContentType(filename: string): string {
  const ext = filename.split('.').pop()?.toLowerCase();
  const mimeTypes: Record<string, string> = {
    jpg: 'image/jpeg',
    jpeg: 'image/jpeg',
    png: 'image/png',
    gif: 'image/gif',
    webp: 'image/webp',
  };
  return mimeTypes[ext || ''] || 'application/octet-stream';
}
```

**Environment Variables (.env.local):**

```bash
CLOUDFLARE_R2_BUCKET=joelschaeffer-media
CLOUDFLARE_R2_ENDPOINT=https://<account-id>.[r2.cloudflarestorage.com](http://r2.cloudflarestorage.com)
CLOUDFLARE_R2_ACCESS_KEY_ID=<your-access-key>
CLOUDFLARE_R2_SECRET_ACCESS_KEY=<your-secret-key>
CLOUDFLARE_CDN_DOMAIN=[cdn.joelschaeffer.com](http://cdn.joelschaeffer.com)
```

---

### 3.4. Key Algorithms & Logic Flows

**Upload Workflow:**

```
1. Admin selects image in Payload UI
2. Payload validates file type, size
3. Payload generates image sizes (thumbnail, card, tablet)
4. For each size:
   a. Call r2Adapter.handleUpload({ data: buffer, filename })
   b. S3Client.send(PutObjectCommand) → R2 bucket
   c. Return filename
5. Payload stores metadata in PostgreSQL:
   - filename
   - URL (from generateURL())
   - sizes array
   - alt text
6. Admin sees uploaded image in Media collection
```

**Retrieval Workflow:**

```
1. User visits /photo/gallery
2. Next.js page queries Payload API: GET /api/artworks?status=published
3. Payload returns artwork data with mainImage URLs
4. Next.js <Image> component fetches from [cdn.joelschaeffer.com](http://cdn.joelschaeffer.com)
5. Cloudflare CDN caches and delivers image
```

---

### 3.5. Integration with Other Services

**Cloudflare R2 Bucket Setup:**

1. Create bucket via Cloudflare dashboard: `joelschaeffer-media`
2. Generate R2 API credentials (Access Key ID + Secret)
3. Configure public access policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::joelschaeffer-media/*"
    }
  ]
}
```

1. Set up custom domain: [cdn.joelschaeffer.com](http://cdn.joelschaeffer.com) → R2 bucket

**Next.js Image Optimization:**

```tsx
// next.config.js
module.exports = {
  images: {
    domains: ['[cdn.joelschaeffer.com](http://cdn.joelschaeffer.com)'],
    formats: ['image/avif', 'image/webp'],
  },
};
```

---

### 3.6. Error Handling & Resilience

**Upload Failures:**

- Retry logic: 3 attempts with exponential backoff
- Fallback: Store temp file locally, queue for later upload
- User feedback: "Upload failed, retrying..."

**R2 Unavailability:**

- Graceful degradation: Show placeholder images
- Admin notification: "R2 connection issue"
- Queue uploads for retry

**Invalid File Types:**

- Validate before upload (client-side + server-side)
- Allowed: jpg, jpeg, png, webp, gif
- Max size: 20MB per file

---

### 3.7. Security Considerations

**Access Control:**

- R2 bucket: Public read, no public write
- Payload admin: JWT authentication required
- File uploads: Admin-only (enforced in collection access config)

**Input Validation:**

- File type whitelist (images only)
- File size limits (20MB max)
- Filename sanitization (remove special chars, spaces)

**CORS Configuration:**

```jsx
// R2 CORS policy
[
  {
    "AllowedOrigins": ["https://joelschaeffer.com", "https://*.pages.dev"],
    "AllowedMethods": ["GET", "HEAD"],
    "AllowedHeaders": ["*"],
    "MaxAgeSeconds": 3600
  }
]
```

---

## 4. Alternatives Considered

**Alternative 1: Vercel Blob Storage**

- Pros: Simpler integration, good Next.js support
- Cons: Higher cost, vendor lock-in, not R2
- **Rejected:** Project requires Cloudflare Pages, so R2 is logical pairing

**Alternative 2: Local Storage + Manual S3 Sync**

- Pros: No custom adapter needed
- Cons: Won't work on Cloudflare Pages (stateless), manual process
- **Rejected:** Not viable for serverless deployment

**Alternative 3: External Media Service (Cloudinary, Imgix)**

- Pros: Built-in CDN, transformations, no custom code
- Cons: Monthly costs, less control, additional service dependency
- **Rejected:** Want to own infrastructure, R2 more cost-effective long-term

---

## 5. Scalability & Performance Implications

**Storage Scaling:**

- R2 has no storage limits (pay per GB)
- CDN caching reduces bandwidth costs
- Image sizes optimized (thumbnail, card, tablet) reduce payload

**Performance Optimizations:**

- Cloudflare CDN edge caching (close to users)
- Next.js Image component lazy loading
- WebP/AVIF format serving (smaller files)
- Responsive images (srcset generation)

**Bottlenecks:**

- Upload speed limited by user's connection, not R2
- Payload API queries (PostgreSQL) - add indexes on status, category

---

## 6. Testing Strategy

**Unit Tests:**

- R2 adapter methods (handleUpload, handleDelete, generateURL)
- Mock S3Client responses
- Validate URL generation logic

**Integration Tests:**

- Full upload flow: Payload UI → R2 bucket
- Verify file appears in bucket
- Verify URL is accessible
- Test image size generation

**Manual Testing Checklist:**

- [ ]  Upload JPG, PNG, WebP images
- [ ]  Verify all sizes generated correctly
- [ ]  Check URLs resolve from CDN
- [ ]  Test delete functionality
- [ ]  Verify broken image handling
- [ ]  Test upload with poor network (retry logic)

---

## 7. Deployment Considerations

**Environment Variables (Cloudflare Pages):**

- Set via Cloudflare dashboard (not .env file)
- Required: R2 credentials, bucket name, endpoint, CDN domain

**Build Configuration:**

```yaml
# wrangler.toml (if using Wrangler for deployment)
bucket_name = "joelschaeffer-media"
r2_binding = "MY_BUCKET"
```

**Deployment Steps:**

1. Create R2 bucket and credentials
2. Configure Cloudflare Pages environment variables
3. Deploy to preview branch first
4. Test upload flow on preview
5. Promote to production

---

## 8. Open Questions / Unresolved Issues

1. **Image Optimization Settings:** What quality level for each size? (Default: 80% for jpg, lossless for png)
2. **CDN Cache TTL:** How long should images be cached? (Proposed: 1 year, use cache-busting if updated)
3. **Backup Strategy:** Should R2 bucket have versioning enabled? (Recommended: Yes, for accidental deletion recovery)
4. **Monitoring:** Do we need alerts for R2 upload failures? (Proposed: Email admin on 3+ consecutive failures)

---

**Related Documents:**

- PRD: LWM [joelschaeffer.com](http://joelschaeffer.com) Photography Site - PRD - v1.0.0
- User Story: US-JS-002: Payload CMS + Cloudflare R2 Integration
- Sprint: Sprint 1: [joelschaeffer.com](http://joelschaeffer.com) Foundation Build
- Architecture Review: v_product_architect (2025-11-01)