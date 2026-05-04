# Plantry App 2 – Development Plan

## Phase 0 – Repository Foundations

- [x] Review `docs/requirements.md` and `docs/architecture.md` to understand the application scope
- [x] Create `README.md` with an overview of the repository and pointers to detailed documentation
- [x] Create `CONTRIBUTING.md` with local development setup, workflow guidance, and PR instructions
- [x] Create `docs/plan.md` with checkbox-based phased plan

## Phase 1 – Project Scaffolding

- [ ] Initialize the React PWA (Vite + TypeScript)
- [ ] Set up Azure Functions project (Node.js / TypeScript)
- [ ] Configure MSAL authentication in the PWA
- [ ] Add ESLint, Prettier, and basic CI workflow

## Phase 2 – Core Backend

- [ ] Provision Cosmos DB collections (`Users`, `Households`, `Weeks`, `Meals`, `GroceryItems`)
- [ ] Implement `GET /weeks` and `POST /weeks` endpoints
- [ ] Implement `POST /weeks/{id}/duplicate`
- [ ] Implement meal endpoints (`POST`, `PATCH`, `DELETE /meals/{id}`)
- [ ] Implement grocery item endpoints (`POST`, `PATCH`, `DELETE /items/{id}`)
- [ ] Add Microsoft identity token validation middleware
- [ ] Add retention job (scheduled Function, keep latest 36 weeks)

## Phase 3 – Core Frontend

- [ ] Weekly plan view (two-pane layout for laptop)
- [ ] Grocery list view with filters (All / Remaining / Completed)
- [ ] Mobile-optimised view with large tap targets
- [ ] Optimistic UI updates

## Phase 4 – Real-time & Offline

- [ ] Integrate Azure Web PubSub (subscribe to week channel on load)
- [ ] Apply PubSub events to local state
- [ ] Service worker – cache app shell and current/recent weeks
- [ ] Local mutation queue – flush on reconnect

## Phase 5 – Polish & Launch

- [ ] End-to-end testing (happy-path sign-in, add item, real-time update)
- [ ] Accessibility pass (keyboard navigation, screen reader labels)
- [ ] Performance audit (Lighthouse PWA score)
- [ ] Production deployment to Azure Static Web Apps + Azure Functions
