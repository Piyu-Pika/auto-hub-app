# AutoHub Express — Mobile API Specification

**Audience:** Backend team
**Source:** Derived from the shipped Flutter UI (all screens, forms and filters are built)
**Base URL:** `https://api.autohub.express`
**Version prefix:** `/v1`

---

## 1. General

### 1.1 Authentication

JWT bearer tokens.

| Header | Value |
|---|---|
| `Authorization` | `Bearer <accessToken>` |

Access tokens are short-lived (~60 min). A refresh token is issued at login and rotated on every refresh.

Only these endpoints are public (no `Authorization` required):
`/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/refresh`, `/auth/social`

Everything else requires a valid token and returns **401** when missing, expired or invalid.

### 1.2 Request headers

Sent on every request:

| Header | Example | Required |
|---|---|---|
| `Accept` | `application/json` | Yes |
| `Content-Type` | `application/json` | Yes, except `multipart/form-data` |
| `Authorization` | `Bearer eyJhbGci…` | Yes, except public endpoints |
| `X-Request-Id` | `9f1c2e40-7a3b-4c1e-9d55-0f2a1b3c4d5e` | Yes |
| `X-App-Platform` | `ios` \| `android` | Yes |
| `X-App-Version` | `1.0.0+1` | Yes |
| `X-Device-Id` | `a3f19c2b8e7d4650a1c4f2b9d8e7c605` | Yes |
| `X-Locale` | `en-us` | Yes |
| `X-Timezone` | `America/New_York` | Recommended |

Return `X-Request-Id` in every response so the client can correlate failures.

Rate-limit headers to return: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.

### 1.3 Response envelope

**Success**
```json
{
  "success": true,
  "data": { },
  "meta": { "page": 1, "limit": 20, "total": 348, "requestId": "9f1c2e40-…" },
  "requestId": "9f1c2e40-…"
}
```

**Error**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Password must be at least 8 characters.",
    "details": { "field": "password" }
  },
  "requestId": "9f1c2e40-…"
}
```

Rules:
- `error.message` must be safe to display verbatim in the UI.
- Return **HTTP 4xx/5xx** alongside `success: false`. Never return `200` with `success: false`.
- `data` is omitted on errors. `meta` only appears on list endpoints.

### 1.4 Error catalogue

| HTTP | `error.code` | When |
|---|---|---|
| 400 | `BAD_REQUEST` | Malformed request |
| 401 | `UNAUTHORIZED` | Missing/expired/invalid token |
| 401 | `INVALID_CREDENTIALS` | Wrong email or password |
| 403 | `FORBIDDEN` | Authenticated but not permitted |
| 404 | `NOT_FOUND` | Resource does not exist |
| 409 | `CONFLICT` | State conflict (e.g. cancelling a shipped order) |
| 422 | `VALIDATION_ERROR` | Field-level validation failed |
| 429 | `RATE_LIMITED` | Too many requests |
| 500 | `INTERNAL_ERROR` | Unexpected server error |
| 503 | `SERVICE_UNAVAILABLE` | Maintenance / degraded |

### 1.5 Conventions

- **Pagination:** `?page=1&limit=20`, returned in `meta`. `limit` max 100.
- **Dates:** ISO 8601 UTC, e.g. `2026-04-01T14:30:00Z`.
- **Money:** decimal number in USD, e.g. `185.00`. Never a formatted string.
- **IDs:** opaque prefixed strings — `usr_1`, `prt_8`, `ord_1042`, `adr_1`, `pm_1`, `jnk_0412`, `tkt_7`.
- **Multi-value filters:** repeated query keys, e.g. `?make=Honda&make=Ford`.
- **Empty list:** `[]`, never `null`.

---

## 2. Canonical data models

### User
```json
{
  "id": "usr_1",
  "fullName": "Mike Johnson",
  "email": "mike@x.com",
  "phone": "+1 609 758 1919",
  "location": "Houston, TX",
  "avatarUrl": "https://…/avatar.jpg",
  "memberSince": "Mar 2024",
  "accountType": "buyer",
  "initials": "MJ",
  "isVerified": true
}
```

### Part (list item)
```json
{
  "id": "prt_8",
  "title": "OEM Alternator",
  "price": 185.00,
  "condition": "Excellent",
  "rating": 4.8,
  "ratingCount": 94,
  "make": "Honda",
  "model": "Civic",
  "yearRange": "2016-2021",
  "category": "Electrical",
  "warranty": "90 Days",
  "location": "Houston, TX",
  "imagePath": "https://…/alternator.jpg",
  "tag": "Featured",
  "isFavorite": false
}
```

`condition` ∈ `Excellent | Good | Fair | For Parts`.

### Order
```json
{
  "id": "ord_1042",
  "orderNumber": "AH-1042",
  "title": "OEM Alternator",
  "price": 185.00,
  "status": "inTransit",
  "trackingNumber": "1Z999AA10123456784",
  "address": "4521 Westheimer Rd, Houston, TX 77027",
  "placedAt": "2026-03-28T14:12:00Z",
  "estimatedDelivery": "2026-04-02T00:00:00Z",
  "items": [ { "partId": "prt_8", "title": "OEM Alternator", "quantity": 1, "unitPrice": 185.00 } ],
  "timeline": [
    { "title": "Order Placed", "time": "Mar 28, 2:12 PM", "isCompleted": true },
    { "title": "Shipped",    "time": "Mar 29, 9:03 AM", "isCompleted": true },
    { "title": "Delivered",  "time": null,             "isCompleted": false }
  ]
}
```

`status` ∈ `processing | inTransit | delivered | cancelled`.

### Address
```json
{
  "id": "adr_1", "type": "home", "label": "Home",
  "streetAddress": "4521 Westheimer Rd", "city": "Houston",
  "state": "TX", "zip": "77027", "isDefault": true
}
```

### Payment card
```json
{ "id": "pm_1", "cardHolder": "Mike Johnson", "last4": "4291", "expiry": "09/28", "brand": "Visa", "isDefault": true }
```

### Junk request
```json
{
  "id": "jnk_0412", "status": "offerPending", "vehicleTitle": "2010 Honda Civic",
  "date": "Apr 1, 2026", "vin": "2HGFC2F59NH504321",
  "condition": "Running – Good condition", "notes": "",
  "offerAmount": 450, "pickupDateTime": null, "towCompany": null,
  "salvageYardName": "Houston Auto Recyclers", "salvageYardPhone": "(832) 555-0142"
}
```

`status` ∈ `pickupScheduled | offerPending | completed | cancelled`.

### Chat
```json
// ChatRoom
{ "chatRoomId": "1", "name": "AutoHub Support", "lastMessage": "Your pickup is confirmed.",
  "timestamp": "2026-04-01T14:30:00Z", "initials": "AS", "avatarUrl": "https://…",
  "isOnline": true, "unreadCount": 1, "participantType": "support" }

// ChatMessage
{ "id": "msg_1", "chatRoomId": "1", "senderId": "usr_1", "text": "Hello",
  "sentAt": "2026-04-01T14:30:00Z", "isSender": true, "status": "sent", "attachmentUrl": null }
```

`participantType` ∈ `support | seller | tow`. `status` ∈ `sending | sent | delivered | read`.

---

## 3. Endpoints

### 3.1 Auth

#### `POST /auth/register`
**Auth:** none · **Purpose:** create account

Request
```json
{ "fullName": "Mike Johnson", "email": "mike@x.com", "password": "P@ssw0rd!",
  "deviceId": "a3f1…", "platform": "android" }
```
Response `201`
```json
{ "success": true, "data": {
  "accessToken": "eyJ…", "refreshToken": "rft_…", "expiresIn": 3600,
  "user": { "id": "usr_1", "fullName": "Mike Johnson", "email": "mike@x.com", "…": "…" } } }
```
Errors: `422` weak password, `409` email already registered.

#### `POST /auth/login`
**Auth:** none

Request
```json
{ "email": "mike@x.com", "password": "P@ssw0rd!", "deviceId": "a3f1…" }
```
Response — identical envelope to `/auth/register`.
Errors: `401 INVALID_CREDENTIALS`.

#### `POST /auth/forgot-password`
**Auth:** none

Request `{ "email": "mike@x.com" }` → Response `{ "success": true, "data": { "message": "Reset link sent" } }`
Always return `200` whether or not the email exists (no account enumeration).

#### `POST /auth/refresh`
**Auth:** none · **Purpose:** called by the app automatically on a 401

Request `{ "refreshToken": "rft_…" }` → Response
`{ "accessToken": "eyJ…", "refreshToken": "rft_new…", "expiresIn": 3600 }`
The old refresh token must be invalidated. Return `401` if it was already used.

#### `POST /auth/logout`
Request `{ "refreshToken": "rft_…" }` → Response `{ "success": true, "data": {} }`

#### `POST /auth/social`
**Auth:** none

Request
```json
{ "provider": "google", "idToken": "eyJ…", "deviceId": "a3f1…" }
```
`provider` ∈ `google | facebook`. Response identical to `/auth/login` — create the account on first login.

#### `GET /auth/session`
**Auth:** bearer · **Purpose:** app launch, decides Home vs. Login

Response
```json
{ "success": true, "data": { "authenticated": true, "user": { "id": "usr_1", "…": "…" } } }
```

---

### 3.2 Account

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/users/me` | ✔ | Load profile |
| `PATCH` | `/users/me` | ✔ | Update profile |
| `POST` | `/users/me/avatar` | ✔ | Upload profile photo |
| `POST` | `/users/me/password` | ✔ | Change password |
| `POST` | `/users/me/deletion-request` | ✔ | Request account deletion |
| `DELETE` | `/users/me/search-history` | ✔ | Clear search history |

**`PATCH /users/me`** — send only changed fields
```json
{ "fullName": "Mike Johnson", "phone": "+1 609 758 1919", "location": "Houston, TX" }
```
→ Returns the full User object.

**`POST /users/me/avatar`** — `multipart/form-data`, field `file`, ≤ 5 MB, jpg/png
→ `{ "avatarUrl": "https://…/avatar.jpg" }`

**`POST /users/me/password`**
```json
{ "currentPassword": "…", "newPassword": "…" }
```
→ `{ "message": "Password updated" }`. Invalidate all refresh tokens on success.

**`POST /users/me/deletion-request`**
```json
{ "reason": "user_request", "confirmationText": "DELETE" }
```
→ `{ "requestId": "del_1", "status": "scheduled", "gracePeriodDays": 30 }`

---

### 3.3 Addresses

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/addresses` | ✔ | List (default first) |
| `POST` | `/addresses` | ✔ | Create |
| `PATCH` | `/addresses/{id}` | ✔ | Update |
| `DELETE` | `/addresses/{id}` | ✔ | Delete |
| `POST` | `/addresses/{id}/default` | ✔ | Set default |

**Create / update body**
```json
{ "type": "home", "label": "Home", "streetAddress": "4521 Westheimer Rd",
  "city": "Houston", "state": "TX", "zip": "77027", "isDefault": false }
```
`type` ∈ `home | work | other`. Setting one default must unset the others.
`GET` returns `[]` when the user has none.

---

### 3.4 Payment methods

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/payment-methods` | ✔ | List saved cards |
| `POST` | `/payment-methods` | ✔ | Add card |
| `DELETE` | `/payment-methods/{id}` | ✔ | Remove card |
| `POST` | `/payment-methods/{id}/default` | ✔ | Set default |

**`POST /payment-methods`**
```json
{ "cardHolder": "Mike Johnson", "cardNumber": "4242424242424242",
  "expiry": "09/28", "cvc": "123", "makeDefault": false }
```
→ Returns the stored PaymentCard (`last4` only — never echo the PAN or CVC).

> **Decision required:** confirm whether you want the raw PAN or a gateway token (e.g. Stripe SetupIntent). If Stripe, the client will send `paymentMethodId` instead and you must return the card `brand`.

---

### 3.5 Parts catalog

#### `GET /parts`
**Auth:** optional — when present, personalise `isFavorite`

Query parameters
| Param | Type | Notes |
|---|---|---|
| `q` | string | Free-text over title, make, model, category |
| `make` | string, repeatable | e.g. `make=Honda&make=Ford` |
| `category` | string, repeatable | |
| `condition` | string, repeatable | `Excellent \| Good \| Fair \| For Parts` |
| `maxPrice` | number | |
| `minPrice` | number | |
| `vin` | string | 17 chars — returns only parts that fit |
| `sort` | enum | `newest \| price_asc \| price_desc \| top_rated` |
| `page` | int | default 1 |
| `limit` | int | default 20 |

Response → `data` is an array of Part, `meta` carries `page` / `limit` / `total`.
`total` also drives the "N parts listed" counter on the browse header, so it must reflect the **unfiltered** catalogue size when no filters are applied.

#### `GET /parts/filter-options`
Populates the filter sheet and the results-count preview.
```json
{ "success": true, "data": {
  "makes": ["BMW", "Chevrolet", "Ford", "Honda", "Kia", "Nissan", "Subaru", "Toyota"],
  "categories": ["Body", "Cooling", "Electrical", "Engine", "Interior", "Suspension", "Transmission"],
  "conditions": ["Excellent", "Good", "Fair", "For Parts"],
  "priceRange": { "min": 0, "max": 2000 } } }
```

#### `GET /parts/fitments`
Query: `?vin=<17>&page=1&limit=20` → array of Part, same envelope as `/parts`.

#### `GET /parts/{id}`
Full detail for the product page.
```json
{ "success": true, "data": {
  "id": "prt_8", "title": "OEM Alternator", "subtitle": "Alternator",
  "description": "OEM alternator pulled from a 2019 Honda Civic with only 48K miles…",
  "price": 185.00, "condition": "Excellent", "tag": "Featured",
  "imageUrl": "https://…/engine.jpg", "rating": 4.8, "ratingCount": 94,
  "warranty": "90 Days", "isFavorite": false, "location": "Houston, TX",
  "partNumber": "ALT-8912-HON",
  "specifications": { "category": "Electrical", "compatibleMake": "Honda",
    "compatibleModel": "Civic", "yearRange": "2016-2021",
    "donorMileage": "48,000 mi", "weight": "4.2 kg" },
  "fitment": { "label": "Fits: Honda Civic",
    "detail": "Model years 2016-2021 · Donor mileage: 48,000 mi" },
  "yard": { "yardId": "yrd_12", "name": "Houston Auto Recyclers", "rating": 4.8,
    "ratingCount": 94, "address": "Houston, TX", "phone": "(832) 555-0142",
    "businessHours": "Mon-Sat 8AM-6PM", "pickupAvailable": true,
    "deliveryNationwide": true, "isVerified": true } } }
```

#### `GET /parts/{id}/similar`
Returns an array of Part — same shape as `/parts`.

#### `POST /parts/{id}/favorite`
Request `{}` — the server toggles.
Response `{ "partId": "prt_8", "isFavorite": true }`

---

### 3.6 Saved / wishlist

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/saved-parts` | ✔ | Wishlist contents |
| `DELETE` | `/saved-parts/{partId}` | ✔ | Remove from wishlist |

`GET` supports `?page` / `?limit` and returns an array of Part.

---

### 3.7 Home feed

#### `GET /home/feed`
**Purpose:** one call populates the entire home screen. Optional query: `?lat=&lng=` for locality-aware content.

```json
{ "success": true, "data": {
  "hero": { "id": "bnr_1", "title": "Summer sale", "subtitle": "Up to 40% off",
            "imageUrl": "https://…", "ctaLabel": "Shop now",
            "ctaUrl": "autohub://browse?category=body" },
  "stats": [ { "label": "Parts listed", "value": "48K" },
             { "label": "Verified yards", "value": "312" },
             { "label": "Avg. delivery", "value": "3.2 days" } ],
  "categories": [ { "id": "cat_1", "name": "Body", "iconUrl": "https://…", "partCount": 8420 } ],
  "featured": [ /* Part */ ],
  "recent":   [ /* Part */ ],
  "junkBanner": { "title": "Junk your car", "subtitle": "Free towing + cash offer",
                  "imageUrl": "https://…", "ctaUrl": "autohub://new-junk-request" },
  "trustStrip": { "items": [ { "icon": "verified", "label": "Verified sellers" },
                             { "icon": "shield",   "label": "Warranty protected" } ] } } }
```

Fallback granular endpoints, if you prefer to split it:

| Method | Path | Returns |
|---|---|---|
| `GET` | `/home/hero-banner` | `hero` |
| `GET` | `/home/stats` | `stats` |
| `GET` | `/categories` | `categories` |
| `GET` | `/home/junk-banner` | `junkBanner` |
| `GET` | `/home/trust-strip` | `trustStrip` |

`featured` = `GET /parts?featured=true&limit=10`; `recent` = `GET /parts?sort=newest&limit=10`.

---

### 8 / 3.8 VIN

The app currently decodes VINs directly against the public NHTSA vPIC service and needs no endpoint:

```
GET https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvalues/{VIN}?format=json
```

**Optional additions:**

#### `POST /vin/decode`
```json
{ "vin": "1HGCM82633A004352" }
```
→ Same field set vPIC returns (`Make`, `Model`, `ModelYear`, `Trim`, `BodyClass`, `Doors`, `DriveType`, `EngineHP`, `EngineCylinders`, `DisplacementL`, `FuelTypePrimary`, `TransmissionStyle`, `ManufacturerName`, `PlantCountry`). Useful for caching lookups and analytics. The client will keep vPIC as a fallback.

#### `POST /users/me/vehicles`
Saves a decoded vehicle to the user's garage for one-tap "find parts that fit".
Request `{ "vin": "…", "label": "My Civic" }` → returns the saved vehicle.

---

### 3.9 Cart & checkout

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/cart` | ✔ | Current cart |
| `POST` | `/cart/items` | ✔ | Add a part |
| `PATCH` | `/cart/items/{cartItemId}` | ✔ | Change quantity |
| `DELETE` | `/cart/items/{cartItemId}` | ✔ | Remove a line |
| `POST` | `/checkout/orders` | ✔ | Place the order |

**Cart response**
```json
{ "success": true, "data": {
  "cartId": "crt_9",
  "items": [ { "cartItemId": "ci_1", "part": { /* Part */ }, "quantity": 1, "unitPrice": 185.00 } ],
  "subtotal": 185.00, "shipping": 0.00, "tax": 13.70, "total": 198.70,
  "freeShippingThreshold": 100.00, "qualifiesForFreeShipping": true } }
```

**`POST /cart/items`** → `{ "partId": "prt_8", "quantity": 1 }` → returns the updated cart.
**`PATCH`** → `{ "quantity": 2 }`
**`POST /checkout/orders`**
```json
{ "addressId": "adr_1", "paymentMethodId": "pm_1", "shippingMethod": "standard", "couponCode": null }
```
→ `{ "orderId": "ord_1043", "orderNumber": "AH-1043", "total": 198.70 }`
`409 CONFLICT` if the part sold out between add and checkout.

---

### 3.10 Orders

#### `GET /orders`
Query: `?status=all|active|completed|cancelled&page=1&limit=20`
`active` expands to `processing` + `inTransit`.
Response → array of Order, `meta.total` for pagination.

#### `GET /orders/{id}`
Returns one Order. `404` when it belongs to another user.

#### `POST /orders/{id}/cancel`
```json
{ "reason": "no_longer_needed", "note": "Found a local one" }
```
→ Returns the updated Order with a `Cancelled` timeline entry appended.
`409 CONFLICT` if the order has already shipped.

#### `GET /orders/{id}/tracking`
```json
{ "success": true, "data": {
  "carrier": "UPS", "trackingNumber": "1Z999AA10123456784",
  "trackingUrl": "https://…", "estimatedDelivery": "2026-04-02T00:00:00Z",
  "events": [ { "status": "in_transit", "description": "Departed Houston, TX",
                "occurredAt": "2026-03-30T04:20:00Z" } ] } }
```
`status` ∈ `label_created | picked_up | in_transit | out_for_delivery | delivered`.

#### `POST /orders/{id}/reorder`
Request `{ "items": [ { "partId": "prt_8", "quantity": 1 } ] }`
→ `{ "cartId": "crt_9", "itemCount": 1 }` — populates the cart for a one-tap rebuy.

#### `POST /orders/{id}/rate`
```json
{ "rating": 5, "comment": "Great part, fast shipping" }
```
`rating` 1–5. → `{ "reviewId": "rev_3" }`

#### `POST /orders/{id}/return`
```json
{ "reason": "wrong_part", "note": "", "images": ["https://…"] }
```
→ `{ "returnId": "ret_2", "labelUrl": "https://…", "status": "label_issued" }`
Returnable only while `status = delivered`.

---

### 3.11 Junk requests

#### `POST /junk-requests/quote`
**Purpose:** live cash offer, shown to the user *before* they submit.
```json
{ "year": "2010", "make": "Honda", "model": "Civic", "vin": "",
  "condition": "Running – Good condition", "hasTitle": true, "hasKeys": true }
```
```json
{ "success": true, "data": {
  "estimatedOffer": 450, "currency": "USD", "validUntil": "2026-04-02T00:00:00Z",
  "breakdown": [ { "label": "Vehicle base value", "amount": 500 },
                 { "label": "Deduction – repairs", "amount": -50 } ] } }
```

`condition` — the exact strings the app sends:
`Running – Good condition` · `Running – Needs repairs` · `Non-running – Fixable` · `Non-running – Totaled/Scrap`
*(note the en-dashes — send them back unchanged)*

#### `POST /junk-requests`
```json
{ "year": "2010", "make": "Honda", "model": "Civic", "vin": "2HGFC2F59NH504321",
  "condition": "Running – Good condition", "hasTitle": true, "hasKeys": true,
  "pickupAddress": "4521 Westheimer Rd, Houston, TX 77027",
  "notes": "Car is in the driveway, keys under the mat",
  "imageUrls": ["https://…"] }
```
Response `201` → the created JunkRequest with a generated `id` (e.g. `jnk_0412`).

#### `POST /uploads/vehicle-images`
`multipart/form-data`, field `files[]`, up to 8 images, ≤ 10 MB each, jpg/png/heic.
→ `{ "urls": ["https://…"] }`

#### Remaining operations

| Method | Path | Request | Response |
|---|---|---|---|
| `GET` | `/junk-requests?status=all&page=1` | — | array of JunkRequest |
| `GET` | `/junk-requests/{id}` | — | JunkRequest |
| `POST` | `/junk-requests/{id}/cancel` | `{ "reason": "changed_mind" }` | JunkRequest |
| `POST` | `/junk-requests/{id}/accept-offer` | `{ "offerAmount": 450 }` | JunkRequest |
| `POST` | `/junk-requests/{id}/pickup-schedule` | `{ "scheduledAt": "2026-04-03T09:00:00Z", "notes": "" }` | JunkRequest |

---

### 3.12 Messaging

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/chats/rooms?type=all&page=1` | ✔ | Conversation list |
| `GET` | `/chats/rooms/{roomId}` | ✔ | Room header |
| `GET` | `/chats/rooms/{roomId}/messages?before=&limit=30` | ✔ | Message history (newest first) |
| `POST` | `/chats/rooms/{roomId}/messages` | ✔ | Send a message |
| `POST` | `/chats/rooms/{roomId}/read` | ✔ | Mark as read |
| `DELETE` | `/chats/rooms/{roomId}/messages` | ✔ | Clear chat |
| `DELETE` | `/chats/rooms/{roomId}` | ✔ | Delete conversation |
| `GET` | `/chats/unread-count` | ✔ | Badge counts |
| `POST` | `/chats/rooms/{roomId}/attachments` | ✔ | Upload image |

**`POST /chats/rooms/{roomId}/messages`**
```json
{ "text": "xaxx", "attachmentUrl": null }
```
→ `{ "id": "msg_9", "sentAt": "2026-04-01T14:30:00Z", "status": "sent" }`

**`GET /chats/unread-count`** → `{ "total": 3, "byRoom": { "1": 1, "2": 2 } }`

**Realtime** — `wss://api.autohub.express/ws?token=<accessToken>`
Server events: `message.new`, `message.read`, `room.updated`, `typing`.
If a socket is not available the client falls back to polling `/chats/unread-count` every 15 s.

---

### 3.13 Help center & support

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/help/categories` | optional | Category chips |
| `GET` | `/help/articles?category=&q=&page=1` | optional | Search + list |
| `GET` | `/help/articles/{id}` | optional | Single article |
| `POST` | `/support/tickets` | ✔ | Submit a ticket |
| `GET` | `/support/tickets?page=1` | ✔ | Recent tickets |
| `GET` | `/support/tickets/{id}` | ✔ | Ticket + replies |
| `POST` | `/support/callback-request` | ✔ | Request a phone call-back |

**HelpArticle**
```json
{ "id": "1", "title": "How do I junk my car?", "content": "…",
  "category": "Junking", "updatedAt": "2026-03-01T00:00:00Z" }
```

**`POST /support/tickets`**
```json
{ "category": "Order Issue", "subject": "…", "description": "…",
  "orderId": null, "attachments": [] }
```
→ `{ "ticketId": "tkt_7", "status": "open", "createdAt": "…", "slaHours": 24 }`

`category` must be one of the six the app offers:
`General` · `Order Issue` · `Part Question` · `Junk Request` · `Payment` · `Bug Report`

**`POST /support/callback-request`**
```json
{ "phone": "+16097581919", "preferredTime": "10:00-12:00" }
```
→ `{ "requestId": "cb_4", "scheduledFor": "2026-04-02T10:00:00Z" }`

---

### 3.14 Settings

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/settings` | ✔ | Load preferences |
| `PATCH` | `/settings` | ✔ | Update preferences |
| `GET` | `/settings/languages` | optional | Language list |

**Settings object**
```json
{ "pushNotifications": true, "emailNotifications": true, "priceDropAlerts": false,
  "orderUpdates": true, "chatMessages": true, "notificationSounds": true,
  "vibration": true, "darkMode": true, "autoDistanceUnit": true,
  "selectedLanguage": "English", "selectedLanguageFlag": "🇺🇸" }
```

**`PATCH /settings`** — send only the changed keys, return the full object.

**`GET /settings/languages`**
```json
{ "success": true, "data": [ { "code": "en", "name": "English", "flag": "🇺🇸" },
                             { "code": "es", "name": "Español", "flag": "🇲🇽" } ] }
```

*Note: "Clear Cache" is device-local and needs no endpoint.*

---

### 3.15 Meta / analytics (optional)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `POST` | `/analytics/events` | ✔ | Batched screen views, searches, taps. Must never block the UI |
| `POST` | `/referrals/track` | none | Partner referral click-through |
| `GET` | `/app/config` | optional | Feature flags, min app version |

**`POST /referrals/track`**
```json
{ "partner": "hitech", "utmSource": "autohub_mobile_app",
  "utmMedium": "flutter_widget", "utmCampaign": "partner_referral" }
```

---

## 4. Summary — 58 endpoints

| # | Group | Endpoints | Auth |
|---|---|---|---|
| 1 | Auth | 7 | mixed |
| 2 | Account | 6 | ✔ |
| 3 | Addresses | 5 | ✔ |
| 4 | Payment methods | 4 | ✔ |
| 5 | Parts catalog | 6 | mixed |
| 6 | Saved parts | 2 | ✔ |
| 7 | Home feed | 2 (+5 fallback) | mixed |
| 8 | VIN | 1 (+1 optional) | mixed |
| 9 | Cart & checkout | 5 | ✔ |
| 10 | Orders | 7 | ✔ |
| 11 | Junk requests | 8 | ✔ |
| 12 | Messaging | 9 + 1 websocket | ✔ |
| 13 | Help & support | 7 | mixed |
| 14 | Settings | 3 | mixed |
| 15 | Meta | 3 | mixed |

---

## 5. Suggested delivery order

| Phase | Scope | Rationale |
|---|---|---|
| **P0** | Auth (7), Account (6), Parts (6), Home feed (2) | Blocks login, the home screen and all browsing |
| **P1** | Orders (7), Addresses (5), Cart & checkout (5) | Purchase path |
| **P2** | Junk requests (8) + uploads | Separate revenue stream |
| **P3** | Messaging (9 + ws), Saved (2) | Engagement |
| **P4** | Help & support (7), Settings (3), Payment methods (4), Meta (3) | Completeness |

---

## 6. Decisions needed from the backend team

1. **Auth** — confirm JWT access + rotating refresh, and whether social login accepts a provider `idToken`.
2. **Envelope** — is `{ success, data, meta }` acceptable as the standard shape?
3. **Payments** — raw PAN or a gateway token (Stripe SetupIntent)? This decides whether the app needs a payment SDK.
4. **Chat** — is the WebSocket endpoint available, or should we poll?
5. **Home** — one aggregated `/home/feed`, or separate endpoints per section?
6. **Junk quote** — can the offer be previewed before the user submits the request?
7. **Pickup address** — free text, or must the user pick a saved address from `/addresses`?
8. **VIN** — keep calling NHTSA vPIC from the device, or proxy through you?
9. **Pagination** — is cursor-based pagination preferred over page/limit for large collections?