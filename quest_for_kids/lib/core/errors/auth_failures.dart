abstract class Failure {
  final String message;
  const Failure(this.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// Specific failures can be added here
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
