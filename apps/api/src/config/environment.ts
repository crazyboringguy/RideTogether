const validNodeEnvironments = ['development', 'test', 'production'] as const;
type NodeEnvironment = (typeof validNodeEnvironments)[number];

function nodeEnvironment(value: string | undefined): NodeEnvironment {
  return validNodeEnvironments.includes(value as NodeEnvironment)
    ? (value as NodeEnvironment)
    : 'development';
}

function port(value: string | undefined): number {
  const parsed = Number(value ?? 3000);
  return Number.isInteger(parsed) && parsed > 0 && parsed <= 65535 ? parsed : 3000;
}

export const environment = Object.freeze({
  nodeEnv: nodeEnvironment(process.env.NODE_ENV),
  port: port(process.env.PORT),
  databaseUrl: process.env.DATABASE_URL,
  redisUrl: process.env.REDIS_URL,
});
