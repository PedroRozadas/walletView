import 'package:flutter_dotenv/flutter_dotenv.dart';

class AlphaVantageConfig {
  // CONFIGURACIÓN DE ALPHA VANTAGE API CON VARIABLES DE ENTORNO
  // ===========================================================
  
  // 1. Obtener API Key desde variables de entorno (.env)
  //    - Más seguro que hardcodear la API Key
  //    - Permite diferentes configuraciones por entorno
  //    - Evita exponer credenciales en el código fuente
  
  static String get apiKey {
    return dotenv.env['ALPHA_VANTAGE_API_KEY'] ?? 'YOUR_ALPHA_VANTAGE_API_KEY';
  }
  
  // URL base de la API
  static const String baseUrl = 'https://www.alphavantage.co/query';
  
  // Límites de la API gratuita
  static const int dailyRequestLimit = 500;    // 500 requests por día
  static const int minuteRequestLimit = 5;     // 5 requests por minuto
  
  // Configuración de símbolos para Argentina disponibles en Alpha Vantage
  // IMPORTANTE: Los bonos TX26.BA, TX24.BA, etc. NO están disponibles en Alpha Vantage
  // Solo están disponibles estas acciones argentinas:
  static const Map<String, SymbolInfo> supportedSymbols = {
    // Acciones argentinas disponibles en Alpha Vantage (confirmado)
    'GGAL': SymbolInfo(
      symbol: 'GGAL',
      exchange: 'NASDAQ',
      description: 'Grupo Financiero Galicia',
      currency: 'USD',
    ),
    'YPF': SymbolInfo(
      symbol: 'YPF',
      exchange: 'NYSE',
      description: 'YPF Sociedad Anonima',
      currency: 'USD',
    ),
    'PAM': SymbolInfo(
      symbol: 'PAM',
      exchange: 'NYSE',
      description: 'Pampa Energia SA',
      currency: 'USD',
    ),
    'BBAR': SymbolInfo(
      symbol: 'BBAR',
      exchange: 'NYSE',
      description: 'BBVA Argentina',
      currency: 'USD',
    ),
    'TEO': SymbolInfo(
      symbol: 'TEO',
      exchange: 'NYSE',
      description: 'Telecom Argentina S.A.',
      currency: 'USD',
    ),
    'LOMA': SymbolInfo(
      symbol: 'LOMA',
      exchange: 'NYSE',
      description: 'Loma Negra Compania Industrial Argentina',
      currency: 'USD',
    ),
    'ARGT': SymbolInfo(
      symbol: 'ARGT',
      exchange: 'NYSE ARCA',
      description: 'Global X MSCI Argentina ETF',
      currency: 'USD',
    ),
    // ⚠️ NOTA: TX26, TX24, TX25, TX27, AE38, AL29, AL30 NO están disponibles
    // Estos bonos argentinos no se encuentran en Alpha Vantage
    // La aplicación usará datos simulados para TX26
  };
  
  // Verificar si está configurado
  static bool get isConfigured {
    return apiKey != 'YOUR_ALPHA_VANTAGE_API_KEY' && 
           apiKey.isNotEmpty && 
           apiKey.length > 10;
  }
  
  // Validar API Key
  static bool validateApiKey(String key) {
    return key.isNotEmpty && 
           key.length >= 8 && 
           key != 'YOUR_ALPHA_VANTAGE_API_KEY' &&
           !key.contains(' ') &&
           RegExp(r'^[A-Z0-9]+$').hasMatch(key);
  }
  
  // Obtener información del símbolo
  static SymbolInfo? getSymbolInfo(String symbol) {
    return supportedSymbols[symbol.toUpperCase()];
  }
  
  // Obtener el símbolo mapeado para la API
  static String getMappedSymbol(String symbol) {
    final info = getSymbolInfo(symbol);
    return info?.symbol ?? symbol;
  }
  
  // Información de configuración para mostrar en UI
  static Map<String, dynamic> getConfigInfo() {
    return {
      'configured': isConfigured,
      'api_key': isConfigured ? apiKey.substring(0, 8) + '...' : 'No configurado',
      'daily_limit': dailyRequestLimit,
      'minute_limit': minuteRequestLimit,
      'supported_symbols': supportedSymbols.length,
      'base_url': baseUrl,
      'status': isConfigured ? 'Listo' : 'Necesita configuración',
    };
  }
}

// Información de símbolo
class SymbolInfo {
  final String symbol;
  final String exchange;
  final String description;
  final String currency;
  
  const SymbolInfo({
    required this.symbol,
    required this.exchange,
    required this.description,
    required this.currency,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'exchange': exchange,
      'description': description,
      'currency': currency,
    };
  }
}

// INSTRUCCIONES DE CONFIGURACIÓN
// ==============================
/*

📋 PASOS PARA CONFIGURAR ALPHA VANTAGE:

1. 🌐 OBTENER API KEY GRATUITA:
   • Ir a: https://www.alphavantage.co/support/#api-key
   • Llenar el formulario:
     - First Name: Tu nombre
     - Last Name: Tu apellido
     - Email: Tu email válido
     - Organization: Opcional (ej: "Personal")
     - Briefly describe how you will use our service: "Mobile app for financial data"
   • Verificar tu email
   • Copiar la API Key que te envían

2. 🔧 CONFIGURAR EN EL CÓDIGO:
   • Reemplazar 'YOUR_ALPHA_VANTAGE_API_KEY' con tu API Key real
   • Guardar el archivo
   • Reiniciar la aplicación

3. 📊 LÍMITES DE LA API GRATUITA:
   • 500 requests por día
   • 5 requests por minuto
   • Datos diarios e intradia disponibles
   • Soporte para mercados internacionales

4. ✅ VERIFICACIÓN:
   • La app mostrará "Alpha Vantage" en lugar de "Simulado"
   • El indicador verde confirmará que está funcionando
   • Los datos serán reales de Alpha Vantage

5. 🔄 SÍMBOLOS SOPORTADOS:
   • TX26.BA - República Argentina 2026
   • TX24.BA - República Argentina 2024
   • TX25.BA - República Argentina 2025
   • TX27.BA - República Argentina 2027
   • AE38.BA - BONCER AE38
   • AL29.BA - BONCER AL29
   • AL30.BA - BONCER AL30

⚠️ IMPORTANTE:
- La API Key es gratuita pero limitada
- Guarda tu API Key en lugar seguro
- No compartas tu API Key públicamente
- Si superas el límite, espera al día siguiente

🔗 ENLACES ÚTILES:
- Alpha Vantage Dashboard: https://www.alphavantage.co/
- Documentación: https://www.alphavantage.co/documentation/
- Soporte: https://www.alphavantage.co/support/

*/
