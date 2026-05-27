# ThreeFold Connect

ThreeFold Connect is a mobile and web application providing user identity, digital wallet, and grid interaction capabilities.

## What this is

ThreeFold Connect serves as an end-user interface for identity verification, token management, and workload deployment. It integrates with authentication and billing systems to provide a unified experience for users interacting with decentralized infrastructure.

The application includes:
- **Identity management** — user registration, verification, and secure identity handling
- **Digital wallet** — token storage, transfers, and transaction history
- **Grid interaction** — workload deployment and management interfaces
- **Two-factor authentication** — secure login mechanisms

## What this repository contains

- `app/` — Flutter mobile application (iOS, Android, macOS)
- `frontend/` — Web frontend components
- `backend/` — Python backend services with database models, API endpoints, and key management
- `threefoldloginexample/` — Example integration for ThreeFold login
- `nginx.conf` — Reverse proxy configuration
- `helm_files/` — Kubernetes deployment manifests
- `Dockerfile` — Container build definition

## Role in the stack

ThreeFold Connect sits at the user-facing layer of the stack. It communicates with backend services for identity and wallet operations, and with grid orchestration services for workload management. It relies on authentication services for secure user sessions and on blockchain integrations for token operations.

## Relation to ThreeFold

This technology is used within the ThreeFold ecosystem and was first deployed on the ThreeFold Grid. The component itself is designed as reusable infrastructure technology and should be understood by its technical function first, independent of any specific deployment.

## Ownership

This repository is owned and maintained by TF-Tech NV, a Belgian company responsible for the development and maintenance of this technology.

## Local Development

- See [frontend/README.md](frontend/README.md)
- See [backend/README.md](backend/README.md)
- See [app/README.md](app/README.md)

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.
