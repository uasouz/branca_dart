
class VersionException implements Exception {
  String cause;
  VersionException() {
    this.cause = "Invalid token version.";
  }
}

class InvalidLengthException implements Exception {
  String cause;
  InvalidLengthException() {
    this.cause = "Length is less than 62.";
  }
}


class TokenExpiredException implements Exception {
  String cause;
  TokenExpiredException() {
    this.cause = "Token is Expired";
  }
}