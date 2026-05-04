# Requirements Document

## 1. Problem statement

Build a cross‑device grocery planning and shopping application for a single household using:
- Windows 11 laptops for planning
- Samsung Galaxy phones for shopping
- Microsoft identity for authentication
- Azure Web PubSub for real‑time collaboration
- Azure Cosmos DB as the authoritative data store

The app supports weekly meal planning, grocery list creation, real‑time updates, offline usage, and up to 36 weeks of history.

## 2. User roles

### 2.1. User
- Authenticated via Microsoft identity (MSAL).
- Member of a single household.
- Can plan meals, create grocery items, and check items off while shopping.

### 2.2. Household
- Logical grouping of users.
- Supports multiple users, but only one household is needed for this app.

## 3. Core use cases

### 3.1. Sign in
- User signs in using Microsoft identity.
- After sign‑in, user sees the current week’s plan and list.

### 3.2. Create a weekly plan
- Create a new week (auto‑labeled “Week of YYYY‑MM‑DD”).
- Add/edit/delete meal entries (simple text).

### 3.3. Manage grocery list
- Add/edit/delete grocery items.
- Each item is a single freeform text field.
- Toggle completion state.

### 3.4. Real‑time collaboration (PubSub)
- When one user adds or checks an item:
  - Backend writes to Cosmos DB.
  - Backend publishes a PubSub event to the week’s channel.
  - All connected clients update instantly.

### 3.5. Shopping on phones
- Large tap targets.
- Filters:
  - All
  - Remaining
  - Completed
- Real‑time updates from the other user.

### 3.6. Offline usage
- App loads from service worker cache.
- User can:
  - View current and recent weeks
  - Add/edit items
  - Toggle completion
- Changes queue locally and sync when online.
- PubSub reconnects automatically when connectivity returns.

### 3.7. History & reuse
- Up to 36 weeks of history retained.
- User can view past weeks.
- User can duplicate a past week to create a new one:
  - Meals copied as‑is
  - Grocery items copied with completed = false

### 3.8. Optional future: notifications
- Non‑critical push notifications for item changes.
- Not required for v1.

## 4. Functional requirements

### 4.1. Authentication
- Microsoft identity only.
- MSAL used in the PWA.
- Backend validates tokens on every request.

### 4.2. Weekly structure
- Week entity with:
  - Label
  - Start date
  - Created timestamp
- Meals and grocery items linked by weekId.

### 4.3. Grocery items
- Fields:
  - `id`
  - `weekId`
  - `text`
  - `completed`
  - `createdAt`
  - `updatedAt`

### 4.4. Real‑time updates
- Each week corresponds to a PubSub group/channel.
- Clients subscribe to the current week’s channel.
- Backend publishes events after successful DB writes.
- Best‑effort publish:
  - If publish fails, no retry is required.
  - Data remains correct in Cosmos DB.
  - Clients eventually reconcile via reconnect or refresh.

### 4.5. Retention
- Only the most recent 36 weeks are kept.
- Older weeks are deleted or archived by a scheduled backend job.

## 5. Non‑functional requirements
- Platform: PWA on Edge (Windows) and Chrome/Samsung Internet (Android)
- Performance: Fast load, instant UI updates
- Offline: Service worker caching + local mutation queue
- Security: HTTPS, secure token handling, least‑privilege access
- Scalability: Azure Functions + Cosmos DB + Web PubSub
- Maintainability: Clean separation of UI, state, sync, and backend logic
