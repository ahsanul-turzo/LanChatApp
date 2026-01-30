abstract class Either<L, R> {
  const Either();

  bool isLeft() => this is Left<L, R>;
  bool isRight() => this is Right<L, R>;

  L? getLeft() => isLeft() ? (this as Left<L, R>).value : null;
  R? getRight() => isRight() ? (this as Right<L, R>).value : null;

  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    if (isLeft()) {
      return leftFn((this as Left<L, R>).value);
    } else {
      return rightFn((this as Right<L, R>).value);
    }
  }
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}
