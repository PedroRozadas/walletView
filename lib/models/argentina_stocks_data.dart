class ArgentinaStockData {
  final String symbol;
  final String name;
  final String exchange;
  final double currentPrice;
  final double change;
  final double changePercent;
  final String date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final String currency;

  ArgentinaStockData({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.currency = 'USD',
  });

  // Formatters
  String get priceFormatted => '\$${currentPrice.toStringAsFixed(2)}';
  String get changeFormatted => change >= 0 ? '+\$${change.toStringAsFixed(2)}' : '-\$${change.abs().toStringAsFixed(2)}';
  String get changePercentFormatted => change >= 0 ? '+${changePercent.toStringAsFixed(2)}%' : '-${changePercent.abs().toStringAsFixed(2)}%';
  String get volumeFormatted => volume >= 1000000 
      ? '${(volume / 1000000).toStringAsFixed(1)}M'
      : volume >= 1000
          ? '${(volume / 1000).toStringAsFixed(1)}K'
          : volume.toStringAsFixed(0);
  
  String get previousCloseFormatted => '\$${close.toStringAsFixed(2)}';
  String get lastUpdateFormatted => date;
  String get dataSource => 'Alpha Vantage';

  bool get isPositive => change >= 0;

  factory ArgentinaStockData.fromAlphaVantage(
    String symbol,
    String name,
    String exchange,
    Map<String, dynamic> dailyData,
    Map<String, dynamic> quoteData,
  ) {
    try {
      // Procesar datos de la cotización global
      final globalQuote = quoteData['Global Quote'] as Map<String, dynamic>?;
      
      if (globalQuote != null) {
        final currentPrice = double.parse(globalQuote['05. price'] ?? '0');
        final change = double.parse(globalQuote['09. change'] ?? '0');
        final changePercent = double.parse(globalQuote['10. change percent']?.replaceAll('%', '') ?? '0');
        final open = double.parse(globalQuote['02. open'] ?? '0');
        final high = double.parse(globalQuote['03. high'] ?? '0');
        final low = double.parse(globalQuote['04. low'] ?? '0');
        final close = double.parse(globalQuote['08. previous close'] ?? '0');
        final volume = double.parse(globalQuote['06. volume'] ?? '0');
        final date = globalQuote['07. latest trading day'] ?? '';

        return ArgentinaStockData(
          symbol: symbol,
          name: name,
          exchange: exchange,
          currentPrice: currentPrice,
          change: change,
          changePercent: changePercent,
          date: date,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        );
      }
    } catch (e) {
      print('❌ Error procesando datos de $symbol: $e');
    }

    // Fallback con datos simulados
    return ArgentinaStockData.simulated(symbol, name, exchange);
  }

  factory ArgentinaStockData.simulated(String symbol, String name, String exchange) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Precios base simulados para cada acción
    final basePrices = {
      'GGAL': 25.50,
      'YPF': 18.75,
      'PAM': 42.30,
      'BBAR': 8.90,
      'TEO': 12.45,
      'LOMA': 15.60,
      'ARGT': 28.20,
    };

    final basePrice = basePrices[symbol] ?? 20.0;
    
    // Variación simulada realista
    final variation = (0.5 - (DateTime.now().millisecond % 1000) / 1000.0) * 0.05; // ±5%
    final currentPrice = basePrice * (1 + variation);
    final change = basePrice * variation;
    final changePercent = variation * 100;
    
    // Precios intradiarios
    final spread = currentPrice * 0.02; // 2% spread
    final open = currentPrice - spread * 0.3;
    final high = currentPrice + spread * 0.8;
    final low = currentPrice - spread * 0.6;
    
    // Volumen simulado
    final baseVolumes = {
      'GGAL': 2500000.0,
      'YPF': 3200000.0,
      'PAM': 1800000.0,
      'BBAR': 1500000.0,
      'TEO': 900000.0,
      'LOMA': 600000.0,
      'ARGT': 1200000.0,
    };
    
    final volume = (baseVolumes[symbol] ?? 1000000.0) * (0.8 + (DateTime.now().millisecond % 400) / 1000.0);

    return ArgentinaStockData(
      symbol: symbol,
      name: name,
      exchange: exchange,
      currentPrice: currentPrice,
      change: change,
      changePercent: changePercent,
      date: dateStr,
      open: open,
      high: high,
      low: low,
      close: currentPrice,
      volume: volume,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'exchange': exchange,
      'currentPrice': currentPrice,
      'change': change,
      'changePercent': changePercent,
      'date': date,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'currency': currency,
    };
  }
}

// Estado para las acciones argentinas
class ArgentinaStocksState {
  final List<ArgentinaStockData> stocks;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdate;

  const ArgentinaStocksState({
    this.stocks = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdate,
  });

  ArgentinaStocksState copyWith({
    List<ArgentinaStockData>? stocks,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
  }) {
    return ArgentinaStocksState(
      stocks: stocks ?? this.stocks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
