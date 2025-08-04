import '../models/argentina_stocks_data.dart';
import 'alpha_vantage_service.dart';
import 'alpha_vantage_config.dart';

class ArgentinaStocksService {
  // Configuración de acciones argentinas disponibles
  static const Map<String, Map<String, String>> _argentinaStocks = {
    'GGAL': {
      'name': 'Grupo Financiero Galicia',
      'exchange': 'NASDAQ',
      'sector': 'Financiero',
      'description': 'Holding financiero líder en Argentina',
    },
    'YPF': {
      'name': 'YPF Sociedad Anonima',
      'exchange': 'NYSE',
      'sector': 'Energía',
      'description': 'Compañía petrolera integrada',
    },
    'PAM': {
      'name': 'Pampa Energia SA',
      'exchange': 'NYSE',
      'sector': 'Energía',
      'description': 'Generadora de energía eléctrica',
    },
    'BBAR': {
      'name': 'BBVA Argentina',
      'exchange': 'NYSE',
      'sector': 'Financiero',
      'description': 'Banco comercial',
    },
    'TEO': {
      'name': 'Telecom Argentina S.A.',
      'exchange': 'NYSE',
      'sector': 'Telecomunicaciones',
      'description': 'Servicios de telecomunicaciones',
    },
    'LOMA': {
      'name': 'Loma Negra Compania Industrial Argentina',
      'exchange': 'NYSE',
      'sector': 'Materiales',
      'description': 'Fabricante de cemento',
    },
    'ARGT': {
      'name': 'Global X MSCI Argentina ETF',
      'exchange': 'NYSE ARCA',
      'sector': 'ETF',
      'description': 'ETF que replica el mercado argentino',
    },
  };

  // Obtener todas las acciones argentinas
  static Future<List<ArgentinaStockData>> fetchAllArgentinaStocks() async {
    print('🇦🇷 Iniciando obtención de acciones argentinas...');
    
    final List<ArgentinaStockData> stocksList = [];
    
    for (final symbol in _argentinaStocks.keys) {
      try {
        final stockData = await fetchSingleStock(symbol);
        if (stockData != null) {
          stocksList.add(stockData);
        }
      } catch (e) {
        print('❌ Error obteniendo $symbol: $e');
        // Agregar datos simulados como fallback
        final stockInfo = _argentinaStocks[symbol]!;
        stocksList.add(ArgentinaStockData.simulated(
          symbol,
          stockInfo['name']!,
          stockInfo['exchange']!,
        ));
      }
    }

    // Ordenar por símbolo
    stocksList.sort((a, b) => a.symbol.compareTo(b.symbol));
    
    print('✅ Obtenidas ${stocksList.length} acciones argentinas');
    return stocksList;
  }

  // Obtener una acción específica
  static Future<ArgentinaStockData?> fetchSingleStock(String symbol) async {
    if (!_argentinaStocks.containsKey(symbol)) {
      print('❌ Símbolo $symbol no disponible');
      return null;
    }

    final stockInfo = _argentinaStocks[symbol]!;
    
    if (AlphaVantageConfig.isConfigured) {
      try {
        print('📊 Obteniendo datos reales de $symbol desde Alpha Vantage...');
        
        // Obtener datos de Alpha Vantage
        final dailyData = await AlphaVantageService.getDailyTimeSeries(symbol);
        final quoteData = await AlphaVantageService.getGlobalQuote(symbol);
        
        final stockData = ArgentinaStockData.fromAlphaVantage(
          symbol,
          stockInfo['name']!,
          stockInfo['exchange']!,
          dailyData,
          quoteData,
        );
        
        print('✅ Datos reales obtenidos para $symbol: ${stockData.priceFormatted}');
        return stockData;
        
      } catch (e) {
        print('❌ Error obteniendo datos reales de $symbol: $e');
        // Fallback a datos simulados
      }
    } else {
      print('⚠️ Alpha Vantage no configurado para $symbol');
    }

    // Usar datos simulados
    print('🔄 Usando datos simulados para $symbol');
    return ArgentinaStockData.simulated(
      symbol,
      stockInfo['name']!,
      stockInfo['exchange']!,
    );
  }

  // Obtener información de la acción
  static Map<String, String>? getStockInfo(String symbol) {
    return _argentinaStocks[symbol];
  }

  // Obtener todas las acciones disponibles
  static List<String> getAvailableSymbols() {
    return _argentinaStocks.keys.toList();
  }

  // Obtener acciones por sector
  static List<String> getStocksBySector(String sector) {
    return _argentinaStocks.entries
        .where((entry) => entry.value['sector'] == sector)
        .map((entry) => entry.key)
        .toList();
  }

  // Obtener sectores disponibles
  static List<String> getAvailableSectors() {
    return _argentinaStocks.values
        .map((info) => info['sector']!)
        .toSet()
        .toList()
        ..sort();
  }

  // Verificar estado del servicio
  static Map<String, dynamic> getServiceStatus() {
    return {
      'alpha_vantage_configured': AlphaVantageConfig.isConfigured,
      'available_stocks': _argentinaStocks.length,
      'data_source': AlphaVantageConfig.isConfigured ? 'Alpha Vantage API' : 'Datos simulados',
      'supported_symbols': _argentinaStocks.keys.toList(),
      'sectors': getAvailableSectors(),
    };
  }

  // Obtener resumen del mercado
  static Future<Map<String, dynamic>> getMarketSummary() async {
    final stocks = await fetchAllArgentinaStocks();
    
    if (stocks.isEmpty) {
      return {'error': 'No hay datos disponibles'};
    }

    final positive = stocks.where((s) => s.change > 0).length;
    final negative = stocks.where((s) => s.change < 0).length;
    final unchanged = stocks.where((s) => s.change == 0).length;

    final avgChange = stocks.fold<double>(0, (sum, stock) => sum + stock.changePercent) / stocks.length;
    final totalVolume = stocks.fold<double>(0, (sum, stock) => sum + stock.volume);

    return {
      'total_stocks': stocks.length,
      'positive': positive,
      'negative': negative,
      'unchanged': unchanged,
      'market_sentiment': positive > negative ? 'Positivo' : negative > positive ? 'Negativo' : 'Neutral',
      'avg_change_percent': avgChange,
      'total_volume': totalVolume,
      'data_source': AlphaVantageConfig.isConfigured ? 'Alpha Vantage' : 'Simulado',
      'last_update': DateTime.now().toIso8601String(),
    };
  }
}
