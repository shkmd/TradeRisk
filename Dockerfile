FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile

FROM node:22-alpine AS build
WORKDIR /app
ENV DATABASE_URL=postgresql://build:build@localhost:5432/build
ENV AUTH_SECRET=build-only-secret-not-used-at-runtime-00000000000000000000
ENV NEXT_PUBLIC_APP_URL=https://web-app-production-ed6a.up.railway.app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN corepack enable && pnpm build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system app && adduser --system --ingroup app app
COPY --from=build --chown=app:app /app/node_modules ./node_modules
COPY --from=build --chown=app:app /app/.next/standalone ./
COPY --from=build --chown=app:app /app/.next/static ./.next/static
COPY --from=build --chown=app:app /app/src ./src
COPY --from=build --chown=app:app /app/prisma ./prisma
COPY --from=build --chown=app:app /app/prisma.config.ts ./prisma.config.ts
COPY --from=build --chown=app:app /app/tsconfig.json ./tsconfig.json
USER app
EXPOSE 3000
CMD ["sh","-c","if [ \"$SERVICE_MODE\" = \"worker\" ]; then node node_modules/tsx/dist/cli.mjs src/worker.ts; else node node_modules/prisma/build/index.js migrate deploy && node server.js; fi"]
