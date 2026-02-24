sealed class AcceptOrderEffect {
  const AcceptOrderEffect();
}

class AcceptOpenSmsDialog extends AcceptOrderEffect {
  final int orderId;
  final double amount;
  const AcceptOpenSmsDialog({required this.orderId, required this.amount});
}

class AcceptCloseDialog extends AcceptOrderEffect {
  const AcceptCloseDialog();
}

class AcceptShowError extends AcceptOrderEffect {
  final String message;
  const AcceptShowError(this.message);
}