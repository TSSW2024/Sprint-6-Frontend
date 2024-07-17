class Moneda {
  final String index;
  final String image;
  final String name;
  final String price;
  final String change24h;

  Moneda({
    required this.index,
    required this.image,
    required this.name,
    required this.price,
    required this.change24h,
  });

  factory Moneda.fromJson(Map<String, dynamic> json) {
    return Moneda(
      index: json['index'],
      image: json['image'],
      name: json['name'],
      price: json['price'],
      change24h: json['change_24h'],
    );
  }
}

class MonedasResponse {
  final List<Moneda> ganadores;
  final List<Moneda> mayorVolumen;
  final List<Moneda> perdedores;
  final List<Moneda> populares;

  MonedasResponse({
    required this.ganadores,
    required this.mayorVolumen,
    required this.perdedores,
    required this.populares,
  });

  factory MonedasResponse.fromJson(Map<String, dynamic> json) {
    var ganadoresList = json['Ganadores'] as List;
    var mayorVolumenList = json['MayorVolumen'] as List;
    var perdedoresList = json['Perdedores'] as List;
    var popularesList = json['Populares'] as List;

    List<Moneda> ganadores =
        ganadoresList.map((i) => Moneda.fromJson(i)).toList();
    List<Moneda> mayorVolumen =
        mayorVolumenList.map((i) => Moneda.fromJson(i)).toList();
    List<Moneda> perdedores =
        perdedoresList.map((i) => Moneda.fromJson(i)).toList();
    List<Moneda> populares =
        popularesList.map((i) => Moneda.fromJson(i)).toList();

    return MonedasResponse(
      ganadores: ganadores,
      mayorVolumen: mayorVolumen,
      perdedores: perdedores,
      populares: populares,
    );
  }
}
