# 🚀 Configuración de Alpha Vantage API

## 📋 Introducción

Esta aplicación ahora utiliza **Alpha Vantage API** como fuente principal de datos financieros para obtener información en tiempo real de los bonos argentinos TX26 BONCER 2026 y otros instrumentos.

## 🎯 ¿Por qué Alpha Vantage?

- ✅ **API Gratuita**: 500 requests por día sin costo
- ✅ **Fácil configuración**: Solo necesita un email para registrarse
- ✅ **Datos confiables**: Proveedor reconocido de datos financieros
- ✅ **Soporte internacional**: Incluye mercados de Argentina
- ✅ **Sin complejidad**: No requiere broker ni suscripciones

## 🔧 Configuración Paso a Paso

### 1. Obtener API Key GRATUITA

1. **Ir al sitio oficial**: https://www.alphavantage.co/support/#api-key
2. **Completar formulario básico**:
   - First Name: Tu nombre
   - Last Name: Tu apellido  
   - Email: Tu email válido
   - Organization: (Opcional) "Personal" o tu empresa
   - Use case: "Mobile app for financial data"
3. **Verificar email**: Revisar tu bandeja de entrada
4. **Copiar API Key**: Te llegará por email

### 2. Configurar en la aplicación

1. **Abrir archivo**: `lib/services/alpha_vantage_config.dart`
2. **Buscar línea**:
   ```dart
   static const String apiKey = 'YOUR_ALPHA_VANTAGE_API_KEY';
   ```
3. **Reemplazar** `YOUR_ALPHA_VANTAGE_API_KEY` con tu API Key real
4. **Guardar archivo**
5. **Reiniciar aplicación**

### 3. Verificar configuración

- ✅ El título de la app cambiará de "Simulado" a "Alpha Vantage"
- ✅ La barra superior será verde (configurado) en lugar de naranja
- ✅ Los datos serán reales de Alpha Vantage

## 📊 Símbolos Soportados

La aplicación está configurada para los siguientes bonos argentinos:

| Símbolo | Descripción | Exchange |
|---------|-------------|----------|
| TX26.BA | República Argentina 2026 | Buenos Aires |
| TX24.BA | República Argentina 2024 | Buenos Aires |
| TX25.BA | República Argentina 2025 | Buenos Aires |
| TX27.BA | República Argentina 2027 | Buenos Aires |
| AE38.BA | BONCER AE38 | Buenos Aires |
| AL29.BA | BONCER AL29 | Buenos Aires |
| AL30.BA | BONCER AL30 | Buenos Aires |

## ⚡ Límites de la API Gratuita

- **Requests diarios**: 500 por día
- **Requests por minuto**: 5 máximo
- **Datos disponibles**: Diarios e intradia
- **Mercados**: Internacionales incluido Argentina

## 🔄 Arquitectura de Fallback

La aplicación mantiene una arquitectura robusta de múltiples fuentes:

1. **🥇 Primaria**: Alpha Vantage API (datos reales)
2. **🥈 Fallback**: Web scraping de Rava.com
3. **🥉 Último recurso**: Datos simulados realistas

## 🛠️ Ejemplo de Configuración

```dart
// En alpha_vantage_config.dart
class AlphaVantageConfig {
  static const String apiKey = 'TU_API_KEY_AQUI'; // ✅ Reemplazar esto
  
  // El resto se configura automáticamente
}
```

## 🔍 Troubleshooting

### ❌ Problema: "Rate limit exceeded"
**Solución**: Has superado el límite de 500 requests diarios. Espera al día siguiente.

### ❌ Problema: "API Key no configurado"
**Solución**: Asegúrate de haber reemplazado `YOUR_ALPHA_VANTAGE_API_KEY` con tu key real.

### ❌ Problema: "Symbol not found"
**Solución**: Alpha Vantage puede no tener algunos símbolos argentinos. La app usará fallback automáticamente.

### ❌ Problema: Sigue mostrando "Simulado"
**Solución**: 
1. Verifica que guardaste el archivo de configuración
2. Reinicia la aplicación completamente
3. Verifica que la API Key sea válida

## 📱 Estados de la Aplicación

| Estado | AppBar | Descripción |
|--------|--------|-------------|
| 🟢 Alpha Vantage | Verde | API configurada y funcionando |
| 🟠 Simulado | Naranja | Usando datos simulados |
| 🔴 Error | Rojo | Error en la conexión |

## 🔗 Enlaces Útiles

- **Sitio oficial**: https://www.alphavantage.co/
- **Documentación**: https://www.alphavantage.co/documentation/
- **Soporte**: https://www.alphavantage.co/support/
- **Dashboard**: https://www.alphavantage.co/ (después de registrarse)

## ⚠️ Notas Importantes

1. **Gratuita pero limitada**: 500 requests por día
2. **No compartir**: Tu API Key es personal, no la compartas públicamente
3. **Guardala segura**: Anota tu API Key en lugar seguro
4. **Datos internacionales**: Alpha Vantage cubre mercados mundiales
5. **Fallback automático**: Si la API falla, la app seguirá funcionando

## 🏆 Ventajas vs TradingView

| Característica | Alpha Vantage | TradingView |
|---------------|---------------|-------------|
| **Costo** | ✅ Gratis | ❌ Requiere plan pago |
| **Configuración** | ✅ Solo email | ❌ Broker + suscripción |
| **Límites** | ✅ 500/día gratis | ❌ Muy restrictivo gratis |
| **Cobertura** | ✅ Global | ✅ Global |
| **Facilidad** | ✅ Muy fácil | ❌ Complejo |

---

*Configurado Alpha Vantage API para TX26 BONCER 2026 - Datos financieros en tiempo real* 🚀
