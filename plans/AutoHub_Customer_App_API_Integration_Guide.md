# AutoHub Customer App API — Integration Guide

2026-11-16 · Ansh Goyal

The Flutter app talks to the customer API under `/v1` on the AutoHub backend. It is separate from the admin CRM `/api` routes. Every endpoint below was run against a real server on 2026-11-16 (145 calls, all returned the documented status); the examples are real responses with IDs and long strings shortened.

## Getting started

### Base URL

All paths in this guide are relative to `<host>/v1`. The host depends on the environment the backend team points you at, for example `https://api.autohubexpress.us/v1` (Lightsail). Use HTTPS in every environment except local development (`http://localhost:5000/v1`).

### Headers sent on every request

| Header | Example | Required |
| --- | --- | --- |
| `Accept` | `application/json` | Yes |
| `Content-Type` | `application/json` (not set for file uploads, which use `multipart/form-data`) | Yes for JSON bodies |
| `Authorization` | `Bearer eyJhbGci…` | Yes, except on public endpoints |
| `X-Request-Id` | `9f1c2e40-7a3b-4c1e-9d55-0f2a1b3c4d5e` | Recommended; the server creates one if missing |
| `X-App-Platform` | `ios` or `android` | Recommended |
| `X-App-Version` | `1.0.0+1` | Recommended; used by `GET /app/config` |
| `X-Device-Id` | `a3f19c2b8e7d4650a1c4f2b9d8e7c605` | Recommended |
| `X-Locale` | `en-us` | Recommended |
| `X-Timezone` | `America/New_York` | Recommended; order timeline times are formatted in this zone (UTC if missing) |

A missing recommended header never blocks a request.

### Headers returned on every response

| Header | Meaning |
| --- | --- |
| `X-Request-Id` | Your request id (or the one the server made). Log it with any error. |
| `X-RateLimit-Limit` | Requests allowed per window (120 per minute per signed-in customer, or per IP when signed out) |
| `X-RateLimit-Remaining` | Requests left in the current window |
| `X-RateLimit-Reset` | When the window resets, as Unix seconds |
| `Retry-After` | Only on 429: seconds to wait |

Sign-in endpoints (register, login, forgot/reset password, social) have a stricter limit of 20 calls per 15 minutes per IP.

### Response format

Every response is JSON in one of two shapes. Read `success` first.

```json
{
  "success": true,
  "data": { },
  "meta": { "page": 1, "limit": 20, "total": 348, "requestId": "9f1c2e40-…" },
  "requestId": "9f1c2e40-…"
}
```

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

- `meta` appears only on list endpoints.
- `data` is never present on errors.
- `error.message` is written for customers and can be shown in the UI as is.
- `error.details.field` names the input to highlight on a 422.
- A failed request never comes back as HTTP 200.

### Status codes and error codes

| HTTP | `error.code` | When it happens | What the app should do |
| --- | --- | --- | --- |
| 200 | — | Read or update succeeded | Use `data` |
| 201 | — | Something was created (account, address, order, message…) | Use `data` |
| 202 | — | Analytics events accepted | Nothing |
| 400 | `BAD_REQUEST` | Body is not valid JSON, or is too large | Fix the request |
| 401 | `UNAUTHORIZED` | Token missing, expired or invalid; password changed; refresh token reused | Call `POST /auth/refresh` once; if that fails, send the user to Login |
| 401 | `INVALID_CREDENTIALS` | Wrong email or password | Show the message on the login form |
| 403 | `FORBIDDEN` | Account suspended | Show the message, sign out |
| 404 | `NOT_FOUND` | The item doesn't exist, belongs to another customer, or the route doesn't exist | Show "not found", go back |
| 409 | `CONFLICT` | State conflict: email taken, part sold out, order already shipped, offer changed… | Show the message and refresh the screen |
| 422 | `VALIDATION_ERROR` | An input failed a rule; `details.field` names it | Highlight that field |
| 429 | `RATE_LIMITED` | Too many requests | Wait `Retry-After` seconds |
| 500 | `INTERNAL_ERROR` | Unexpected server error | Generic error; report the `requestId` |
| 503 | `SERVICE_UNAVAILABLE` | A dependency is down (VIN service) or a feature isn't configured (social login) | Retry later or hide the feature |

### Conventions

- **IDs** are opaque strings with a prefix: `usr_`, `prt_` (part), `ord_`, `adr_`, `pm_`, `ci_` (cart item), `crt_`, `jnk_`, `msg_`, `tkt_`, `veh_`, `rev_`, `ret_`, `del_`, `cb_`, `ref_`. Send them back exactly as received. Chat room ids and help article ids have no prefix.
- **Dates** are ISO 8601 in UTC, for example `2026-04-01T14:30:00.000Z`. A few display strings are pre-formatted (order timeline `"Nov 16, 1:38 AM"`, junk request `date` `"Nov 16, 2026"`).
- **Money** is a number in USD with up to 2 decimals (`185`, `38.78`), never a formatted string.
- **Pagination** uses `?page=1&limit=20` (limit at most 100); totals come back in `meta.total`.
- **Repeated filters** use repeated keys: `?make=Honda&make=Ford` (comma-separated also works).
- **Empty lists** are `[]`, never `null`.
- **Image URLs** are absolute and can be loaded directly. Stock photos come from `static.wixstatic.com`; customer uploads from `<host>/uploads/…`.

### Sign-in and token flow

1. `POST /auth/register` or `POST /auth/login` returns `accessToken` (valid `expiresIn` = 3600 seconds), `refreshToken` and `user`. Store both tokens securely.
2. Send `Authorization: Bearer <accessToken>` on every call.
3. On a 401 `UNAUTHORIZED`, call `POST /auth/refresh` with the stored `refreshToken`. It returns a NEW pair; replace both, then retry the original call once.
4. A refresh token works only once. Using an old one ends every session on that login, and refresh returns 401. Make sure only one refresh runs at a time (queue other calls behind it).
5. If refresh returns 401, clear the tokens and show Login.
6. On app launch, call `GET /auth/session`: 200 means go to Home, 401 means refresh or Login.

Refresh tokens last 30 days. Changing the password signs the customer out everywhere.

## Endpoint index

Auth column: **Public** = no token; **Optional** = works without a token, personalised (e.g. `isFavorite`) with one; **Bearer** = 401 without a valid token.

| Area | Method | Path | Auth | Success |
| --- | --- | --- | --- | --- |
| Auth | POST | `/auth/register` | Public | 201 |
| Auth | POST | `/auth/login` | Public | 200 |
| Auth | POST | `/auth/refresh` | Public | 200 |
| Auth | POST | `/auth/logout` | Bearer | 200 |
| Auth | POST | `/auth/social` | Public | 200 |
| Auth | GET | `/auth/session` | Bearer | 200 |
| Auth | POST | `/auth/forgot-password` | Public | 200 |
| Auth | POST | `/auth/reset-password` | Public | 200 |
| Account | GET | `/users/me` | Bearer | 200 |
| Account | PATCH | `/users/me` | Bearer | 200 |
| Account | POST | `/users/me/avatar` | Bearer | 200 |
| Account | POST | `/users/me/password` | Bearer | 200 |
| Account | POST | `/users/me/deletion-request` | Bearer | 200 |
| Account | DELETE | `/users/me/search-history` | Bearer | 200 |
| Settings | GET | `/settings` | Bearer | 200 |
| Settings | PATCH | `/settings` | Bearer | 200 |
| Settings | GET | `/settings/languages` | Optional | 200 |
| Addresses | GET | `/addresses` | Bearer | 200 |
| Addresses | POST | `/addresses` | Bearer | 201 |
| Addresses | PATCH | `/addresses/{id}` | Bearer | 200 |
| Addresses | DELETE | `/addresses/{id}` | Bearer | 200 |
| Addresses | POST | `/addresses/{id}/default` | Bearer | 200 |
| Payment methods | GET | `/payment-methods` | Bearer | 200 |
| Payment methods | POST | `/payment-methods` | Bearer | 201 |
| Payment methods | DELETE | `/payment-methods/{id}` | Bearer | 200 |
| Payment methods | POST | `/payment-methods/{id}/default` | Bearer | 200 |
| Parts | GET | `/parts` | Optional | 200 |
| Parts | GET | `/parts/filter-options` | Optional | 200 |
| Parts | GET | `/parts/fitments` | Optional | 200 |
| Parts | GET | `/parts/{id}` | Optional | 200 |
| Parts | GET | `/parts/{id}/similar` | Optional | 200 |
| Parts | POST | `/parts/{id}/favorite` | Bearer | 200 |
| Saved parts | GET | `/saved-parts` | Bearer | 200 |
| Saved parts | DELETE | `/saved-parts/{partId}` | Bearer | 200 |
| Home | GET | `/home/feed` | Optional | 200 |
| Home | GET | `/home/hero-banner`, `/home/stats`, `/categories`, `/home/junk-banner`, `/home/trust-strip` | Optional | 200 |
| VIN | POST | `/vin/decode` | Bearer | 200 |
| VIN | GET / POST | `/users/me/vehicles` | Bearer | 200 / 201 |
| VIN | DELETE | `/users/me/vehicles/{id}` | Bearer | 200 |
| Cart | GET | `/cart` | Bearer | 200 |
| Cart | POST | `/cart/items` | Bearer | 200 |
| Cart | PATCH | `/cart/items/{cartItemId}` | Bearer | 200 |
| Cart | DELETE | `/cart/items/{cartItemId}` | Bearer | 200 |
| Checkout | POST | `/checkout/orders` | Bearer | 201 |
| Orders | GET | `/orders` | Bearer | 200 |
| Orders | GET | `/orders/{id}` | Bearer | 200 |
| Orders | POST | `/orders/{id}/cancel` | Bearer | 200 |
| Orders | GET | `/orders/{id}/tracking` | Bearer | 200 |
| Orders | POST | `/orders/{id}/reorder` | Bearer | 200 |
| Orders | POST | `/orders/{id}/rate` | Bearer | 201 |
| Orders | POST | `/orders/{id}/return` | Bearer | 201 |
| Junk | POST | `/junk-requests/quote` | Bearer | 200 |
| Junk | POST | `/junk-requests` | Bearer | 201 |
| Junk | GET | `/junk-requests` | Bearer | 200 |
| Junk | GET | `/junk-requests/{id}` | Bearer | 200 |
| Junk | POST | `/junk-requests/{id}/cancel` | Bearer | 200 |
| Junk | POST | `/junk-requests/{id}/accept-offer` | Bearer | 200 |
| Junk | POST | `/junk-requests/{id}/pickup-schedule` | Bearer | 200 |
| Uploads | POST | `/uploads/vehicle-images` | Bearer | 201 |
| Chat | GET | `/chats/rooms` | Bearer | 200 |
| Chat | GET | `/chats/rooms/{roomId}` | Bearer | 200 |
| Chat | GET | `/chats/rooms/{roomId}/messages` | Bearer | 200 |
| Chat | POST | `/chats/rooms/{roomId}/messages` | Bearer | 201 |
| Chat | POST | `/chats/rooms/{roomId}/read` | Bearer | 200 |
| Chat | DELETE | `/chats/rooms/{roomId}/messages` | Bearer | 200 |
| Chat | DELETE | `/chats/rooms/{roomId}` | Bearer | 200 |
| Chat | GET | `/chats/unread-count` | Bearer | 200 |
| Chat | POST | `/chats/rooms/{roomId}/attachments` | Bearer | 201 |
| Realtime | WS | `wss://<host>/ws?token=<accessToken>` | Bearer (in query) | 101 |
| Help | GET | `/help/categories` | Optional | 200 |
| Help | GET | `/help/articles` | Optional | 200 |
| Help | GET | `/help/articles/{id}` | Optional | 200 |
| Support | POST | `/support/tickets` | Bearer | 201 |
| Support | GET | `/support/tickets` | Bearer | 200 |
| Support | GET | `/support/tickets/{id}` | Bearer | 200 |
| Support | POST | `/support/attachments` | Bearer | 201 |
| Support | POST | `/support/callback-request` | Bearer | 201 |
| Meta | POST | `/analytics/events` | Bearer | 202 |
| Meta | POST | `/referrals/track` | Public | 201 |
| Meta | GET | `/app/config` | Optional | 200 |

The WebSocket is at the host root (`/ws`, also `/v1/ws`), not under `/v1/` like the HTTP routes.

## Auth

### The User object

Returned by register, login, social, session and `GET/PATCH /users/me`.

```json
{
  "id": "usr_6afab2e2e2e90a1ddccb7995",
  "fullName": "Mike Johnson",
  "email": "mike@x.com",
  "phone": "+1 609 758 1919",
  "location": "Houston, TX",
  "avatarUrl": null,
  "memberSince": "Nov 2026",
  "accountType": "buyer",
  "initials": "MJ",
  "isVerified": false
}
```

### POST /auth/register

Public. Creates an account and signs the customer in.

| Field | Type | Required | Rules |
| --- | --- | --- | --- |
| `fullName` | string | Yes | 2–100 characters |
| `email` | string | Yes | Valid email; stored lower-case |
| `password` | string | Yes | 8–128 characters, at least one letter and one number |
| `phone` | string | No | Up to 30 characters |
| `deviceId` | string | No | Saved with the session |
| `platform` | string | No | `ios` or `android` |

```json
{ "fullName": "Mike Johnson", "email": "mike@x.com", "password": "P@ssw0rd1", "deviceId": "a3f19c2b", "platform": "android" }
```

**201 Created**

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs…",
    "refreshToken": "rft_65965d97e7137a95…",
    "expiresIn": 3600,
    "user": { "id": "usr_6afab2e2e2e90a1ddccb7995", "fullName": "Mike Johnson", "email": "mike@x.com", "…": "…" }
  },
  "requestId": "515a338a-…"
}
```

| Status | Code | When |
| --- | --- | --- |
| 409 | `CONFLICT` | Email already registered (`details.field` = `email`) |
| 422 | `VALIDATION_ERROR` | Missing name, bad email, weak password, e.g. "Password must be at least 8 characters." |
| 429 | `RATE_LIMITED` | More than 20 sign-in calls in 15 minutes from one IP |

### POST /auth/login

Public. Body `{ "email": "mike@x.com", "password": "P@ssw0rd1", "deviceId": "a3f19c2b" }`.

**200 OK**: same `data` as register.

| Status | Code | When |
| --- | --- | --- |
| 401 | `INVALID_CREDENTIALS` | Wrong email or password: "Incorrect email or password." |
| 403 | `FORBIDDEN` | Account suspended |
| 422 | `VALIDATION_ERROR` | Email or password missing |
| 400 | `BAD_REQUEST` | Body is not valid JSON |

### POST /auth/refresh

Public. Body `{ "refreshToken": "rft_…" }`. Call it when any request returns 401.

**200 OK**

```json
{ "success": true, "data": { "accessToken": "eyJ…", "refreshToken": "rft_0e5217…", "expiresIn": 3600 }, "requestId": "…" }
```

Replace BOTH stored tokens. The old refresh token stops working immediately.

| Status | Code | When |
| --- | --- | --- |
| 401 | `UNAUTHORIZED` | Token unknown, expired (30 days), already used, or the account was signed out everywhere. Send the user to Login. |

### POST /auth/logout

Bearer. Body `{ "refreshToken": "rft_…" }` (ends that session). **200 OK** with `data: {}`. Delete the stored tokens either way.

### POST /auth/social

Public. Signs in with Google or Facebook and creates the account on first use.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `provider` | string | Yes | `google` or `facebook` |
| `idToken` | string | Yes | Google: the Google **ID token**. Facebook: the Facebook **user access token**. |
| `deviceId` | string | No |  |

**200 OK**: same `data` as login.

| Status | Code | When |
| --- | --- | --- |
| 401 | `UNAUTHORIZED` | Token rejected by Google/Facebook or issued for another app |
| 422 | `VALIDATION_ERROR` | Unknown provider; the account has no verified email |
| 503 | `SERVICE_UNAVAILABLE` | Provider not configured on the server yet (true today until the backend team adds the client ids) |

### GET /auth/session

Bearer. Use on app launch. **200 OK**: `{ "authenticated": true, "user": { …User } }`. **401** = refresh or show Login.

### POST /auth/forgot-password

Public. Body `{ "email": "mike@x.com" }`. Always **200 OK** with `data.message` "If an account exists for this email, a reset link has been sent.", whether or not the email exists. The email contains a link `autohub://reset-password?token=<token>` (valid 60 minutes); the app should handle that deep link.

### POST /auth/reset-password

Public. Not in the original spec; completes the forgot-password flow.

| Field | Type | Required | Rules |
| --- | --- | --- | --- |
| `token` | string | Yes | The token from the deep link |
| `newPassword` | string | Yes | Same rules as register |

**200 OK**: `data.message` "Password updated. Please sign in with your new password." All sessions are signed out.

| Status | Code | When |
| --- | --- | --- |
| 422 | `VALIDATION_ERROR` | Token invalid, expired or already used (`details.field` = `token`); weak password |

## Account and settings

All Bearer, except `GET /settings/languages`.

### GET /users/me

**200 OK**: `data` = the User object.

### PATCH /users/me

Send only the fields that changed.

| Field | Type | Rules |
| --- | --- | --- |
| `fullName` | string | 2–100 characters |
| `phone` | string | Up to 30 characters; `""` clears it |
| `location` | string | Up to 120 characters; `""` clears it |

**200 OK**: the full, updated User. **422** `VALIDATION_ERROR` with `details.field` on a bad value.

### POST /users/me/avatar

`multipart/form-data` with one file in the field **`file`**: JPG or PNG, at most 5 MB.

**200 OK**

```json
{ "success": true, "data": { "avatarUrl": "https://<host>/uploads/app-avatar-1794814690873-3b….jpg" }, "requestId": "…" }
```

| Status | Code | When |
| --- | --- | --- |
| 422 | `VALIDATION_ERROR` | No file, wrong type ("Only jpg, png images are allowed.") or larger than 5 MB ("The file is too large.") |

### POST /users/me/password

Body `{ "currentPassword": "…", "newPassword": "…" }` (new password: same rules as register).

**200 OK**: `data.message` = "Password updated". Every session is signed out, including this one: the current access token now returns 401 "Your password was changed. Please sign in again.", so send the user to Login (or log in again with the new password).

| Status | Code | When |
| --- | --- | --- |
| 422 | `VALIDATION_ERROR` | Current password wrong (`details.field` = `currentPassword`); new password weak or same as current (`newPassword`) |

### POST /users/me/deletion-request

Body `{ "reason": "user_request", "confirmationText": "DELETE" }`. `confirmationText` must be exactly `DELETE`.

**200 OK**

```json
{ "success": true, "data": { "requestId": "del_6afab2e6e2e90a1ddccb7c11", "status": "scheduled", "gracePeriodDays": 30, "scheduledFor": "2026-12-16T07:38:14.333Z" }, "requestId": "…" }
```

The customer is signed out everywhere (refresh tokens revoked). Sending it again returns the same request. **422** if `confirmationText` is not `DELETE`.

### DELETE /users/me/search-history

Clears the searches recorded from `GET /parts?q=…` while signed in. **200 OK**: `{ "cleared": 3 }`.

### GET /settings

**200 OK**

```json
{
  "pushNotifications": true, "emailNotifications": true, "priceDropAlerts": false,
  "orderUpdates": true, "chatMessages": true, "notificationSounds": true,
  "vibration": true, "darkMode": true, "autoDistanceUnit": true,
  "selectedLanguage": "English", "selectedLanguageFlag": "🇺🇸"
}
```

### PATCH /settings

Send only the changed keys, e.g. `{ "darkMode": false, "priceDropAlerts": true }`. Booleans must be real JSON booleans. **200 OK** returns the full settings object.

| Status | Code | When |
| --- | --- | --- |
| 422 | `VALIDATION_ERROR` | Unknown key, wrong type (e.g. `"no"` instead of `false`), or a `selectedLanguage` not in `/settings/languages` |

### GET /settings/languages

Optional auth. **200 OK**: `[ { "code": "en", "name": "English", "flag": "🇺🇸" }, { "code": "es", "name": "Español", "flag": "🇲🇽" } ]`. Send the `name` as `selectedLanguage`.

## Addresses and payment methods

All Bearer. A customer only ever sees their own addresses and cards; another customer's id returns 404.

### The Address object

```json
{ "id": "adr_6afab2e2e2e90a1ddccb7a1e", "type": "home", "label": "Home", "streetAddress": "4521 Westheimer Rd", "city": "Houston", "state": "TX", "zip": "77027", "isDefault": true }
```

### Address endpoints

| Method + path | Body | Success | Notes |
| --- | --- | --- | --- |
| `GET /addresses` | — | 200, array of Address | Default first; `[]` when none |
| `POST /addresses` | Address fields (no `id`) | 201, Address | The first address becomes the default automatically |
| `PATCH /addresses/{id}` | Only changed fields | 200, Address |  |
| `DELETE /addresses/{id}` | — | 200, `{}` | If it was the default, the oldest remaining one becomes default |
| `POST /addresses/{id}/default` | — | 200, Address | Unsets every other default |

| Field | Type | Required on create | Rules |
| --- | --- | --- | --- |
| `type` | string | No (default `home`) | `home`, `work` or `other` |
| `label` | string | No | Up to 40 characters |
| `streetAddress` | string | Yes | Up to 200 characters |
| `city` | string | Yes | Up to 80 characters |
| `state` | string | Yes | Up to 40 characters, e.g. `TX` |
| `zip` | string | Yes | 5 digits, or ZIP+4 (`77027-1234`) |
| `isDefault` | boolean | No | `true` makes it the default |

| Status | Code | When |
| --- | --- | --- |
| 404 | `NOT_FOUND` | Address id unknown or not this customer's |
| 422 | `VALIDATION_ERROR` | Missing field or bad ZIP ("ZIP code must be 5 digits.") |

### The PaymentCard object

```json
{ "id": "pm_6afab2e3e2e90a1ddccb7a46", "cardHolder": "Mike Johnson", "last4": "4242", "expiry": "09/30", "brand": "Visa", "isDefault": true }
```

`brand` is one of `Visa`, `Mastercard`, `Amex`, `Discover`, `JCB`, `Diners Club`, `Card`. The full card number and CVC are never returned and never stored.

### Payment method endpoints

| Method + path | Body | Success | Notes |
| --- | --- | --- | --- |
| `GET /payment-methods` | — | 200, array of PaymentCard | Default first |
| `POST /payment-methods` | See below | 201, PaymentCard | The first card becomes the default |
| `DELETE /payment-methods/{id}` | — | 200, `{}` | If it was the default, the oldest remaining card becomes default |
| `POST /payment-methods/{id}/default` | — | 200, PaymentCard |  |

**POST /payment-methods** body (today's card-entry form):

```json
{ "cardHolder": "Mike Johnson", "cardNumber": "4242424242424242", "expiry": "09/30", "cvc": "123", "makeDefault": false }
```

| Field | Rules |
| --- | --- |
| `cardHolder` | 2–100 characters |
| `cardNumber` | 12–19 digits, spaces/dashes allowed, must pass the Luhn check |
| `expiry` | `MM/YY` (or `MM/YYYY`), not in the past |
| `cvc` | 3 or 4 digits; checked, then discarded |
| `makeDefault` | Optional boolean |

When a payment gateway (e.g. Stripe) is added, send its token instead of the card number: `{ "cardHolder", "paymentMethodId": "pm_gateway_…", "brand": "Visa", "last4": "4242", "expiry": "09/30" }`.

| Status | Code | When |
| --- | --- | --- |
| 409 | `CONFLICT` | Same card (brand + last 4 + expiry) already saved |
| 404 | `NOT_FOUND` | Card id unknown or not this customer's |
| 422 | `VALIDATION_ERROR` | Invalid number (`cardNumber`), expired or bad format (`expiry`), bad CVC (`cvc`) |

No card is charged anywhere in this API yet (see Known limits).

## Parts, saved parts, home feed and VIN

Parts are the in-stock items of the yard's inventory. A part that sells (in the app, on eBay, Wix or in store) disappears from these lists within about 2 minutes, and immediately after an app order.

### The Part object (list item)

```json
{
  "id": "prt_6afab2df5917c805aaf26ba1",
  "title": "Front Bumper",
  "price": 375,
  "condition": "Good",
  "rating": 0,
  "ratingCount": 0,
  "make": "Toyota",
  "model": "Corolla",
  "yearRange": "2001",
  "category": "Vehicle Body Parts",
  "warranty": "30 Days",
  "location": "AutoHub Express",
  "imagePath": "https://static.wixstatic.com/media/d1d397_0b78….png",
  "tag": "New",
  "isFavorite": false
}
```

- `condition`: `Excellent`, `Good`, `Fair` or `For Parts`.
- `yearRange` is the donor car's model year (a single year today).
- `tag`: `"New"` (listed in the last 14 days), `"Featured"` (only in featured lists) or `null`.
- `imagePath` can be `null` (show a placeholder).
- `isFavorite` is only ever `true` when a token is sent.

### GET /parts

Optional auth. Query parameters:

| Param | Type | Notes |
| --- | --- | --- |
| `q` | string | Free text over title, make, model, category, part number |
| `make` | string, repeatable | `make=Toyota&make=BMW`; case-insensitive |
| `category` | string, repeatable | Values from `/parts/filter-options` |
| `condition` | string, repeatable | `Excellent`, `Good`, `Fair`, `For Parts` |
| `minPrice`, `maxPrice` | number | USD |
| `vin` | string | 17 characters; only parts that fit that vehicle |
| `featured` | `true` | Only parts with a photo, tagged `Featured` |
| `sort` | string | `newest` (default), `price_asc`, `price_desc`, `top_rated` |
| `page`, `limit` | int | Defaults 1 and 20; limit at most 100 |

**200 OK**: `data` = array of Part; `meta` = `{ "page": 1, "limit": 20, "total": 4 }`. With no filters `meta.total` is the whole catalog size ("N parts listed").

| Status | Code | When |
| --- | --- | --- |
| 422 | `VALIDATION_ERROR` | Bad `sort`, negative price, invalid `vin`, or a VIN NHTSA can't decode |
| 503 | `SERVICE_UNAVAILABLE` | `vin` given and the NHTSA VIN service is down |

### GET /parts/filter-options

Optional auth. Accepts the same filters as `/parts` to preview a result count.

```json
{ "makes": ["Toyota"], "categories": ["Engine", "Vehicle Body Parts"], "conditions": ["Excellent", "Good", "Fair", "For Parts"], "priceRange": { "min": 95, "max": 375 }, "resultCount": 4 }
```

### GET /parts/fitments

Optional auth. `?vin=1NXBR12E91Z123456&page=1&limit=20`. Same response as `/parts`, plus the decoded vehicle in `meta.vehicle`: `{ "vin": "1NXBR12E91Z123456", "year": 2001, "make": "TOYOTA", "model": "Corolla", "trim": "" }`. A part fits when make and model match and the model year is the same. Errors as `/parts` with `vin`.

### GET /parts/{id}

Optional auth. **200 OK**

```json
{
  "id": "prt_6afab2df5917c805aaf26ba1",
  "title": "Front Bumper",
  "subtitle": "Vehicle Body Parts",
  "description": "Front bumper cover from a 2001 Toyota Corolla, straight w…",
  "price": 375,
  "condition": "Good",
  "tag": "New",
  "imageUrl": "https://static.wixstatic.com/media/d1d397_0b78….png",
  "rating": 0,
  "ratingCount": 0,
  "warranty": "30 Days",
  "isFavorite": false,
  "location": "AutoHub Express",
  "partNumber": "TOY/COR/2001-FB1",
  "quantityAvailable": 1,
  "specifications": { "category": "Vehicle Body Parts", "compatibleMake": "Toyota", "compatibleModel": "Corolla", "yearRange": "2001", "trim": "CE", "donorMileage": null, "weight": "22 lbs" },
  "fitment": { "label": "Fits: Toyota Corolla", "detail": "Model year 2001 · Trim: CE" },
  "yard": { "yardId": "yrd_1", "name": "AutoHub Express", "address": "", "phone": "", "businessHours": "Mon-Sat 8AM-6PM", "pickupAvailable": true, "deliveryNationwide": true, "isVerified": true, "rating": null, "ratingCount": null },
  "listedAt": "2026-11-16T07:38:07.819Z"
}
```

`donorMileage`, `weight`, `partNumber`, `yard.rating` may be `null`; hide those rows. **404** `NOT_FOUND`: unknown id, or the part has sold ("This part is no longer available.").

### GET /parts/{id}/similar

Optional auth. `?limit=10` (max 20). **200 OK**: array of Part (same category first, then same vehicle; never the part itself). Works for sold parts too. **404** for an unknown id.

### POST /parts/{id}/favorite

Bearer. Body `{}`. Toggles. **200 OK**: `{ "partId": "prt_…", "isFavorite": true }` (or `false` after removing). **401** without a token, **404** unknown part.

### GET /saved-parts and DELETE /saved-parts/{partId}

Bearer. `GET /saved-parts?page=1&limit=20` returns an array of Part (all `isFavorite: true`) with `meta`. Saved parts that have since sold are left out. `DELETE /saved-parts/{partId}` returns **200** `{}`, or **404** if the part isn't saved.

### GET /home/feed

Optional auth. One call for the whole home screen.

```json
{
  "hero": { "id": "bnr_1", "title": "Quality used auto parts", "subtitle": "Tested OEM parts from our yard", "imageUrl": null, "ctaLabel": "Shop now", "ctaUrl": "autohub://browse" },
  "stats": [ { "label": "Parts listed", "value": "4" }, { "label": "Makes covered", "value": "1" }, { "label": "Categories", "value": "2" } ],
  "categories": [ { "id": "cat_engine", "name": "Engine", "iconUrl": null, "partCount": 2 } ],
  "featured": [ "…Part (tag Featured), up to 10" ],
  "recent": [ "…Part, newest first, up to 10" ],
  "junkBanner": { "title": "Junk your car", "subtitle": "Free towing + cash offer", "imageUrl": null, "ctaUrl": "autohub://new-junk-request" },
  "trustStrip": { "items": [ { "icon": "verified", "label": "Verified sellers" }, { "icon": "shield", "label": "Warranty protected" } ] }
}
```

Stats values are strings (large numbers come as `"48K"`). `imageUrl` / `iconUrl` can be `null`: use bundled assets. Each block is also available alone: `GET /home/hero-banner`, `/home/stats`, `/categories`, `/home/junk-banner`, `/home/trust-strip` (same shapes, all 200, optional auth). To open a category, call `/parts?category=<name>`.

### POST /vin/decode

Bearer. Body `{ "vin": "1NXBR12E91Z123456" }`. Calls NHTSA vPIC (the app can keep calling vPIC directly as a fallback).

```json
{ "vin": "1NXBR12E91Z123456", "Make": "TOYOTA", "Model": "Corolla", "ModelYear": "2001", "Trim": "", "BodyClass": "Sedan/Saloon", "Doors": "4", "DriveType": "4x2", "EngineHP": "", "EngineCylinders": "4", "DisplacementL": "1.8", "FuelTypePrimary": "Gasoline", "TransmissionStyle": "", "ManufacturerName": "", "PlantCountry": "UNITED STATES (USA)" }
```

Unknown values are `""`. **422**: not 17 valid characters (letters I, O, Q are never valid) or NHTSA can't decode it. **503**: NHTSA not responding.

### My garage: /users/me/vehicles

Bearer.

- `POST /users/me/vehicles` body `{ "vin": "1NXBR12E91Z123456", "label": "My Corolla" }` (label optional) → **201** `{ "id": "veh_6afab2e38d2b54bc64a36aea", "vin": "…", "label": "My Corolla", "year": 2001, "make": "TOYOTA", "model": "Corolla", "trim": "", "createdAt": "…" }`. Saving the same VIN again updates it.
- `GET /users/me/vehicles` → **200** array of vehicles, newest first.
- `DELETE /users/me/vehicles/{id}` → **200** `{}`; **404** if unknown.

Use a saved vehicle's VIN with `/parts/fitments?vin=` for one-tap "parts that fit".

## Cart, checkout and orders

All Bearer. Each customer has one cart, kept on the server.

### The Cart object

Every cart endpoint (GET, POST, PATCH, DELETE) returns the whole updated cart.

```json
{
  "cartId": "crt_6afab2e38d2b54bc64a36aeb",
  "items": [
    {
      "cartItemId": "ci_6afab2e3e2e90a1ddccb7ab1",
      "part": { "id": "prt_6afab2df5917c805aaf26ba1", "title": "Front Bumper", "price": 375, "…": "…Part" },
      "quantity": 1,
      "unitPrice": 375,
      "maxQuantity": 1,
      "isAvailable": true
    }
  ],
  "subtotal": 470,
  "shipping": 0,
  "tax": 38.78,
  "total": 508.78,
  "freeShippingThreshold": 100,
  "qualifiesForFreeShipping": true
}
```

- `maxQuantity` = how many the yard has; most parts are 1 of a kind.
- `isAvailable: false` = the part sold since it was added. Its `part` then holds only `id`, it is left out of the totals, and checkout will fail until it is removed.
- Cart totals use standard shipping. The real totals for the chosen shipping method come back from checkout.

### Cart endpoints

| Method + path | Body | Success |
| --- | --- | --- |
| `GET /cart` | — | 200, Cart |
| `POST /cart/items` | `{ "partId": "prt_…", "quantity": 1 }` (quantity optional, default 1; adding the same part again adds to its quantity) | 200, Cart |
| `PATCH /cart/items/{cartItemId}` | `{ "quantity": 2 }` | 200, Cart |
| `DELETE /cart/items/{cartItemId}` | — | 200, Cart |

| Status | Code | When |
| --- | --- | --- |
| 409 | `CONFLICT` | Part sold or not available; quantity above stock ("Only 1 of this part is available.", `details.available`) |
| 404 | `NOT_FOUND` | Unknown `partId` or `cartItemId` |
| 422 | `VALIDATION_ERROR` | `partId` missing; quantity not a whole number from 1 to 10 |

### POST /checkout/orders

Places the order for everything in the cart, then empties the cart.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `addressId` | string | Yes | One of the customer's `adr_` ids |
| `paymentMethodId` | string | Yes | One of the customer's `pm_` ids |
| `shippingMethod` | string | No | `standard` (default) or `express` |
| `couponCode` | string or null | No | Send `null`. No coupons exist yet, so any code returns 422. |

```json
{ "addressId": "adr_6afab2e2e2e90a1ddccb7a1e", "paymentMethodId": "pm_6afab2e3e2e90a1ddccb7a46", "shippingMethod": "standard", "couponCode": null }
```

**201 Created**

```json
{ "success": true, "data": { "orderId": "ord_6afab2e3e2e90a1ddccb7b0a", "orderNumber": "AH-1", "total": 405.94, "paymentStatus": "pending" }, "requestId": "…" }
```

| Status | Code | When |
| --- | --- | --- |
| 409 | `CONFLICT` | A part in the cart was just sold (`details.partId`): "A part in your cart was just sold. Please review your cart." Reload the cart. |
| 422 | `VALIDATION_ERROR` | Empty cart (`details.field` = `cart`); missing/unknown address or card (`addressId`, `paymentMethodId`); bad `shippingMethod`; any `couponCode` |

Pricing today: standard shipping $15, free when the subtotal is $100 or more; express $35; tax 8.25 % of the subtotal. These numbers come from the server and may change, so always display the totals the API returns. `paymentStatus` is always `"pending"` for now: no card is charged.

### The Order object

```json
{
  "id": "ord_6afab2e4e2e90a1ddccb7b57",
  "orderNumber": "AH-2",
  "title": "Front Bumper",
  "price": 440.94,
  "status": "delivered",
  "trackingNumber": "1Z999AA10123456784",
  "address": "4521 Westheimer Rd, Houston, TX 77027",
  "placedAt": "2026-11-16T07:38:12.253Z",
  "estimatedDelivery": "2026-11-18T07:38:12.253Z",
  "items": [ { "partId": "prt_6afab2df5917c805aaf26ba4", "title": "Front Bumper", "quantity": 1, "unitPrice": 375, "imageUrl": "https://static.wixstatic.com/…" } ],
  "subtotal": 375,
  "shipping": 35,
  "tax": 30.94,
  "total": 440.94,
  "shippingMethod": "express",
  "paymentStatus": "pending",
  "timeline": [
    { "title": "Order Placed", "time": "Nov 16, 1:38 AM", "isCompleted": true },
    { "title": "Shipped", "time": "Nov 16, 1:38 AM", "isCompleted": true },
    { "title": "Delivered", "time": "Nov 16, 1:38 AM", "isCompleted": true }
  ]
}
```

- `status`: `processing` → `inTransit` → `delivered`; or `cancelled` (only from `processing`). Staff move orders forward.
- `title` = first item's title, plus " + N more" for multi-item orders. `price` = `total`.
- `timeline` steps not reached yet have `time: null` and `isCompleted: false`. A cancelled order ends with a completed "Cancelled" step. Times use the request's `X-Timezone`.
- `trackingNumber` and `estimatedDelivery` may be `null`.

### Order endpoints

| Method + path | Body | Success | Errors |
| --- | --- | --- | --- |
| `GET /orders?status=all&page=1&limit=20` | — | 200, array of Order + `meta` (newest first) | 422 bad `status` |
| `GET /orders/{id}` | — | 200, Order | 404 unknown or another customer's |
| `POST /orders/{id}/cancel` | `{ "reason": "no_longer_needed", "note": "Found a local one" }` | 200, updated Order (status `cancelled`) | 409 already shipped or already cancelled; 422 no reason |
| `GET /orders/{id}/tracking` | — | 200, Tracking (below) | 404 |
| `POST /orders/{id}/reorder` | `{ "items": [ { "partId": "prt_…", "quantity": 1 } ] }` (optional; omit to reorder everything) | 200, `{ "cartId", "itemCount", "unavailablePartIds" }` | 404 |
| `POST /orders/{id}/rate` | `{ "rating": 5, "comment": "Great part, fast shipping" }` | 201, `{ "reviewId": "rev_…" }` | 409 not delivered yet or already rated; 422 rating not 1–5 |
| `POST /orders/{id}/return` | `{ "reason": "wrong_part", "note": "", "images": ["https://…"] }` | 201, `{ "returnId": "ret_…", "labelUrl": null, "status": "requested" }` | 409 not delivered, or a return already open; 422 no reason or more than 8 images |

- `status` filter: `all`, `active` (= processing + inTransit), `completed` (= delivered), `cancelled`.
- Cancel reasons the app can send: `no_longer_needed`, `found_cheaper`, `ordered_by_mistake`, `delivery_too_slow`, `other` (any lower_snake_case word is accepted). Cancelling puts the parts back in stock.
- Reorder adds the parts that are still available to the cart; `unavailablePartIds` lists the ones that are not. Then open the cart.
- Return images: upload with `POST /uploads/vehicle-images` first, then send the URLs.
- A return starts as `requested` with `labelUrl: null`; staff issue the label later. Show "We'll email your return label" rather than a download button.

**Tracking**

```json
{ "carrier": "UPS", "trackingNumber": "1Z999AA10123456784", "trackingUrl": "https://www.ups.com/track?tracknum=1Z999AA10123456784", "estimatedDelivery": "2026-11-18T07:38:12.253Z", "events": [ { "status": "in_transit", "description": "Departed Houston, TX", "occurredAt": "2026-11-16T07:38:12.362Z" } ] }
```

Before shipping, `carrier`, `trackingNumber` and `trackingUrl` are `null` and `events` is `[]`. Event `status`: `label_created`, `picked_up`, `in_transit`, `out_for_delivery`, `delivered` (newest first).

## Junk car requests and photo uploads

All Bearer. The flow is: quote → upload photos → create request (status `offerPending`, with the offer) → accept offer → schedule pickup (status `pickupScheduled`) → staff complete it (`completed`). The customer can cancel any time before `completed`. Each request also appears for staff in the CRM's Junk Car Requests list.

### Vehicle fields (quote and create)

| Field | Type | Required | Rules |
| --- | --- | --- | --- |
| `year` | string | Yes | 4 digits, 1950 to next year, e.g. `"2010"` |
| `make` | string | Yes | Up to 60 characters |
| `model` | string | Yes | Up to 60 characters |
| `vin` | string | No | `""` or a valid 17-character VIN |
| `condition` | string | Yes | Exactly one of the four strings below |
| `hasTitle` | boolean | Yes |  |
| `hasKeys` | boolean | Yes |  |

`condition` must be sent exactly as shown, including the en-dash (–), not a hyphen:

- `Running – Good condition`
- `Running – Needs repairs`
- `Non-running – Fixable`
- `Non-running – Totaled/Scrap`

### POST /junk-requests/quote

Body: the vehicle fields. Saves nothing; shows the offer before the customer submits.

**200 OK**

```json
{ "estimatedOffer": 450, "currency": "USD", "validUntil": "2026-11-17T07:38:12.422Z", "breakdown": [ { "label": "Vehicle base value", "amount": 450 } ] }
```

`breakdown` lines add up to `estimatedOffer`; deductions are negative (e.g. `{ "label": "Deduction – no title", "amount": -100 }`). The offer is valid for 24 hours.

| Status | Code | When |
| --- | --- | --- |
| 422 | `VALIDATION_ERROR` | Bad year, missing make/model, condition not one of the four strings, `hasTitle`/`hasKeys` not booleans |
| 503 | `SERVICE_UNAVAILABLE` | Instant offers switched off by the business; let the customer submit without a quote |

### POST /uploads/vehicle-images

`multipart/form-data`, files in the field **`files[]`** (repeat the field per file; `files` also works). Up to 8 images, JPG, PNG or HEIC, at most 10 MB each.

**201 Created**: `{ "urls": ["https://<host>/uploads/app-vehicle-1794814692430-f….jpg", "…"] }`. Send these URLs as `imageUrls` when creating the request.

**422** `VALIDATION_ERROR`: no files, more than 8, wrong type or too large.

### POST /junk-requests

Body: the vehicle fields plus:

| Field | Type | Required | Rules |
| --- | --- | --- | --- |
| `pickupAddress` | string | Yes | Free text, 5–300 characters |
| `notes` | string | No | Up to 1000 characters |
| `imageUrls` | array of strings | No | Up to 8 URLs from the upload endpoint |

```json
{ "year": "2010", "make": "Honda", "model": "Civic", "vin": "2HGFC2F59NH504321", "condition": "Running – Good condition", "hasTitle": true, "hasKeys": true, "pickupAddress": "4521 Westheimer Rd, Houston, TX 77027", "notes": "Car is in the driveway, keys under the mat", "imageUrls": ["https://<host>/uploads/app-vehicle-….jpg"] }
```

**201 Created**: a JunkRequest.

### The JunkRequest object

```json
{
  "id": "jnk_6afab2e4e2e90a1ddccb7b9f",
  "status": "offerPending",
  "vehicleTitle": "2010 Honda Civic",
  "date": "Nov 16, 2026",
  "createdAt": "2026-11-16T07:38:12.438Z",
  "year": "2010", "make": "Honda", "model": "Civic",
  "vin": "2HGFC2F59NH504321",
  "condition": "Running – Good condition",
  "hasTitle": true, "hasKeys": true,
  "pickupAddress": "4521 Westheimer Rd, Houston, TX 77027",
  "notes": "Car is in the driveway, keys under the mat",
  "imageUrls": ["https://<host>/uploads/app-vehicle-….jpg"],
  "offerAmount": 450,
  "offerValidUntil": "2026-11-17T07:38:12.437Z",
  "offerAccepted": false,
  "pickupDateTime": null,
  "towCompany": null,
  "salvageYardName": "AutoHub Express",
  "salvageYardPhone": null
}
```

`status`: `offerPending`, `pickupScheduled`, `completed`, `cancelled`. After accepting, `status` stays `offerPending` with `offerAccepted: true` until a pickup is scheduled. `offerAmount` can be `null` if instant offers are off.

### Other junk request endpoints

| Method + path | Body | Success | Errors |
| --- | --- | --- | --- |
| `GET /junk-requests?status=all&page=1&limit=20` | — | 200, array of JunkRequest + `meta`, newest first | 422 bad `status` |
| `GET /junk-requests/{id}` | — | 200, JunkRequest | 404 unknown or another customer's |
| `POST /junk-requests/{id}/accept-offer` | `{ "offerAmount": 450 }` (the amount shown) | 200, JunkRequest (`offerAccepted: true`) | 409 amount changed, offer expired, or request not `offerPending`; 422 no amount |
| `POST /junk-requests/{id}/pickup-schedule` | `{ "scheduledAt": "2026-04-03T09:00:00Z", "notes": "" }` | 200, JunkRequest (`pickupScheduled`) | 409 offer not accepted yet, or request completed/cancelled; 422 time less than 1 hour away or more than 60 days away |
| `POST /junk-requests/{id}/cancel` | `{ "reason": "changed_mind" }` (optional) | 200, JunkRequest (`cancelled`) | 409 already completed or cancelled |

`status` filter values: `all`, `active` (offerPending + pickupScheduled), `offerPending`, `pickupScheduled`, `completed`, `cancelled`. On a 409 for accept-offer, `details.offerAmount` holds the current offer: show it and ask again.

## Messaging and realtime

All Bearer. Every customer automatically has one room, "AutoHub Support" (`participantType: "support"`); its messages reach the yard's staff inbox and their replies come back here. Rooms of type `seller` and `tow` exist in the format but none are created yet.

### The ChatRoom and ChatMessage objects

```json
{ "chatRoomId": "6afab2e48d2b54bc64a36af0", "name": "AutoHub Support", "lastMessage": "", "timestamp": "2026-11-16T07:38:12.511Z", "initials": "AS", "avatarUrl": null, "isOnline": true, "unreadCount": 0, "participantType": "support" }
```

```json
{ "id": "msg_6afab2e4e2e90a1ddccb7bc6", "chatRoomId": "6afab2e48d2b54bc64a36af0", "senderId": "usr_6afab2e2e2e90a1ddccb7995", "senderName": "Mike Johnson", "text": "Hello, is the bumper still available?", "sentAt": "2026-11-16T07:38:12.532Z", "isSender": true, "status": "sent", "attachmentUrl": null }
```

- `isSender: true` = sent by this customer (show on the right).
- Staff messages have `senderId: "support"` and `senderName: "AutoHub Support"`.
- Message `status`: `sent`, `delivered`, `read`. `sending` is a client-only state.
- `chatRoomId` has no prefix.

### Endpoints

| Method + path | Body / query | Success | Errors |
| --- | --- | --- | --- |
| `GET /chats/rooms?type=all&page=1&limit=20` | `type`: `all`, `support`, `seller`, `tow` | 200, array of ChatRoom + `meta`, latest message first | 422 bad `type` |
| `GET /chats/rooms/{roomId}` | — | 200, ChatRoom | 404 |
| `GET /chats/rooms/{roomId}/messages?limit=30&before=` | `limit` max 100; `before` = a message id (or ISO date) to load older messages | 200, array of ChatMessage, newest first; `meta` = `{ "limit", "hasMore", "nextBefore" }` | 404; 422 bad `before` |
| `POST /chats/rooms/{roomId}/messages` | `{ "text": "Hello", "attachmentUrl": null }` | 201, `{ "id": "msg_…", "sentAt": "…", "status": "sent" }` | 422 both empty, or text over 2000 characters; 404 |
| `POST /chats/rooms/{roomId}/read` | — | 200, `{}` | 404 |
| `DELETE /chats/rooms/{roomId}/messages` | — | 200, `{}` (clear chat: hides history for this customer) | 404 |
| `DELETE /chats/rooms/{roomId}` | — | 200, `{}` | 404 |
| `GET /chats/unread-count` | — | 200, `{ "total": 3, "byRoom": { "6afab2e4…": 3 } }` | — |
| `POST /chats/rooms/{roomId}/attachments` | `multipart/form-data`, field **`file`**: JPG, PNG, HEIC or WEBP, at most 10 MB | 201, `{ "attachmentUrl": "https://…", "url": "https://…" }` | 422 wrong type/size; 404 |

- Paging older messages: pass `meta.nextBefore` as `before` until `hasMore` is `false`.
- Sending a photo: upload it to `/attachments`, then send a message with `attachmentUrl` set (text may be empty).
- "Delete conversation" on the support room clears it but keeps it in the list, so the customer can always reach support.
- Call `/read` when the room is opened; the room's `unreadCount` goes to 0.

### Realtime WebSocket

Connect with the access token. This is a plain WebSocket (e.g. Dart's `WebSocketChannel`), not Socket.IO:

```
wss://<host>/ws?token=<accessToken>
```

A bad or expired token gets an HTTP 401 at connect time. Reconnect with a fresh token after a refresh. Every frame is JSON text.

| Direction | Frame | Meaning |
| --- | --- | --- |
| Server → app | `{ "event": "message.new", "data": ChatMessage }` | A new message: staff reply, or one this customer sent from another device |
| Server → app | `{ "event": "room.updated", "data": ChatRoom }` | Room's last message or unread count changed |
| Server → app | `{ "event": "message.read", "data": { "chatRoomId", "readAt" } }` | Room was marked read (this customer, another device) |
| App → server | `{ "event": "typing", "data": { "chatRoomId": "…" } }` | Customer is typing (shown to staff) |
| App → server | `{ "event": "ping" }` | Server answers `{ "event": "pong" }` |

The server pings every 30 seconds and drops dead connections. If the socket can't connect, poll `GET /chats/unread-count` every 15 seconds instead. A `typing` event from staff is defined in the format but not sent yet.

## Help, support and app metadata

### Help center (optional auth)

| Method + path | Query | Success |
| --- | --- | --- |
| `GET /help/categories` | — | 200, `[ { "name": "Junking", "articleCount": 2 }, { "name": "Orders", "articleCount": 2 }, … ]` |
| `GET /help/articles` | `category` (`All` or a name), `q` (search title + content), `page`, `limit` | 200, array of HelpArticle + `meta` |
| `GET /help/articles/{id}` | — | 200, HelpArticle; 404 unknown id |

```json
{ "id": "1", "title": "How do I junk my car?", "content": "Navigate to the Home screen and tap 'Junk Your Car'…", "category": "Junking", "updatedAt": "2026-03-01T00:00:00Z" }
```

Today the server returns the same 8 articles the app ships with (categories Junking, Orders, Parts, Payments), so the screen can switch to the API with no visible change.

### Support tickets (Bearer)

**POST /support/tickets**

| Field | Type | Required | Rules |
| --- | --- | --- | --- |
| `category` | string | Yes | Exactly one of `General`, `Order Issue`, `Part Question`, `Junk Request`, `Payment`, `Bug Report` |
| `subject` | string | Yes | 3–150 characters |
| `description` | string | Yes | 10–4000 characters |
| `orderId` | string | No | One of the customer's `ord_` ids |
| `attachments` | array of strings | No | Up to 5 URLs from `POST /support/attachments` |

**201 Created**: `{ "ticketId": "tkt_6afab2e4e2e90a1ddccb7beb", "ticketNumber": "TKT-1", "status": "open", "createdAt": "…", "slaHours": 24 }`. **422** for a bad category, short subject/description or unknown order.

| Method + path | Success |
| --- | --- |
| `GET /support/tickets?page=1&limit=20` | 200, array of tickets + `meta`, newest first |
| `GET /support/tickets/{id}` | 200, ticket with `replies: [ { "from": "staff", "name", "text", "createdAt" } ]`; 404 if unknown |
| `POST /support/attachments` | `multipart/form-data`, field `files[]`, up to 5 images (JPG, PNG, HEIC, at most 10 MB) → 201 `{ "urls": […] }` |

Ticket `status`: `open`, `pending`, `resolved`, `closed`.

**POST /support/callback-request** body `{ "phone": "+16097581919", "preferredTime": "10:00-12:00" }` (`preferredTime` optional, format `HH:MM-HH:MM`). **201 Created**: `{ "requestId": "cb_…", "scheduledFor": "2026-11-16T10:00:00.000Z", "status": "requested" }`. **422** for a bad phone number or time format. The slot is read as UTC today.

### POST /analytics/events (Bearer)

Send events in batches, never on the critical path; the server answers immediately.

```json
{ "events": [ { "name": "screen_view", "properties": { "screen": "home" }, "occurredAt": "2026-11-16T07:38:00Z" } ] }
```

**202 Accepted**: `{ "accepted": 1 }`. At most 100 events per call; events without a `name` are skipped; `properties` over 4 KB are dropped. Kept 180 days.

### POST /referrals/track (public)

Body `{ "partner": "hitech", "utmSource": "autohub_mobile_app", "utmMedium": "flutter_widget", "utmCampaign": "partner_referral" }` (`partner` required). **201 Created**: `{ "referralId": "ref_…" }`.

### GET /app/config (optional auth)

Call at launch; it reads your `X-App-Version` header.

```json
{ "minAppVersion": "1.0.0", "latestAppVersion": "1.0.0", "updateRequired": false, "updateAvailable": false, "maintenance": false, "features": { "socialLogin": true, "junkQuote": true, "chatRealtime": true, "payments": false }, "support": { "email": "support@autohub.express", "phone": null } }
```

`updateRequired: true` → block the app with an update screen. `maintenance: true` → show a maintenance screen. Use `features` to hide screens that aren't live (e.g. hide card payment while `payments` is `false`).

## Known limits and differences from the spec

The API is not deployed to production yet; ask the backend team which host to use for testing.

### Behaviour the app must handle today

| Area | Today | App impact |
| --- | --- | --- |
| Payments | No gateway connected; orders are placed with `paymentStatus: "pending"` and nothing is charged | Don't tell the customer they were charged; check `features.payments` |
| Coupons | None exist; any `couponCode` returns 422 | Hide the coupon field or send `null` |
| Social login | Returns 503 until the Google/Facebook ids are configured on the server | Check `features.socialLogin` and handle 503 |
| Push notifications | Not sent yet (no device-token endpoint) | Rely on the WebSocket and polling |
| Order status / tracking | Moved by staff; there is no staff screen yet, so orders stay `processing` for now | Show the status as returned |
| Return labels | `labelUrl` is `null`; status `requested` | Show "label coming by email" |
| Yard details | `yard.address`, `yard.phone`, `salvageYardPhone` are empty until the business fills them in | Hide empty fields |
| Donor mileage | Always `null` (not recorded at intake) | Hide the row |
| Business numbers | Shipping, tax, warranty text and the junk offer formula are placeholders the business will confirm | Always show what the API returns; never hard-code prices |

### Differences from api-integration-plan.md

| Spec | Implemented | Why |
| --- | --- | --- |
| Base URL `https://api.autohub.express/v1` | `<host>/v1` on the existing AutoHub backend host | Host chosen at deployment |
| `wss://api.autohub.express/ws?token=` | `wss://<host>/ws?token=` (also `/v1/ws`) | Same server |
| — | `POST /auth/reset-password` added | Completes the forgot-password email link |
| — | `GET/DELETE /users/me/vehicles`, `POST /support/attachments` added | List/delete saved vehicles; ticket photos |
| Password rules not stated | 8–128 characters with a letter and a number |  |
| Order number `AH-1042` | Starts at `AH-1` and counts up |  |
| Return response `status: "label_issued"` + `labelUrl` | `status: "requested"`, `labelUrl: null` until staff issue it | No label service connected |
| Card endpoint takes the raw card number | Accepted and checked, but only brand, last 4 and expiry are stored | Switch to a gateway token (`paymentMethodId`) when a gateway is chosen |
| Help categories (shape not given) | `[{ "name", "articleCount" }]` |  |
| Fields not in the spec | Extra fields appear, e.g. `paymentStatus`, `subtotal`/`shipping`/`tax` on orders, `maxQuantity`/`isAvailable` on cart items, `offerAccepted` on junk requests, `meta.vehicle` on fitments, `resultCount` on filter options | Ignore any you don't need |

### Required request rules (quick checklist)

- [ ] Send `Authorization: Bearer <accessToken>` on every Bearer route; refresh once on 401 with a single in-flight refresh.
- [ ] Send `X-Timezone` and `X-App-Version` on every call.
- [ ] Send IDs back exactly as received (with their prefixes).
- [ ] Junk `condition` strings use the en-dash (–).
- [ ] Uploads: `file` for avatar and chat images, `files[]` for vehicle and support photos.
- [ ] Show `error.message` to the customer; highlight `error.details.field` on 422.
- [ ] Log `requestId` with every failed call.
