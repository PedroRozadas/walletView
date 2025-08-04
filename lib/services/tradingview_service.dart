import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tx26_data.dart';
import '../config/tradingview_config.dart';

class TradingViewService {
  // Obtener cotizaciones en tiempo real
  static Future<Map<String, dynamic>> getQuotes(String symbol) async {
    if (!TradingViewConfig.isConfigured) {
      throw Exception('TradingView no está configurado. Ver config/tradingview_config.dart');
    }
    
    try {
      print('📊 Obteniendo cotización de $symbol desde TradingView...');
      
      final uri = Uri.parse(TradingViewConfig.getEndpointUrl('quotes')).replace(
        queryParameters: {'symbols': symbol},
      );
      
      final response = await http.get(uri, headers: TradingViewConfig.defaultHeaders);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Cotización obtenida exitosamente');
        return data;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo cotización: $e');
      rethrow;
    }
  }

  // Obtener datos históricos
  static Future<Map<String, dynamic>> getHistory({
    required String symbol,
    required String resolution, // 1, 5, 15, 30, 60, 240, 1D, 1W, 1M
    required int from, // timestamp
    required int to, // timestamp
    int? countback,
  }) async {
    if (!TradingViewConfig.isConfigured) {
      throw Exception('TradingView no está configurado. Ver config/tradingview_config.dart');
    }
    
    try {
      print('📈 Obteniendo historial de $symbol...');
      
      final queryParams = <String, String>{
        'symbol': symbol,
        'resolution': resolution,
        'from': from.toString(),
        'to': to.toString(),
      };
      
      if (countback != null) {
        queryParams['countback'] = countback.toString();
      }
      
      final uri = Uri.parse(TradingViewConfig.getEndpointUrl('history')).replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(uri, headers: TradingViewConfig.defaultHeaders);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Historial obtenido exitosamente');
        return data;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo historial: $e');
      rethrow;
    }
  }

  // Obtener información del símbolo
  static Future<Map<String, dynamic>> getSymbolInfo(String symbol) async {
    if (!TradingViewConfig.isConfigured) {
      throw Exception('TradingView no está configurado. Ver config/tradingview_config.dart');
    }
    
    try {
      print('ℹ️ Obteniendo información de símbolo $symbol...');
      
      final uri = Uri.parse(TradingViewConfig.getEndpointUrl('symbol_info')).replace(
        queryParameters: {'symbol': symbol},
      );
      
      final response = await http.get(uri, headers: TradingViewConfig.defaultHeaders);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Información del símbolo obtenida');
        return data;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo información del símbolo: $e');
      rethrow;
    }
  }

  // Método principal para obtener datos de TX26
  static Future<List<TX26Data>> fetchTX26DataFromTradingView() async {
    final symbol = TradingViewConfig.tx26FullSymbol; // BCBA:TX26
    
    if (!TradingViewConfig.isConfigured) {
      print('⚠️ TradingView no configurado - usando datos simulados');
      return _generateFallbackData();
    }
    
    try {
      print('🚀 Iniciando obtención de datos TX26 desde TradingView...');
      
      // 1. Obtener cotización actual
      final quotes = await getQuotes(symbol);
      
      // 2. Obtener datos históricos (últimos 30 días)
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(Duration(days: TradingViewConfig.maxHistoryDays ~/ 12));
      
      final history = await getHistory(
        symbol: symbol,
        resolution: '1D', // Datos diarios
        from: (thirtyDaysAgo.millisecondsSinceEpoch / 1000).floor(),
        to: (now.millisecondsSinceEpoch / 1000).floor(),
        countback: 30,
      );
      
      // 3. Procesar y convertir datos
      final processedData = _processHistoryData(history, quotes);
      
      if (processedData.isNotEmpty) {
        print('✅ Datos obtenidos exitosamente desde TradingView API');
        return processedData;
      } else {
        print('⚠️ No se encontraron datos - usando fallback');
        return _generateFallbackData();
      }
      
    } catch (e) {
      print('❌ Error en fetchTX26DataFromTradingView: $e');
      // Fallback a datos simulados si TradingView falla
      return _generateFallbackData();
    }
  }

  // Procesar datos históricos de TradingView
  static List<TX26Data> _processHistoryData(
    Map<String, dynamic> history, 
    Map<String, dynamic> quotes
  ) {
    final List<TX26Data> dataList = [];
    
    try {
      // TradingView devuelve arrays paralelos
      final List<dynamic> timestamps = history['t'] ?? [];
      final List<dynamic> opens = history['o'] ?? [];
      final List<dynamic> highs = history['h'] ?? [];
      final List<dynamic> lows = history['l'] ?? [];
      final List<dynamic> closes = history['c'] ?? [];
      final List<dynamic> volumes = history['v'] ?? [];
      
      // Procesar cada día
      for (int i = 0; i < timestamps.length; i++) {
        final timestamp = timestamps[i] as int;
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        final open = (opens[i] as num).toDouble();
        final high = (highs[i] as num).toDouble();
        final low = (lows[i] as num).toDouble();
        final close = (closes[i] as num).toDouble();
        final volume = volumes.isNotEmpty ? (volumes[i] as num).toDouble() : 0.0;
        
        // Calcular variación respecto al día anterior
        double variacion = 0.0;
        if (i > 0) {
          final previousClose = (closes[i - 1] as num).toDouble();
          variacion = close - previousClose;
        }
        
        // Simular conversión USD (se debería obtener de otra fuente)
        const usdRate = 1150.0; // Tipo de cambio aproximado
        
        final data = TX26Data(
          especie: 'TX26',
          precioActual: close,
          variacion: variacion,
          fecha: dateStr,
          apertura: open,
          maximo: high,
          minimo: low,
          cierre: close,
          volumen: volume,
          usdApertura: open / usdRate,
          usdMaximo: high / usdRate,
          usdMinimo: low / usdRate,
          usdCierre: close / usdRate,
        );
        
        dataList.add(data);
      }
      
      // Ordenar por fecha (más reciente primero)
      dataList.sort((a, b) => b.fecha.compareTo(a.fecha));
      
      print('✅ Procesados ${dataList.length} registros de TradingView');
      
    } catch (e) {
      print('❌ Error procesando datos de TradingView: $e');
    }
    
    return dataList;
  }

  // Datos simulados como fallback
  static List<TX26Data> _generateFallbackData() {
    print('⚠️ Usando datos simulados como fallback...');
    
    final List<TX26Data> dataList = [];
    final now = DateTime.now();
    double basePrice = 1485.50;
    
    // Generar 15 días de datos
    for (int i = 14; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Variación diaria realista
      final variation = (0.5 - (i * 0.03)) * 0.01; // Tendencia descendente leve
      final dayPrice = basePrice * (1 + variation);
      
      final spread = dayPrice * 0.001;
      final apertura = dayPrice - spread;
      final cierre = dayPrice;
      final maximo = dayPrice + spread;
      final minimo = dayPrice - spread;
      
      final volumen = 150000.0 + (i * 10000);
      const usdRate = 1150.0;
      
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
    
    dataList.sort((a, b) => b.fecha.compareTo(a.fecha));
    return dataList;
  }

  // Obtener configuración del broker
  static Future<Map<String, dynamic>> getConfig() async {
    if (!TradingViewConfig.isConfigured) {
      throw Exception('TradingView no está configurado. Ver config/tradingview_config.dart');
    }
    
    try {
      final uri = Uri.parse(TradingViewConfig.getEndpointUrl('config'));
      final response = await http.get(uri, headers: TradingViewConfig.defaultHeaders);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error obteniendo configuración: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo configuración: $e');
      rethrow;
    }
  }

  // Streaming de cotizaciones (WebSocket)
  static Stream<Map<String, dynamic>> streamQuotes(List<String> symbols) async* {
    // Implementación de WebSocket para streaming en tiempo real
    // Por ahora, simulamos con polling cada 5 segundos
    
    while (true) {
      try {
        for (String symbol in symbols) {
          final quote = await getQuotes(symbol);
          yield quote;
        }
        await Future.delayed(Duration(seconds: 5));
      } catch (e) {
        print('❌ Error en streaming: $e');
        await Future.delayed(Duration(seconds: 10)); // Esperar más en caso de error
      }
    }
  }
}
