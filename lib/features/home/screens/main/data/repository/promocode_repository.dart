abstract interface class PromoCodeRepository {
  Future<bool> applyPromoCode({required String promocode, required int orderId});
}