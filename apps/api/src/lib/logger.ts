type LogContext = Record<string, unknown>;

function write(level: 'info' | 'error', message: string, context: LogContext = {}): void {
  process.stdout.write(
    `${JSON.stringify({ level, message, timestamp: new Date().toISOString(), ...context })}\n`,
  );
}

export const logger = {
  info: (message: string, context?: LogContext): void => write('info', message, context),
  error: (message: string, context?: LogContext): void => write('error', message, context),
};
