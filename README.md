# Joel Schaeffer Photography & Cinematography

**Professional portfolio and print shop for Joel Schaeffer - Photographer & Cinematographer**

Built with ❤️ by [LightWave Media LLC](https://lightwave-media.ltd)

---

## 🎬 About

Joel Schaeffer is a photographer and cinematographer specializing in capturing the beauty of the outdoors. This website showcases his work across two distinct portfolios:

- **📸 Photography**: High-resolution stills, landscape photography, and print-worthy images
- **🎥 Cinematography**: Video projects, reels, and motion picture work

The site also features an integrated **print shop** where visitors can purchase high-quality prints of Joel's photography work.

---

## 🏗️ Architecture

This project is built on the **Payload CMS 3.x E-commerce Template** and customized for a dual-portfolio experience with e-commerce capabilities.

### Tech Stack

- **Framework**: [Next.js 15](https://nextjs.org) (App Router)
- **CMS**: [Payload CMS 3.x](https://payloadcms.com)
- **Language**: TypeScript
- **Styling**: TailwindCSS + [shadcn/ui](https://ui.shadcn.com)
- **Forms**: React Hook Form
- **Database**: PostgreSQL (AWS RDS) / MongoDB (development)
- **Storage**: Cloudflare R2 (S3-compatible object storage)
- **Email**: AWS SES via @lightwave-media.ltd domain
- **Payments**: Stripe
- **Deployment**: Cloudflare Pages

### Key Features

✅ **Dual Portfolio System**
- Unified `Artworks` collection with conditional fields based on type (photography | cinematography)
- Separate landing pages for each portfolio type
- Category filtering per portfolio type
- Featured works carousel on homepage

✅ **E-commerce Capabilities**
- Full-featured print shop built on Payload Ecommerce plugin
- Product variants (print sizes, paper types)
- Shopping cart and checkout flow
- Stripe payment integration
- Order tracking and customer accounts

✅ **Professional CMS Features**
- Layout builder with custom blocks (Hero, Gallery, Video Embed, etc.)
- Draft previews and live preview
- SEO optimization with meta tags and Open Graph
- Image focal point and manual cropping
- Scheduled publishing with job queue

✅ **Authentication & Access Control**
- Admin users (full CMS access)
- Customer accounts (order history, saved addresses)
- Guest checkout support

---

## 🚀 Quick Start

### Prerequisites

- Node.js 20.x or higher
- pnpm (recommended) or npm
- PostgreSQL database OR MongoDB (for development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/lightwave-media/lightwave-joelschaeffer-website.git
   cd lightwave-joelschaeffer-website
   ```

2. **Install dependencies**
   ```bash
   pnpm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` and configure:
   - Database connection string (`DATABASE_URI`)
   - Payload secret (`PAYLOAD_SECRET`)
   - Server URL (`NEXT_PUBLIC_SERVER_URL`)
   - Stripe keys (for payments)
   - Email/SMTP settings (AWS SES)
   - Storage settings (Cloudflare R2)

4. **Start development server**
   ```bash
   pnpm dev
   ```

5. **Access the app**
   - Frontend: `http://localhost:3000`
   - Admin panel: `http://localhost:3000/admin`

6. **Create your first admin user**
   Follow the on-screen prompts to create an admin account.

---

## 📁 Project Structure

```
lightwave-joelschaeffer-website/
├── src/
│   ├── app/                      # Next.js App Router pages
│   │   ├── (pages)/             # Frontend pages (portfolio, shop, etc.)
│   │   └── (payload)/           # Payload admin panel
│   ├── collections/             # Payload collections
│   │   ├── Artworks/           # Photography & cinematography works
│   │   ├── Products/           # Print shop products
│   │   ├── Categories/         # Portfolio categories
│   │   ├── Users/              # Authentication
│   │   └── ...                 # Carts, Orders, Transactions, etc.
│   ├── components/             # React components
│   ├── blocks/                 # Payload layout builder blocks
│   └── payload.config.ts       # Payload CMS configuration
├── public/                      # Static assets
└── .claude/                     # Project documentation & context
```

---

## 🎨 Portfolio Architecture

### Artworks Collection

The core of the portfolio system is the **Artworks** collection, which uses a discriminated union pattern:

```typescript
{
  type: 'photography' | 'cinematography',
  title: string,
  slug: string,
  category: Relationship<Category>,
  featured: boolean,

  // Photography-specific fields
  image?: UploadField,
  availableForPurchase?: boolean,
  relatedProduct?: Relationship<Product>,

  // Cinematography-specific fields
  videoUrl?: string,          // Vimeo or YouTube URL
  thumbnailImage?: UploadField,
  duration?: string,
  client?: string,
  role?: string,
}
```

### URL Structure

- **Cinematography Portfolio**: `/cinematography`
- **Cinematography by Category**: `/cinematography/[category-slug]`
- **Photography Portfolio**: `/photography`
- **Photography by Category**: `/photography/[category-slug]`
- **Individual Work**: `/work/[artwork-slug]`
- **Print Shop**: `/shop`
- **Product Detail**: `/products/[product-slug]`

---

## 🛠️ Development

### Running Tests

```bash
# Integration tests (Vitest)
pnpm test:int

# E2E tests (Playwright)
pnpm test:e2e

# All tests
pnpm test
```

### Database Migrations (PostgreSQL)

```bash
# Create a migration
pnpm payload migrate:create

# Run migrations
pnpm payload migrate
```

### Seed Database

Access the admin panel and click the "Seed Database" link. This will populate the database with demo content including:
- Sample artworks (photography and cinematography)
- Categories
- Products
- Demo customer account

**⚠️ WARNING**: Seeding is destructive and will replace all existing data.

---

## 🚢 Deployment

### Cloudflare Pages (Recommended)

1. **Connect GitHub repository** to Cloudflare Pages
2. **Build settings**:
   - Build command: `pnpm build`
   - Build output directory: `.next`
   - Node version: `20.x`
3. **Environment variables**: Configure all required env vars from `.env.example`
4. **Deploy**: Cloudflare will automatically build and deploy

### Vercel (Alternative)

This template supports Vercel deployment with Vercel Postgres and Vercel Blob storage adapters.

See the [Payload Vercel deployment docs](https://payloadcms.com/docs/production/deployment#vercel) for details.

---

## 📚 Documentation

Additional project documentation is available in `.claude/project-context/`:

- `00-project-overview.md` - High-level project vision and roadmap
- `01-architecture-sad.md` - System architecture decisions
- `09-implementation-plan-dual-portfolio.md` - Detailed implementation plan

---

## 🔗 Links

- **Website**: [joelschaeffer.com](https://joelschaeffer.com)
- **Built by**: [LightWave Media LLC](https://lightwave-media.ltd)
- **Payload CMS**: [payloadcms.com](https://payloadcms.com)
- **Next.js**: [nextjs.org](https://nextjs.org)

---

## 📄 License

This project is proprietary software owned by LightWave Media LLC.

Copyright © 2025 LightWave Media LLC. All rights reserved.

---

## 💬 Questions & Support

For questions or support, contact:
- **Email**: info@lightwave-media.ltd
- **GitHub Issues**: [Create an issue](https://github.com/lightwave-media/lightwave-joelschaeffer-website/issues)

---

**Built with 💙 by LightWave Media LLC**
