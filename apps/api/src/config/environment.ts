const validNodeEnvironments = ['development', 'test', 'production'] as const;
type NodeEnvironment = (typeof validNodeEnvironments)[number];

function nodeEnvironment(value: string | undefined): NodeEnvironment {
  return validNodeEnvironments.includes(value as NodeEnvironment)
    ? (value as NodeEnvironment)
    : 'development';
}

function positiveInteger(value: string | undefined, fallback: number, maximum?: number): number {
  const parsed = Number(value ?? fallback);
  return Number.isInteger(parsed) && parsed > 0 && (!maximum || parsed <= maximum)
    ? parsed
    : fallback;
}

export const environment = Object.freeze({
  nodeEnv: nodeEnvironment(process.env.NODE_ENV),
  port: positiveInteger(process.env.PORT, 3000, 65535),
  databaseUrl: process.env.DATABASE_URL,
  redisUrl: process.env.REDIS_URL,
  authJwtSecret: process.env.AUTH_JWT_SECRET,
  authTokenTtlMinutes: positiveInteger(process.env.AUTH_TOKEN_TTL_MINUTES, 15),
});
