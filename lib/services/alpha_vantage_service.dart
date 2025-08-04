import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tx26_data.dart';
import 'alpha_vantage_config.dart';

class AlphaVantageService {
  static const String _baseUrl = 'https://www.alphavantage.co/query';
  
  // Usar configuración centralizada
  static String get _apiKey => AlphaVantageConfig.apiKey;
  
  // Símbolos disponibles en Alpha Vantage (acciones argentinas, NO bonos)
  // IMPORTANTE: TX26, TX24, TX25, etc. NO están disponibles en Alpha Vantage
  static const Map<String, String> _symbolMapping = {
    'GGAL': 'GGAL',     // Grupo Financiero Galicia
    'YPF': 'YPF',       // YPF Sociedad Anonima
    'PAM': 'PAM',       // Pampa Energia SA
    'BBAR': 'BBAR',     // BBVA Argentina
    'TEO': 'TEO',       // Telecom Argentina
    'LOMA': 'LOMA',     // Loma Negra
    'ARGT': 'ARGT',     // Global X MSCI Argentina ETF
    // TX26, TX24, TX25, TX27, AE38, AL29, AL30 NO disponibles
  };

  // Verificar si Alpha Vantage está configurado
  static bool get isConfigured {
    return AlphaVantageConfig.isConfigured;
  }

  // Obtener datos diarios (TIME_SERIES_DAILY)
  static Future<Map<String, dynamic>> getDailyTimeSeries(String symbol) async {
    if (!isConfigured) {
      throw Exception('Alpha Vantage API Key no configurado');
    }

    try {
      final mappedSymbol = _symbolMapping[symbol] ?? symbol;
      print('📊 Obteniendo datos diarios de $mappedSymbol desde Alpha Vantage...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'function': 'TIME_SERIES_DAILY',
        'symbol': mappedSymbol,
        'apikey': _apiKey,
        'outputsize': 'compact', // últimos 100 días
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Verificar si hay error en la respuesta
        if (data.containsKey('Error Message')) {
          throw Exception('Alpha Vantage Error: ${data['Error Message']}');
        }
        
        if (data.containsKey('Note')) {
          throw Exception('Rate limit exceeded: ${data['Note']}');
        }
        
        print('✅ Datos obtenidos exitosamente desde Alpha Vantage');
        return data;
        
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo datos de Alpha Vantage: $e');
      rethrow;
    }
  }

  // Obtener cotización actual (GLOBAL_QUOTE)
  static Future<Map<String, dynamic>> getGlobalQuote(String symbol) async {
    if (!isConfigured) {
      throw Exception('Alpha Vantage API Key no configurado');
    }

    try {
      final mappedSymbol = _symbolMapping[symbol] ?? symbol;
      print('💰 Obteniendo cotización actual de $mappedSymbol...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'function': 'GLOBAL_QUOTE',
        'symbol': mappedSymbol,
        'apikey': _apiKey,
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data.containsKey('Error Message')) {
          throw Exception('Alpha Vantage Error: ${data['Error Message']}');
        }
        
        if (data.containsKey('Note')) {
          throw Exception('Rate limit exceeded: ${data['Note']}');
        }
        
        print('✅ Cotización obtenida exitosamente');
        return data;
        
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo cotización: $e');
      rethrow;
    }
  }

  // Buscar símbolo (SYMBOL_SEARCH)
  static Future<Map<String, dynamic>> searchSymbol(String keywords) async {
    if (!isConfigured) {
      throw Exception('Alpha Vantage API Key no configurado');
    }

    try {
      print('🔍 Buscando símbolo: $keywords...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'function': 'SYMBOL_SEARCH',
        'keywords': keywords,
        'apikey': _apiKey,
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Búsqueda completada');
        return data;
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error en búsqueda: $e');
      rethrow;
    }
  }

  // Método principal para obtener datos de TX26
  static Future<List<TX26Data>> fetchTX26DataFromAlphaVantage() async {
    if (!isConfigured) {
      print('⚠️ Alpha Vantage no configurado - usando datos simulados');
      return _generateFallbackData();
    }

    try {
      print('🚀 Iniciando obtención de datos TX26 desde Alpha Vantage...');
      print('⚠️ IMPORTANTE: TX26 NO está disponible en Alpha Vantage');
      print('📊 Alpha Vantage solo tiene acciones argentinas (GGAL, YPF, PAM, etc.)');
      print('🔄 Usando datos simulados realistas para TX26...');
      
      // TX26 específicamente NO está disponible en Alpha Vantage
      // Aunque tengamos API Key, este símbolo no existe en su base de datos
      return _generateFallbackData();
      
    } catch (e) {
      print('❌ Error en fetchTX26DataFromAlphaVantage: $e');
      return _generateFallbackData();
    }
  }

  // Método para obtener datos REALES de acciones argentinas disponibles
  static Future<Map<String, dynamic>?> fetchRealArgentineStock(String symbol) async {
    if (!isConfigured) {
      print('⚠️ Alpha Vantage no configurado');
      return null;
    }

    try {
      final mappedSymbol = _symbolMapping[symbol];
      if (mappedSymbol == null) {
        print('❌ Símbolo $symbol no disponible en Alpha Vantage');
        return null;
      }

      print('📊 Obteniendo datos REALES de $mappedSymbol desde Alpha Vantage...');
      
      final dailyData = await getDailyTimeSeries(mappedSymbol);
      final quote = await getGlobalQuote(mappedSymbol);
      
      print('✅ Datos reales obtenidos de $mappedSymbol');
      return {
        'symbol': mappedSymbol,
        'daily_data': dailyData,
        'quote': quote,
      };
      
    } catch (e) {
      print('❌ Error obteniendo datos reales de $symbol: $e');
      return null;
    }
  }

  // Datos simulados como fallback
  static List<TX26Data> _generateFallbackData() {
    print('⚠️ Usando datos simulados como fallback para Alpha Vantage...');
    
    final List<TX26Data> dataList = [];
    final now = DateTime.now();
    double basePrice = 1489.75;

    // Generar 30 días de datos para simular lo que Alpha Vantage retornaría
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Variación diaria realista para bonos
      final volatility = 0.012; // 1.2% volatilidad
      final weekendFactor = date.weekday >= 6 ? 0.3 : 1.0; // Menos volatilidad en fines de semana
      final variation = (0.5 - (i % 7) / 7.0) * volatility * weekendFactor;

      final dayPrice = basePrice * (1 + variation);

      // Precios intradiarios
      final spread = dayPrice * 0.0025; // 0.25% spread
      final apertura = dayPrice - spread * 0.3;
      final cierre = dayPrice;
      final maximo = dayPrice + spread * 0.7;
      final minimo = dayPrice - spread * 0.5;

      // Volumen realista
      final baseVolume = 200000.0;
      final volumeVariation = (0.5 - (i % 5) / 5.0) * 0.4;
      final volumen = baseVolume * (1 + volumeVariation);

      // Tipo de cambio USD/ARS
      const usdRate = 1160.0;

      // Calcular variación
      double variacionDiaria = 0.0;
      if (dataList.isNotEmpty) {
        variacionDiaria = cierre - dataList.last.cierre;
      }

      final data = TX26Data(
        especie: 'TX26',
        precioActual: cierre,
        variacion: variacionDiaria,
        fecha: dateStr,
        apertura: apertura,
        maximo: maximo,
        minimo: minimo,
        cierre: cierre,
        volumen: volumen,
        usdApertura: apertura / usdRate,
        usdMaximo: maximo / usdRate,
        usdMinimo: minimo / usdRate,
        usdCierre: cierre / usdRate,
      );

      dataList.add(data);
      basePrice = dayPrice;
    }

    // Ordenar por fecha (más reciente primero)
    dataList.sort((a, b) => b.fecha.compareTo(a.fecha));

    print('✅ Generados ${dataList.length} registros simulados para Alpha Vantage');
    return dataList;
  }

  // Obtener información de la API (cuota restante, etc.)
  static Future<Map<String, dynamic>> getApiStatus() async {
    try {
      // Alpha Vantage no tiene endpoint específico para status,
      // pero podemos hacer una consulta simple para verificar
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'function': 'GLOBAL_QUOTE',
        'symbol': 'AAPL', // Símbolo de prueba
        'apikey': _apiKey,
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data.containsKey('Note')) {
          return {
            'status': 'rate_limited',
            'message': data['Note'],
            'configured': isConfigured,
          };
        }
        
        return {
          'status': 'ok',
          'message': 'API funcionando correctamente',
          'configured': isConfigured,
        };
      }
      
      return {
        'status': 'error',
        'message': 'Error HTTP ${response.statusCode}',
        'configured': isConfigured,
      };
      
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
        'configured': isConfigured,
      };
    }
  }
}
