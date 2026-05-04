# Architecture Blueprint

## 1. High‑level architecture

```
PWA (React + MSAL)
   |
   | 1. Auth via Microsoft identity
   |
Azure AD / Entra ID
   |
   | 2. Authenticated API calls
   |
Azure Functions (API Layer)
   |
   | 3. Writes authoritative data
   |
Azure Cosmos DB
   |
   | 4. Publishes real-time events
   |
Azure Web PubSub
   |
   | 5. Clients receive updates instantly
   |
PWA (React)
```

## 2. Client architecture
### 2.1. Authentication
- MSAL handles login and token acquisition.
- Access tokens included in API calls.

### 2.2. Data flow
- On load:
  - Fetch current week from API.
  - Subscribe to PubSub channel for that week.
- On user action:
  - Apply optimistic UI update.
  - Send mutation to backend.
- On PubSub event:
  - Patch local state with authoritative change.

### 2.3. Offline behavior
- Service worker caches:
  - App shell
  - Current week
  - Recent weeks
- Local queue stores:
  - Add item
  - Edit item
  - Toggle completion
- On reconnect:
  - Queue flushes to backend
  - PubSub reconnects
  - Client receives missed events

## 3. Backend architecture
### 3.1. Azure Functions

Endpoints:
- `GET /weeks`
- `POST /weeks`
- `POST /weeks/{id}/duplicate`
- `GET /weeks/{id}`
- `POST /weeks/{id}/meals`
- `PATCH /meals/{id}`
- `DELETE /meals/{id}`
- `POST /weeks/{id}/items`
- `PATCH /items/{id}`
- `DELETE /items/{id}`

All endpoints:
- Validate Microsoft identity token
- Validate household membership
- Write to Cosmos DB
- Publish PubSub event (best‑effort)

### 3.2. Cosmos DB

Collections:
- `Users`
- `Households`
- `Weeks`
- `Meals`
- `GroceryItems`

Cosmos DB is the **source of truth.**

### 3.3. Azure Web PubSub
- One group/channel per week.
- Backend publishes events like:
  - `itemAdded`
  - `itemUpdated`
  - `itemDeleted`
  - `mealAdded`
  - `mealUpdated`
  - `mealDeleted`
- Clients subscribe to the current week’s group.

### 3.4. PubSub failure handling
Best‑effort publish
- If DB write succeeds but PubSub publish fails:
  - No retry required
  - Data remains correct
  - Clients reconcile on reconnect or refresh

This keeps the system simple and robust.

### 3.5. Retention job
- Scheduled Azure Function runs weekly.
- Keeps only the most recent 36 weeks.
- Deletes or archives older weeks and related items.

4. Data model

Week:
- `id`
- `householdId`
- `label`
- `startDate`
- `createdAt`
- `archived`

Meal:
- `id`
- `weekId`
- `text`
- `order`

GroceryItem:
- `id`
- `weekId`
- `text`
- `completed`
- `createdAt`
- `updatedAt`

## 5. UX considerations
- Laptop view: two‑pane (meals + grocery list)
- Mobile view: focused grocery list with large tap targets, meals available in a collapsable section
- Real‑time updates make the shared shopping experience feel seamless
- Offline mode remains intuitive and conflict‑free