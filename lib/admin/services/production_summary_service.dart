class ProductionSummaryService {
  ProductionSummaryService._();

  static final ProductionSummaryService instance = ProductionSummaryService._();

  final int _ordenesActivas = 12;
  final int _ordenesCompletadas = 45;

  int get ordenesActivas => _ordenesActivas;
  int get ordenesCompletadas => _ordenesCompletadas;
}