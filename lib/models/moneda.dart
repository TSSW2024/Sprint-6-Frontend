class Moneda {
  final String symbol;
  final String icon;
  final double value;

  Moneda({
    required this.symbol,
    required this.icon,
    required this.value,
  });

  factory Moneda.fromMap(Map<String, dynamic> map) {
    return Moneda(
      symbol: map['symbol'],
      icon: map['icon'],
      value: map['value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'icon': icon,
      'value': value,
    };
  }
}
