# TradeRisk Analytics SaaS

Production-oriented public SaaS built with Next.js, Auth.js, PostgreSQL/Prisma, Redis/BullMQ, and private S3-compatible storage.

## Local setup

1. Copy `.env.example` to `.env` and set secure values.
2. Start PostgreSQL, Redis, and a private S3-compatible bucket.
3. Run `pnpm install`, `pnpm db:generate`, `pnpm db:migrate`, then `pnpm dev`.
4. Run the import worker separately with `pnpm worker`.

Deploy the Docker image twice: web (`node server.js`) and worker (`pnpm worker`). Attach managed PostgreSQL, Redis, and private object storage. Run `pnpm db:migrate` before web rollout. Configure Google OAuth callback as `/api/auth/callback/google`.

Security defaults include Argon2id passwords, HTTP-only secure cookies, direct-to-private-storage uploads, short-lived signed URLs, tenant-scoped queries, audit events, file size/type validation, content hashes for duplicate prevention, CSP/security headers, and redacted import failures. Add an antivirus scanning service before enabling uploads for untrusted public traffic.

PDF ingestion is accepted at the upload boundary but must be routed to a sandboxed extraction and antivirus service; the included workbook worker processes CSV, XLS, and XLSX.

