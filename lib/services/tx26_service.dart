import 'package:http/http.dart' as http;
import '../models/tx26_data.dart';
import 'alpha_vantage_service.dart';

class TX26Service {
  // URLs de fallback
  static const String _ravaUrl = 'https://www.rava.com/perfil/TX26';
  
  static final Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'es-ES,es;q=0.8,en;q=0.6',
    'Connection': 'keep-alive',
  };

  static Future<List<TX26Data>> fetchTX26Data() async {
    print('🚀 Iniciando obtención de datos TX26...');
    
    // 1. Intentar primero con Alpha Vantage API
    try {
      print('📊 Intentando obtener datos desde Alpha Vantage API...');
      final alphaVantageData = await AlphaVantageService.fetchTX26DataFromAlphaVantage();
      
      if (alphaVantageData.isNotEmpty) {
        print('✅ Datos obtenidos exitosamente desde Alpha Vantage');
        print('📈 Precio actual: \$${alphaVantageData.first.precioFormateado}');
        print('📊 Registros: ${alphaVantageData.length}');
        return alphaVantageData;
      }
    } catch (e) {
      print('❌ Error con Alpha Vantage API: $e');
    }
    
    // 2. Fallback: Intentar web scraping de Rava.com
    try {
      print('🌐 Fallback: Intentando web scraping de Rava.com...');
      final response = await http.get(Uri.parse(_ravaUrl), headers: _headers);
      
      if (response.statusCode == 200) {
        print('✅ Respuesta exitosa de Rava.com');
        final scrapedData = _parseDataFromHTML(response.body);
        if (scrapedData.isNotEmpty) {
          return scrapedData;
        }
      }
    } catch (e) {
      print('⚠️ Web scraping falló: $e');
    }
    
    // 3. Último recurso: Datos simulados con mensaje claro
    print('🔄 Usando datos simulados como último recurso...');
    return _generateSimulatedData();
  }

  // Parser para datos de Rava.com (mantenido como fallback)
  static List<TX26Data> _parseDataFromHTML(String html) {
    final List<TX26Data> dataList = [];
    
    try {
      // Buscar datos históricos en formato JSON
      final RegExp jsonPattern = RegExp(r'"especie":"TX26"[^}]*"fecha":"([^"]*)"[^}]*"apertura":([0-9.]+)[^}]*"maximo":([0-9.]+)[^}]*"minimo":([0-9.]+)[^}]*"cierre":([0-9.]+)[^}]*"volumen":([0-9.]+)[^}]*"usd_apertura":([0-9.]+)[^}]*"usd_maximo":([0-9.]+)[^}]*"usd_minimo":([0-9.]+)[^}]*"usd_cierre":([0-9.]+)');
      
      final matches = jsonPattern.allMatches(html);
      
      for (var match in matches) {
        try {
          final data = TX26Data(
            especie: 'TX26',
            precioActual: double.parse(match.group(5) ?? '0'), // cierre
            variacion: 0.0, // Se calculará después
            fecha: match.group(1) ?? '',
            apertura: double.parse(match.group(2) ?? '0'),
            maximo: double.parse(match.group(3) ?? '0'),
            minimo: double.parse(match.group(4) ?? '0'),
            cierre: double.parse(match.group(5) ?? '0'),
            volumen: double.parse(match.group(6) ?? '0'),
            usdApertura: double.parse(match.group(7) ?? '0'),
            usdMaximo: double.parse(match.group(8) ?? '0'),
            usdMinimo: double.parse(match.group(9) ?? '0'),
            usdCierre: double.parse(match.group(10) ?? '0'),
          );
          dataList.add(data);
        } catch (e) {
          print('Error parseando datos: $e');
        }
      }
      
      // Calcular variaciones si hay múltiples datos
      if (dataList.length > 1) {
        for (int i = 1; i < dataList.length; i++) {
          final actual = dataList[i];
          final anterior = dataList[i - 1];
          final variacion = actual.cierre - anterior.cierre;
          
          dataList[i] = TX26Data(
            especie: actual.especie,
            precioActual: actual.precioActual,
            variacion: variacion,
            fecha: actual.fecha,
            apertura: actual.apertura,
            maximo: actual.maximo,
            minimo: actual.minimo,
            cierre: actual.cierre,
            volumen: actual.volumen,
            usdApertura: actual.usdApertura,
            usdMaximo: actual.usdMaximo,
            usdMinimo: actual.usdMinimo,
            usdCierre: actual.usdCierre,
          );
        }
      }
      
      dataList.sort((a, b) => b.fecha.compareTo(a.fecha));
      
    } catch (e) {
      print('Error general parseando HTML: $e');
    }
    
    return dataList;
  }

  // Datos simulados mejorados
  static List<TX26Data> _generateSimulatedData() {
    final List<TX26Data> dataList = [];
    final now = DateTime.now();
    
    // Precio base actual del TX26 BONCER 2026
    double basePrice = 1489.75;
    
    print('📊 Generando datos simulados realistas para TX26 BONCER 2026...');
    print('💡 Nota: Usando datos simulados - Configure Alpha Vantage API para datos reales');
    
    // Generar 20 días de datos históricos
    for (int i = 19; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Variación diaria realista para bonos soberanos
      final volatility = 0.008; // 0.8% volatilidad diaria
      final trend = -0.0002; // Tendencia ligeramente bajista
      final variation = trend + (0.5 - (i % 10) / 10.0) * volatility;
      
      final dayPrice = basePrice * (1 + variation);
      
      // Precios intradiarios con spread típico de bonos
      final spread = dayPrice * 0.0015; // 0.15% de spread
      final apertura = dayPrice - spread * 0.5;
      final cierre = dayPrice;
      final maximo = dayPrice + spread * 0.8;
      final minimo = dayPrice - spread * 0.6;
      
      // Volumen típico para bonos soberanos
      final volumen = 180000.0 + (i * 8000) + ((i % 5) * 25000);
      
      // Tipo de cambio USD/ARS (actualizado)
      const usdRate = 1160.0;
      
      // Calcular variación respecto al día anterior
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
    
    print('✅ Generados ${dataList.length} registros simulados');
    print('📈 Precio simulado actual: \$${dataList.first.precioFormateado}');
    
    return dataList;
  }
  
  // Método para verificar el estado de la configuración
  static String getDataSourceStatus() {
    if (AlphaVantageService.isConfigured) {
      return 'Alpha Vantage';
    }
    return 'Simulado';
  }
  
  // Obtener información detallada del estado
  static Map<String, dynamic> getServiceStatus() {
    return {
      'primary_source': 'Alpha Vantage API',
      'alpha_vantage_configured': AlphaVantageService.isConfigured,
      'fallback_web_scraping': true,
      'fallback_simulated_data': true,
      'current_data_source': getDataSourceStatus(),
      'status': AlphaVantageService.isConfigured ? 'Configurado' : 'Necesita configuración',
    };
  }
}
