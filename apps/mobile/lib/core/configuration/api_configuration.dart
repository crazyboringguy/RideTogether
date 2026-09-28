abstract final class ApiConfiguration {
  // Override with --dart-define=API_BASE_URL=http://host:3000 for local targets.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
}
