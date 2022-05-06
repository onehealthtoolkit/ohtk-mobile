class ValidationState {
  final bool valid;
  final String message;
  ValidationState(this.valid, this.message);
}

typedef ValidationCallbackFuncion = ValidationState Function();
typedef UnRegisterValidationCallback = void Function();
