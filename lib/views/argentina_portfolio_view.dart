import 'package:flutter/material.dart';
import '../models/argentina_stocks_data.dart';
import '../services/argentina_stocks_service.dart';

class ArgentinaPortfolioView extends StatefulWidget {
  const ArgentinaPortfolioView({super.key});

  @override
  State<ArgentinaPortfolioView> createState() => _ArgentinaPortfolioViewState();
}

class _ArgentinaPortfolioViewState extends State<ArgentinaPortfolioView> {
  List<ArgentinaStockData> _stocks = [];
  Map<String, dynamic>? _marketSummary;
  bool _isLoading = true;
  String? _error;
  String _selectedSector = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stocks = await ArgentinaStocksService.fetchAllArgentinaStocks();
      final summary = await ArgentinaStocksService.getMarketSummary();
      
      setState(() {
        _stocks = stocks;
        _marketSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ArgentinaStockData> get _filteredStocks {
    if (_selectedSector == 'Todos') {
      return _stocks;
    }
    return _stocks.where((stock) {
      final stockInfo = ArgentinaStocksService.getStockInfo(stock.symbol);
      return stockInfo?['sector'] == _selectedSector;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🇦🇷 Portfolio Argentina',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    _buildMarketSummary(),
                    _buildSectorFilter(),
                    Expanded(child: _buildStocksList()),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar datos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketSummary() {
    if (_marketSummary == null) return const SizedBox.shrink();

    final summary = _marketSummary!;
    final sentiment = summary['market_sentiment'] as String;
    final avgChange = summary['avg_change_percent'] as double;
    final dataSource = summary['data_source'] as String;

    Color sentimentColor = Colors.grey;
    if (sentiment == 'Positivo') sentimentColor = Colors.green;
    if (sentiment == 'Negativo') sentimentColor = Colors.red;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resumen del Mercado',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sentimentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sentiment,
                  style: TextStyle(
                    color: sentimentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Acciones',
                  '${summary['total_stocks']}',
                  Icons.assessment,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Promedio',
                  '${avgChange.toStringAsFixed(2)}%',
                  avgChange >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: avgChange >= 0 ? Colors.green : Colors.red,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Positivas',
                  '${summary['positive']}',
                  Icons.thumb_up,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Negativas',
                  '${summary['negative']}',
                  Icons.thumb_down,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fuente: $dataSource',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectorFilter() {
    final sectors = ['Todos', ...ArgentinaStocksService.getAvailableSectors()];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sectors.length,
        itemBuilder: (context, index) {
          final sector = sectors[index];
          final isSelected = sector == _selectedSector;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(sector),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSector = sector;
                });
              },
              backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStocksList() {
    final filteredStocks = _filteredStocks;
    
    if (filteredStocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay acciones en el sector $_selectedSector',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredStocks.length,
      itemBuilder: (context, index) {
        final stock = filteredStocks[index];
        return _buildStockCard(stock);
      },
    );
  }

  Widget _buildStockCard(ArgentinaStockData stock) {
    final stockInfo = ArgentinaStocksService.getStockInfo(stock.symbol);
    final isPositive = stock.change >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            stock.symbol.substring(0, 2),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          stock.symbol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (stockInfo != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      stockInfo['sector']!,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stockInfo['exchange']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              stock.priceFormatted,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: changeColor,
                  size: 16,
                ),
                Text(
                  '${stock.changePercentFormatted}%',
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showStockDetails(stock),
      ),
    );
  }

  void _showStockDetails(ArgentinaStockData stock) {
    final stockInfo = ArgentinaStocksService.getStockInfo(stock.symbol);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      stock.symbol,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.symbol,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          stock.name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Precio Actual', stock.priceFormatted),
              _buildDetailRow('Cambio', '${stock.changeFormatted} (${stock.changePercentFormatted}%)'),
              _buildDetailRow('Precio Anterior', stock.previousCloseFormatted),
              _buildDetailRow('Volumen', stock.volumeFormatted),
              if (stockInfo != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetailRow('Sector', stockInfo['sector']!),
                _buildDetailRow('Bolsa', stockInfo['exchange']!),
                if (stockInfo['description'] != null)
                  _buildDetailRow('Descripción', stockInfo['description']!),
              ],
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('Última Actualización', stock.lastUpdateFormatted),
              _buildDetailRow('Fuente de Datos', stock.dataSource),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
