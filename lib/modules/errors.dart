class AccountUpdateFailedError implements Error {
  final String message;

  AccountUpdateFailedError(this.message);

  @override
  String toString() => "Account Update Failed: $message\n$stackTrace";

  @override
  StackTrace? get stackTrace => null;
}
