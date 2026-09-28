export class AppError extends Error {
  constructor(
    readonly statusCode: number,
    message: string,
    readonly details?: string[],
  ) {
    super(message);
    this.name = 'AppError';
  }
}
