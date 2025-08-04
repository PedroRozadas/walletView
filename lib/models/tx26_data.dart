class TX26Data {
  final String especie;
  final double precioActual;
  final double variacion;
  final String fecha;
  final double apertura;
  final double maximo;
  final double minimo;
  final double cierre;
  final double volumen;
  final double usdApertura;
  final double usdMaximo;
  final double usdMinimo;
  final double usdCierre;

  TX26Data({
    required this.especie,
    required this.precioActual,
    required this.variacion,
    required this.fecha,
    required this.apertura,
    required this.maximo,
    required this.minimo,
    required this.cierre,
    required this.volumen,
    required this.usdApertura,
    required this.usdMaximo,
    required this.usdMinimo,
    required this.usdCierre,
  });

  factory TX26Data.fromJson(Map<String, dynamic> json) {
    return TX26Data(
      especie: json['especie'] ?? 'TX26',
      precioActual: (json['cierre'] ?? 0).toDouble(),
      variacion: 0.0, // Se calculará
      fecha: json['fecha'] ?? '',
      apertura: (json['apertura'] ?? 0).toDouble(),
      maximo: (json['maximo'] ?? 0).toDouble(),
      minimo: (json['minimo'] ?? 0).toDouble(),
      cierre: (json['cierre'] ?? 0).toDouble(),
      volumen: (json['volumen'] ?? 0).toDouble(),
      usdApertura: (json['usd_apertura'] ?? 0).toDouble(),
      usdMaximo: (json['usd_maximo'] ?? 0).toDouble(),
      usdMinimo: (json['usd_minimo'] ?? 0).toDouble(),
      usdCierre: (json['usd_cierre'] ?? 0).toDouble(),
    );
  }

  // Getters para formateo
  String get precioFormateado => precioActual.toStringAsFixed(2);
  String get variacionFormateada => '${variacion >= 0 ? '+' : ''}${variacion.toStringAsFixed(2)}';
  bool get esPositiva => variacion >= 0;
  String get volumenFormateado => volumen.toStringAsFixed(0);
  
  // Getter para el rendimiento
  String get rendimiento => '2,00%'; // BONCER 2026 2,00%
}

class TX26State {
  final bool isLoading;
  final TX26Data? data;
  final List<TX26Data> historico;
  final String? error;
  final DateTime? lastUpdate;

  TX26State({
    this.isLoading = false,
    this.data,
    this.historico = const [],
    this.error,
    this.lastUpdate,
  });

  TX26State copyWith({
    bool? isLoading,
    TX26Data? data,
    List<TX26Data>? historico,
    String? error,
    DateTime? lastUpdate,
  }) {
    return TX26State(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      historico: historico ?? this.historico,
      error: error ?? this.error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
