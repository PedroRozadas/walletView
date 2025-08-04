import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'models/tx26_data.dart';
import 'services/tx26_service.dart';
import 'services/alpha_vantage_config.dart';
import 'package:flutter/cupertino.dart';

class ImportView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TX26Bloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('TX26 BONCER 2026 - ${AlphaVantageConfig.isConfigured ? "Alpha Vantage" : "Simulado"}'),
              backgroundColor: AlphaVantageConfig.isConfigured ? Colors.green.shade700 : Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            body: BlocBuilder<TX26Bloc, TX26State>(
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () => context.read<TX26Bloc>().fetchTX26Data(),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostrar estado de la configuración
                        _buildConfigStatusCard(),
                        SizedBox(height: 16),
                        
                        // Header Card
                        _buildHeaderCard(state),
                        SizedBox(height: 16),
                        
                        // Current Price Card
                        if (state.data != null) _buildPriceCard(state.data!),
                        if (state.data != null) SizedBox(height: 16),
                        
                        // Action Buttons
                        _buildActionButtons(context, state),
                        SizedBox(height: 16),
                        
                        // Historical Data
                        if (state.historico.isNotEmpty) _buildHistoricalData(state.historico),
                        
                        // Error Message
                        if (state.error != null) _buildErrorCard(state.error!, context),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(TX26State state) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: Colors.blue.shade700, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TX26 BONCER 2026',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rendimiento: 2,00%',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (state.isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (state.lastUpdate != null) ...[
              SizedBox(height: 8),
              Text(
                'Última actualización: ${_formatTime(state.lastUpdate!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(TX26Data data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precio Actual',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${data.precioFormateado}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: data.esPositiva ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data.variacionFormateada,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Apertura', '\$${data.apertura.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildInfoItem('Máximo', '\$${data.maximo.toStringAsFixed(2)}'),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Mínimo', '\$${data.minimo.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildInfoItem('Volumen', data.volumenFormateado),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, TX26State state) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.isLoading 
              ? null 
              : () => context.read<TX26Bloc>().fetchTX26Data(),
            icon: Icon(Icons.refresh),
            label: Text('Actualizar Datos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoricalData(List<TX26Data> historico) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos Históricos (${historico.length} registros)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            ...historico.take(5).map((data) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data.fecha,
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    '\$${data.precioFormateado}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            )).toList(),
            if (historico.length > 5)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '... y ${historico.length - 5} registros más',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error, BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.red.shade700),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<TX26Bloc>().clearError(),
              child: Text('Cerrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Nuevo widget para mostrar el estado de configuración
  Widget _buildConfigStatusCard() {
    final isConfigured = AlphaVantageConfig.isConfigured;
    
    return Card(
      color: isConfigured ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConfigured ? Icons.check_circle : Icons.warning,
                  color: isConfigured ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  isConfigured ? 'Alpha Vantage API Configurado' : 'Usando Datos Simulados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isConfigured ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              isConfigured 
                ? 'Conectado a Alpha Vantage API para datos en tiempo real'
                : 'Configure Alpha Vantage API en services/alpha_vantage_config.dart para datos reales',
              style: TextStyle(
                fontSize: 14,
                color: isConfigured ? Colors.green.shade600 : Colors.orange.shade600,
              ),
            ),
            if (!isConfigured) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Los datos mostrados son simulados pero realistas, basados en TX26 BONCER 2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// TX26 Bloc class
class TX26Bloc extends Cubit<TX26State> {
  TX26Bloc() : super(TX26State());
  
  Future<void> fetchTX26Data() async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final dataList = await TX26Service.fetchTX26Data();
      final latestData = dataList.isNotEmpty ? dataList.first : null;
      
      emit(state.copyWith(
        isLoading: false,
        data: latestData,
        historico: dataList,
        lastUpdate: DateTime.now(),
      ));
      
      print('✅ TX26 Data actualizada exitosamente');
      print('📊 Último precio: ${latestData?.precioFormateado ?? 'N/A'}');
      print('📈 Variación: ${latestData?.variacionFormateada ?? 'N/A'}');
      print('📅 Registros históricos: ${dataList.length}');
      
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      print('❌ Error: $e');
    }
  }
  
  void clearError() {
    emit(state.copyWith(error: null));
  }
}
