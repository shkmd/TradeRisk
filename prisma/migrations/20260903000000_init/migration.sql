-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('TRADER', 'ADVISOR', 'ADMIN');

-- CreateEnum
CREATE TYPE "ImportStatus" AS ENUM ('UPLOADED', 'QUEUED', 'PROCESSING', 'NEEDS_MAPPING', 'READY', 'COMMITTED', 'FAILED');

-- CreateEnum
CREATE TYPE "DataQuality" AS ENUM ('COMPLETE', 'LIMITED', 'REJECTED');

-- CreateEnum
CREATE TYPE "CapitalKind" AS ENUM ('STARTING', 'DEPOSIT', 'WITHDRAWAL', 'ADJUSTMENT');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "name" TEXT,
    "email" TEXT NOT NULL,
    "emailVerified" TIMESTAMP(3),
    "image" TEXT,
    "passwordHash" TEXT,
    "role" "Role" NOT NULL DEFAULT 'TRADER',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Account" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "providerAccountId" TEXT NOT NULL,
    "refresh_token" TEXT,
    "access_token" TEXT,
    "expires_at" INTEGER,
    "token_type" TEXT,
    "scope" TEXT,
    "id_token" TEXT,
    "session_state" TEXT,

    CONSTRAINT "Account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Session" (
    "sessionToken" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL
);

-- CreateTable
CREATE TABLE "VerificationToken" (
    "identifier" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL
);

-- CreateTable
CREATE TABLE "UserProfile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "baseCurrency" TEXT NOT NULL DEFAULT 'INR',
    "primaryMarket" TEXT,
    "experienceLevel" TEXT,
    "tradingStyle" TEXT,
    "yearPreference" TEXT NOT NULL DEFAULT 'INDIAN_FINANCIAL_YEAR',
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Broker" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "Broker_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TradingAccount" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "brokerId" TEXT,
    "name" TEXT NOT NULL,
    "maskedAccountId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TradingAccount_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BrokerImportTemplate" (
    "id" TEXT NOT NULL,
    "brokerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "rules" JSONB NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "BrokerImportTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UploadedStatement" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "objectKey" TEXT NOT NULL,
    "originalName" TEXT NOT NULL,
    "contentType" TEXT NOT NULL,
    "sizeBytes" INTEGER NOT NULL,
    "sha256" TEXT NOT NULL,
    "status" "ImportStatus" NOT NULL DEFAULT 'UPLOADED',
    "deleteAfter" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UploadedStatement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ImportJob" (
    "id" TEXT NOT NULL,
    "statementId" TEXT NOT NULL,
    "status" "ImportStatus" NOT NULL DEFAULT 'QUEUED',
    "detectedBroker" TEXT,
    "detectedSheets" JSONB,
    "importedRows" INTEGER NOT NULL DEFAULT 0,
    "rejectedRows" INTEGER NOT NULL DEFAULT 0,
    "duplicateRows" INTEGER NOT NULL DEFAULT 0,
    "brokerReportedNet" DECIMAL(20,4),
    "calculatedNet" DECIMAL(20,4),
    "mapping" JSONB,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ImportJob_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ImportError" (
    "id" TEXT NOT NULL,
    "importJobId" TEXT NOT NULL,
    "sheet" TEXT,
    "rowNumber" INTEGER,
    "code" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "redactedContext" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ImportError_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Strategy" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "Strategy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Trade" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "symbol" TEXT NOT NULL,
    "underlying" TEXT,
    "exchange" TEXT NOT NULL,
    "segment" TEXT NOT NULL,
    "instrumentType" TEXT NOT NULL,
    "optionType" TEXT,
    "strikePrice" DECIMAL(20,4),
    "expiryDate" TIMESTAMP(3),
    "direction" TEXT NOT NULL,
    "quantity" DECIMAL(20,4) NOT NULL,
    "lotSize" DECIMAL(20,4),
    "entryDateTime" TIMESTAMP(3),
    "exitDateTime" TIMESTAMP(3),
    "averageEntryPrice" DECIMAL(20,4),
    "averageExitPrice" DECIMAL(20,4),
    "grossPnl" DECIMAL(20,4) NOT NULL,
    "totalCharges" DECIMAL(20,4) NOT NULL,
    "netPnl" DECIMAL(20,4) NOT NULL,
    "strategyId" TEXT,
    "importSource" TEXT NOT NULL,
    "sourceFingerprint" TEXT NOT NULL,
    "dataQuality" "DataQuality" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Trade_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TradeExecution" (
    "id" TEXT NOT NULL,
    "tradeId" TEXT NOT NULL,
    "executedAt" TIMESTAMP(3) NOT NULL,
    "side" TEXT NOT NULL,
    "quantity" DECIMAL(20,4) NOT NULL,
    "price" DECIMAL(20,4) NOT NULL,
    "orderId" TEXT,
    "brokerTradeId" TEXT,

    CONSTRAINT "TradeExecution_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TradingCharge" (
    "id" TEXT NOT NULL,
    "tradeId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "amount" DECIMAL(20,4) NOT NULL,

    CONSTRAINT "TradingCharge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CapitalTransaction" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "effectiveAt" TIMESTAMP(3) NOT NULL,
    "kind" "CapitalKind" NOT NULL,
    "amount" DECIMAL(20,4) NOT NULL,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CapitalTransaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "JournalEntry" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tradeId" TEXT,
    "setup" TEXT,
    "entryReason" TEXT,
    "exitReason" TEXT,
    "plannedStop" DECIMAL(20,4),
    "plannedTarget" DECIMAL(20,4),
    "plannedRisk" DECIMAL(20,4),
    "actualRisk" DECIMAL(20,4),
    "emotionBefore" TEXT,
    "emotionAfter" TEXT,
    "mistakeCategory" TEXT,
    "lesson" TEXT,
    "ruleStatus" TEXT,
    "confidence" INTEGER,
    "tags" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "JournalEntry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RiskConfiguration" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "maxRiskPerTrade" DECIMAL(20,4),
    "maxDailyLoss" DECIMAL(20,4),
    "maxWeeklyLoss" DECIMAL(20,4),
    "maxMonthlyDrawdownPct" DECIMAL(10,4),
    "maxPortfolioDrawdownPct" DECIMAL(10,4),
    "maxTradesPerDay" INTEGER,
    "maxConsecutiveLosses" INTEGER,
    "coolOffMinutes" INTEGER,
    "weights" JSONB NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RiskConfiguration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RiskAlert" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "severity" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "evidence" JSONB NOT NULL,
    "observedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "acknowledgedAt" TIMESTAMP(3),

    CONSTRAINT "RiskAlert_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PerformanceSnapshot" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "accountId" TEXT,
    "periodStart" TIMESTAMP(3) NOT NULL,
    "periodEnd" TIMESTAMP(3) NOT NULL,
    "filters" JSONB NOT NULL,
    "metrics" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PerformanceSnapshot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Subscription" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "plan" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "providerRef" TEXT,
    "renewsAt" TIMESTAMP(3),

    CONSTRAINT "Subscription_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SharedReport" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "advisorId" TEXT,
    "tokenHash" TEXT NOT NULL,
    "filters" JSONB NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "SharedReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "action" TEXT NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT,
    "ipHash" TEXT,
    "metadataRedacted" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Account_provider_providerAccountId_key" ON "Account"("provider", "providerAccountId");

-- CreateIndex
CREATE UNIQUE INDEX "Session_sessionToken_key" ON "Session"("sessionToken");

-- CreateIndex
CREATE UNIQUE INDEX "VerificationToken_token_key" ON "VerificationToken"("token");

-- CreateIndex
CREATE UNIQUE INDEX "VerificationToken_identifier_token_key" ON "VerificationToken"("identifier", "token");

-- CreateIndex
CREATE UNIQUE INDEX "UserProfile_userId_key" ON "UserProfile"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Broker_slug_key" ON "Broker"("slug");

-- CreateIndex
CREATE INDEX "TradingAccount_userId_idx" ON "TradingAccount"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "BrokerImportTemplate_brokerId_name_version_key" ON "BrokerImportTemplate"("brokerId", "name", "version");

-- CreateIndex
CREATE UNIQUE INDEX "UploadedStatement_objectKey_key" ON "UploadedStatement"("objectKey");

-- CreateIndex
CREATE INDEX "UploadedStatement_userId_createdAt_idx" ON "UploadedStatement"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "UploadedStatement_userId_sha256_key" ON "UploadedStatement"("userId", "sha256");

-- CreateIndex
CREATE UNIQUE INDEX "Strategy_userId_name_key" ON "Strategy"("userId", "name");

-- CreateIndex
CREATE INDEX "Trade_userId_exitDateTime_idx" ON "Trade"("userId", "exitDateTime");

-- CreateIndex
CREATE INDEX "Trade_accountId_symbol_idx" ON "Trade"("accountId", "symbol");

-- CreateIndex
CREATE UNIQUE INDEX "Trade_userId_sourceFingerprint_key" ON "Trade"("userId", "sourceFingerprint");

-- CreateIndex
CREATE INDEX "CapitalTransaction_userId_effectiveAt_idx" ON "CapitalTransaction"("userId", "effectiveAt");

-- CreateIndex
CREATE INDEX "JournalEntry_userId_createdAt_idx" ON "JournalEntry"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "RiskConfiguration_userId_key" ON "RiskConfiguration"("userId");

-- CreateIndex
CREATE INDEX "RiskAlert_userId_observedAt_idx" ON "RiskAlert"("userId", "observedAt");

-- CreateIndex
CREATE INDEX "PerformanceSnapshot_userId_periodEnd_idx" ON "PerformanceSnapshot"("userId", "periodEnd");

-- CreateIndex
CREATE UNIQUE INDEX "Subscription_userId_key" ON "Subscription"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "SharedReport_tokenHash_key" ON "SharedReport"("tokenHash");

-- CreateIndex
CREATE INDEX "AuditLog_userId_createdAt_idx" ON "AuditLog"("userId", "createdAt");

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserProfile" ADD CONSTRAINT "UserProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TradingAccount" ADD CONSTRAINT "TradingAccount_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TradingAccount" ADD CONSTRAINT "TradingAccount_brokerId_fkey" FOREIGN KEY ("brokerId") REFERENCES "Broker"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BrokerImportTemplate" ADD CONSTRAINT "BrokerImportTemplate_brokerId_fkey" FOREIGN KEY ("brokerId") REFERENCES "Broker"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UploadedStatement" ADD CONSTRAINT "UploadedStatement_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UploadedStatement" ADD CONSTRAINT "UploadedStatement_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "TradingAccount"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImportJob" ADD CONSTRAINT "ImportJob_statementId_fkey" FOREIGN KEY ("statementId") REFERENCES "UploadedStatement"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImportError" ADD CONSTRAINT "ImportError_importJobId_fkey" FOREIGN KEY ("importJobId") REFERENCES "ImportJob"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Trade" ADD CONSTRAINT "Trade_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Trade" ADD CONSTRAINT "Trade_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "TradingAccount"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Trade" ADD CONSTRAINT "Trade_strategyId_fkey" FOREIGN KEY ("strategyId") REFERENCES "Strategy"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TradeExecution" ADD CONSTRAINT "TradeExecution_tradeId_fkey" FOREIGN KEY ("tradeId") REFERENCES "Trade"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TradingCharge" ADD CONSTRAINT "TradingCharge_tradeId_fkey" FOREIGN KEY ("tradeId") REFERENCES "Trade"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CapitalTransaction" ADD CONSTRAINT "CapitalTransaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JournalEntry" ADD CONSTRAINT "JournalEntry_tradeId_fkey" FOREIGN KEY ("tradeId") REFERENCES "Trade"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RiskConfiguration" ADD CONSTRAINT "RiskConfiguration_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

