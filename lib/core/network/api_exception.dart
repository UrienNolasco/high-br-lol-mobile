sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException() : super('Sem conexao com a internet.');
}

class TimeoutException extends ApiException {
  const TimeoutException() : super('A requisicao demorou demais.');
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Recurso nao encontrado.']);
}

class RateLimitedException extends ApiException {
  const RateLimitedException()
      : super('Muitas buscas. Tente novamente em alguns segundos.');
}

class ServerException extends ApiException {
  const ServerException() : super('Erro no servidor. Tente novamente.');
}

class UnknownApiException extends ApiException {
  const UnknownApiException([super.message = 'Erro desconhecido.']);
}
