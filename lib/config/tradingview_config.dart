// Configuración para TradingView API
// Instrucciones de configuración:

// 1. OBTENER ACCESO A TradingView API:
//    - Visita: https://www.tradingview.com/brokerage-integration/
//    - Registrate como broker o usa un broker partner
//    - Obtén tu API_KEY y base URL

// 2. CONFIGURAR CREDENCIALES:
//    Reemplaza los valores de ejemplo con tus credenciales reales:

class TradingViewConfig {
  // ⚠️ IMPORTANTE: Estas son credenciales de ejemplo
  // Reemplaza con tus valores reales de TradingView
  
  // URL base de tu broker integrado con TradingView
  static const String baseUrl = 'https://your-broker-api.com/api';
  
  // Tu API Key de TradingView
  static const String apiKey = 'YOUR_TRADINGVIEW_API_KEY';
  
  // Configuración para TX26 específicamente
  static const String tx26Symbol = 'TX26';
  static const String tx26FullSymbol = 'BCBA:TX26'; // Bolsa de Comercio de Buenos Aires
  
  // Configuración de mercado argentino
  static const String argentineExchange = 'BCBA';
  static const String currency = 'ARS';
  
  // Endpoints específicos
  static const Duration refreshInterval = Duration(seconds: 30);
  static const int maxHistoryDays = 365;
  
  // Headers por defecto
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
    'Accept': 'application/json',
    'User-Agent': 'WalletView-Flutter/1.0',
  };
  
  // Configuración de símbolos soportados
  static const List<String> supportedSymbols = [
    'TX26', // BONCER 2026
    'TX24', // BONCER 2024  
    'TX25', // BONCER 2025
    'TX27', // BONCER 2027
    'AE38', // BONAR 2038
    'AL29', // BONAR 2029
    'AL30', // BONAR 2030
    'GD29', // DISCOUNT 2029
    'GD30', // DISCOUNT 2030
  ];
  
  // Configuración de resoluciones soportadas
  static const List<String> supportedResolutions = [
    '1',    // 1 minuto
    '5',    // 5 minutos
    '15',   // 15 minutos
    '30',   // 30 minutos
    '60',   // 1 hora
    '240',  // 4 horas
    '1D',   // 1 día
    '1W',   // 1 semana
    '1M',   // 1 mes
  ];
  
  // Validar configuración
  static bool get isConfigured {
    return baseUrl != 'https://your-broker-api.com/api' && 
           apiKey != 'YOUR_TRADINGVIEW_API_KEY' &&
           apiKey.isNotEmpty;
  }
  
  // Obtener URL completa para endpoint
  static String getEndpointUrl(String endpoint) {
    return '$baseUrl/$endpoint'.replaceAll('//', '/');
  }
}

// BROKERS RECOMENDADOS CON INTEGRACIÓN TradingView PARA ARGENTINA:

/* 
🏦 BROKERS ARGENTINOS CON API TradingView:

1. PPI (Productos Profesionales de Inversión)
   - Website: https://www.ppi.com.ar/
   - API: Integración con TradingView disponible
   - Instrumentos: Bonos, acciones, CEDEARs, FCI

2. InvertirOnline (IOL)
   - Website: https://www.invertironline.com/
   - API: REST API disponible
   - Documentación: https://api.invertironline.com/

3. Balanz
   - Website: https://balanz.com/
   - API: Integración institucional disponible

4. Bull Market Brokers (BMB)
   - Website: https://www.bmb.com.ar/
   - API: Para clientes institucionales

5. Cocos Capital
   - Website: https://www.cocoscapital.com.ar/
   - API: Disponible para integraciones

📋 PASOS PARA CONFIGURAR:

1. Elegir un broker de la lista
2. Abrir cuenta y solicitar acceso API
3. Obtener credenciales (API_KEY, SECRET, etc.)
4. Reemplazar valores en TradingViewConfig
5. Probar la conexión

💡 ALTERNATIVAS GRATUITAS:

- Yahoo Finance API (limitada)
- Alpha Vantage (500 requests/día gratis)
- Twelve Data (800 requests/día gratis)
- IEX Cloud (500,000 requests/mes gratis)

🔧 IMPLEMENTACIÓN:

Una vez que tengas las credenciales reales:
1. Actualiza baseUrl y apiKey
2. Configura el símbolo correcto para TX26
3. Ejecuta la app y verifica los logs
4. Los datos reales reemplazarán los simulados
*/
