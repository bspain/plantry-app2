# Plantry App 2

A cross-device grocery planning and shopping Progressive Web App (PWA) for a single household.

## What is this?

Plantry App 2 lets household members collaboratively plan weekly meals and manage a shared grocery list from any device. Planning happens on a laptop; shopping happens on a phone. Changes made by one person appear instantly on every other connected device via Azure Web PubSub.

Key capabilities:

- **Weekly meal planning** – create, edit, and duplicate weekly meal plans
- **Shared grocery list** – add items, toggle completion, filter by status
- **Real-time collaboration** – changes propagate instantly to all connected clients
- **Offline support** – full PWA with service worker caching and a local mutation queue that syncs when connectivity returns
- **Up to 36 weeks of history** – view and reuse past weeks

## Technology overview

| Layer | Technology |
|---|---|
| Frontend | React 18 + Vite (PWA), TanStack Query, Zustand, Tailwind CSS, shadcn/ui |
| Authentication | Microsoft Entra ID – personal accounts (MSAL.js) |
| API | Azure Functions v4 (Node.js 20 / TypeScript) |
| Database | Azure Cosmos DB (NoSQL, serverless) |
| Real-time | Azure Web PubSub |
| Hosting | Azure Static Web Apps + standalone Functions App |
| IaC / CI/CD | Bicep + GitHub Actions |

For full requirements and architectural decisions, please read:

- [`docs/requirements.md`](docs/requirements.md) – functional and non-functional requirements
- [`docs/architecture.md`](docs/architecture.md) – component design, data model, and flow diagrams
- [`docs/plan.md`](docs/plan.md) – phased delivery plan and current progress

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to set up a local development environment and the process for submitting changes.

## License

Private repository – all rights reserved.
