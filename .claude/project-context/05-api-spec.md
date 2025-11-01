# API Specification: [joelschaeffer.com](http://joelschaeffer.com) Payload CMS

**Version:** 1.0.0

**Date:** 2025-11-01

**Author:** v_product_architect

**Status:** Approved

**Related DDD:** LWM [joelschaeffer.com](http://joelschaeffer.com) - DDD: Payload CMS + Cloudflare R2 Integration - v1.0.0

---

## Overview

This document specifies the REST API for [joelschaeffer.com](http://joelschaeffer.com)'s Payload CMS instance. The API provides endpoints for managing and retrieving photography artworks, pages, and media.

**Base URL:** [`https://joelschaeffer.com/api`](https://joelschaeffer.com/api)

**Authentication:** JWT (admin endpoints), Public (read endpoints)

**Content Type:** `application/json`

---

## Authentication

### Login

**Endpoint:** `POST /api/users/login`

**Description:** Authenticate admin user and receive JWT token.

**Request Body:**

```json
{
  "email": "[admin@joelschaeffer.com](mailto:admin@joelschaeffer.com)",
  "password": "secure-password"
}
```

**Response (200 OK):**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user-id-123",
    "email": "[admin@joelschaeffer.com](mailto:admin@joelschaeffer.com)"
  },
  "exp": 1699500000
}
```

**Error Responses:**

- `401 Unauthorized`: Invalid credentials
- `400 Bad Request`: Missing email or password

---

## Artworks Collection

### List Artworks

**Endpoint:** `GET /api/artworks`

**Description:** Retrieve a paginated list of artworks.

**Query Parameters:**

- `status` (string): Filter by status (`draft`, `published`)
- `category` (string): Filter by category (`landscape`, `portrait`, `abstract`, `street`)
- `featured` (boolean): Filter featured artworks only
- `limit` (number): Results per page (default: 50, max: 100)
- `page` (number): Page number (default: 1)
- `sort` (string): Sort field (prefix with `-` for descending, e.g., `-createdAt`)

**Example Request:**

```
GET /api/artworks?status=published&category=landscape&limit=20&page=1
```

**Response (200 OK):**

```json
{
  "docs": [
    {
      "id": "artwork-123",
      "title": "Golden Hour Desert",
      "slug": "golden-hour-desert",
      "description": "<p>Captured during golden hour in Joshua Tree...</p>",
      "mainImage": {
        "id": "media-456",
        "url": "https://cdn.joelschaeffer.com/artworks/golden-hour-desert.jpg",
        "alt": "Desert landscape at golden hour",
        "width": 4000,
        "height": 2667,
        "sizes": {
          "thumbnail": {
            "url": "https://cdn.joelschaeffer.com/artworks/golden-hour-desert-thumbnail.jpg",
            "width": 400,
            "height": 300
          },
          "card": {
            "url": "https://cdn.joelschaeffer.com/artworks/golden-hour-desert-card.jpg",
            "width": 768,
            "height": 1024
          },
          "tablet": {
            "url": "https://cdn.joelschaeffer.com/artworks/golden-hour-desert-tablet.jpg",
            "width": 1024,
            "height": 683
          }
        }
      },
      "printOptions": [
        {
          "size": "8x10",
          "priceUSD": 75,
          "available": true,
          "printType": "fine-art"
        },
        {
          "size": "16x20",
          "priceUSD": 200,
          "available": true,
          "printType": "fine-art"
        },
        {
          "size": "24x36",
          "priceUSD": 400,
          "available": true,
          "printType": "canvas"
        }
      ],
      "category": "landscape",
      "featured": true,
      "status": "published",
      "seo": {
        "metaTitle": "Golden Hour Desert - Fine Art Photography Print",
        "metaDescription": "Limited edition fine art print of desert landscape captured during golden hour in Joshua Tree National Park."
      },
      "createdAt": "2025-10-15T14:30:00.000Z",
      "updatedAt": "2025-10-20T10:15:00.000Z"
    }
  ],
  "totalDocs": 45,
  "limit": 20,
  "totalPages": 3,
  "page": 1,
  "pagingCounter": 1,
  "hasPrevPage": false,
  "hasNextPage": true,
  "prevPage": null,
  "nextPage": 2
}
```

**Error Responses:**

- `400 Bad Request`: Invalid query parameters
- `500 Internal Server Error`: Database error

---

### Get Artwork by ID

**Endpoint:** `GET /api/artworks/:id`

**Description:** Retrieve a single artwork by its ID.

**Path Parameters:**

- `id` (string, required): Artwork ID

**Response (200 OK):**

```json
{
  "id": "artwork-123",
  "title": "Golden Hour Desert",
  "slug": "golden-hour-desert",
  // ... (same structure as list item)
}
```

**Error Responses:**

- `404 Not Found`: Artwork not found
- `500 Internal Server Error`: Database error

---

### Get Artwork by Slug

**Endpoint:** `GET /api/artworks/slug/:slug`

**Description:** Retrieve a single artwork by its URL slug.

**Path Parameters:**

- `slug` (string, required): Artwork slug (e.g., "golden-hour-desert")

**Response (200 OK):**

```json
{
  "id": "artwork-123",
  "title": "Golden Hour Desert",
  "slug": "golden-hour-desert",
  // ... (same structure as list item)
}
```

**Error Responses:**

- `404 Not Found`: Artwork not found
- `500 Internal Server Error`: Database error

---

### Create Artwork (Admin)

**Endpoint:** `POST /api/artworks`

**Description:** Create a new artwork entry.

**Authentication:** Required (JWT in Authorization header)

**Request Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

**Request Body:**

```json
{
  "title": "Sunset over Mountains",
  "description": "<p>Breathtaking sunset view...</p>",
  "mainImage": "media-789",
  "printOptions": [
    {
      "size": "8x10",
      "priceUSD": 80,
      "available": true,
      "printType": "fine-art"
    }
  ],
  "category": "landscape",
  "featured": false,
  "status": "draft",
  "seo": {
    "metaTitle": "Sunset over Mountains",
    "metaDescription": "Fine art landscape photography print"
  }
}
```

**Response (201 Created):**

```json
{
  "message": "Artwork created successfully",
  "doc": {
    "id": "artwork-new-123",
    "title": "Sunset over Mountains",
    "slug": "sunset-over-mountains",
    // ... (full artwork object)
  }
}
```

**Error Responses:**

- `400 Bad Request`: Validation errors (missing required fields)
- `401 Unauthorized`: Missing or invalid JWT
- `500 Internal Server Error`: Database error

---

### Update Artwork (Admin)

**Endpoint:** `PATCH /api/artworks/:id`

**Description:** Update an existing artwork.

**Authentication:** Required (JWT in Authorization header)

**Request Body:** (Partial update supported)

```json
{
  "status": "published",
  "featured": true
}
```

**Response (200 OK):**

```json
{
  "message": "Artwork updated successfully",
  "doc": {
    "id": "artwork-123",
    // ... (updated artwork object)
  }
}
```

**Error Responses:**

- `400 Bad Request`: Validation errors
- `401 Unauthorized`: Missing or invalid JWT
- `404 Not Found`: Artwork not found
- `500 Internal Server Error`: Database error

---

### Delete Artwork (Admin)

**Endpoint:** `DELETE /api/artworks/:id`

**Description:** Delete an artwork.

**Authentication:** Required (JWT in Authorization header)

**Response (200 OK):**

```json
{
  "id": "artwork-123",
  "message": "Artwork deleted successfully"
}
```

**Error Responses:**

- `401 Unauthorized`: Missing or invalid JWT
- `404 Not Found`: Artwork not found
- `500 Internal Server Error`: Database error

---

## Pages Collection

### List Pages

**Endpoint:** `GET /api/pages`

**Description:** Retrieve all pages.

**Response (200 OK):**

```json
{
  "docs": [
    {
      "id": "page-about",
      "title": "About Joel Schaeffer",
      "slug": "about",
      "content": "<p>Joel Schaeffer is a photographer based in Los Angeles...</p>",
      "seo": {
        "metaTitle": "About - Joel Schaeffer Photography",
        "metaDescription": "Learn about Joel Schaeffer, fine art photographer specializing in landscape and portrait photography."
      },
      "createdAt": "2025-10-01T12:00:00.000Z",
      "updatedAt": "2025-10-15T09:30:00.000Z"
    }
  ],
  "totalDocs": 3,
  "page": 1,
  "totalPages": 1
}
```

---

### Get Page by Slug

**Endpoint:** `GET /api/pages/slug/:slug`

**Description:** Retrieve a page by its slug.

**Path Parameters:**

- `slug` (string, required): Page slug (e.g., "about", "contact")

**Response (200 OK):**

```json
{
  "id": "page-about",
  "title": "About Joel Schaeffer",
  "slug": "about",
  "content": "<p>Joel Schaeffer is a photographer...</p>",
  "seo": {
    "metaTitle": "About - Joel Schaeffer Photography",
    "metaDescription": "Learn about Joel Schaeffer..."
  }
}
```

**Error Responses:**

- `404 Not Found`: Page not found

---

## Media Collection

### Upload Media (Admin)

**Endpoint:** `POST /api/media`

**Description:** Upload an image file.

**Authentication:** Required (JWT in Authorization header)

**Content-Type:** `multipart/form-data`

**Request Body:**

```
--boundary
Content-Disposition: form-data; name="file"; filename="sunset.jpg"
Content-Type: image/jpeg

[binary image data]
--boundary
Content-Disposition: form-data; name="alt"

Beautiful sunset over mountains
--boundary--
```

**Response (201 Created):**

```json
{
  "message": "Uploaded successfully",
  "doc": {
    "id": "media-new-456",
    "filename": "sunset-1699500000.jpg",
    "url": "https://cdn.joelschaeffer.com/media/sunset-1699500000.jpg",
    "alt": "Beautiful sunset over mountains",
    "mimeType": "image/jpeg",
    "filesize": 2458936,
    "width": 4000,
    "height": 2667,
    "sizes": {
      "thumbnail": {
        "url": "https://cdn.joelschaeffer.com/media/sunset-1699500000-thumbnail.jpg",
        "width": 400,
        "height": 300,
        "filesize": 45678
      },
      "card": {
        "url": "https://cdn.joelschaeffer.com/media/sunset-1699500000-card.jpg",
        "width": 768,
        "height": 1024,
        "filesize": 156890
      },
      "tablet": {
        "url": "https://cdn.joelschaeffer.com/media/sunset-1699500000-tablet.jpg",
        "width": 1024,
        "height": 683,
        "filesize": 234567
      }
    },
    "createdAt": "2025-11-01T18:00:00.000Z",
    "updatedAt": "2025-11-01T18:00:00.000Z"
  }
}
```

**Error Responses:**

- `400 Bad Request`: Invalid file type or size exceeds limit
- `401 Unauthorized`: Missing or invalid JWT
- `413 Payload Too Large`: File exceeds 20MB limit
- `500 Internal Server Error`: Upload failed

---

### List Media (Admin)

**Endpoint:** `GET /api/media`

**Description:** Retrieve all media files.

**Authentication:** Required (JWT in Authorization header)

**Query Parameters:**

- `limit` (number): Results per page (default: 50)
- `page` (number): Page number (default: 1)

**Response (200 OK):**

```json
{
  "docs": [
    {
      "id": "media-456",
      "filename": "sunset.jpg",
      "url": "https://cdn.joelschaeffer.com/media/sunset.jpg",
      "alt": "Beautiful sunset",
      "width": 4000,
      "height": 2667,
      "sizes": { /* ... */ }
    }
  ],
  "totalDocs": 87,
  "page": 1,
  "totalPages": 2
}
```

---

## Error Responses

All error responses follow this format:

```json
{
  "errors": [
    {
      "message": "Validation failed",
      "field": "title",
      "value": null
    }
  ]
}
```

**Common HTTP Status Codes:**

- `200 OK`: Request succeeded
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request parameters or body
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Authenticated but not authorized
- `404 Not Found`: Resource not found
- `413 Payload Too Large`: File upload exceeds size limit
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error

---

## Rate Limiting

**Default Limits (Payload):**

- Unauthenticated: 60 requests per minute per IP
- Authenticated: 300 requests per minute per user

**Headers:**

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1699500060
```

**Rate Limit Exceeded Response:**

```json
{
  "errors": [
    {
      "message": "Too many requests, please try again later."
    }
  ]
}
```

---

## CORS Policy

**Allowed Origins:**

- [`https://joelschaeffer.com`](https://joelschaeffer.com)
- [`https://*.pages.dev`](https://*.pages.dev) (Cloudflare Pages preview deployments)

**Allowed Methods:**

- `GET`, `POST`, `PATCH`, `DELETE`, `OPTIONS`

**Allowed Headers:**

- `Authorization`, `Content-Type`, `Accept`

**Credentials:** Allowed (for JWT cookies)

---

## Webhook Events (Future)

**Payload webhooks can trigger on:**

- `artworks.create`
- `artworks.update`
- `artworks.delete`
- `media.create`
- `media.delete`

**Webhook Payload Example:**

```json
{
  "collection": "artworks",
  "operation": "update",
  "doc": {
    "id": "artwork-123",
    // ... (full artwork object)
  },
  "previousDoc": {
    // ... (artwork before update)
  }
}
```

---

**Related Documents:**

- DDD: LWM [joelschaeffer.com](http://joelschaeffer.com) - DDD: Payload CMS + Cloudflare R2 Integration - v1.0.0
- SAD: LWM [joelschaeffer.com](http://joelschaeffer.com) - SAD - v1.0.0
- User Story: US-JS-002: Payload CMS + Cloudflare R2 Integration