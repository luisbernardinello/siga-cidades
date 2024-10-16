import 'package:sigacidades/domain/entities/locale.dart';

class LocaleModel extends Locale {
  LocaleModel({required String name, required String imageUrl})
      : super(name: name, imageUrl: imageUrl);

  // Converte JSON para o modelo
  factory LocaleModel.fromJson(Map<String, dynamic> json) {
    return LocaleModel(
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }

  // Converte o modelo para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}
