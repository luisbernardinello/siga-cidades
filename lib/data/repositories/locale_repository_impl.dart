import 'package:sigacidades/domain/entities/locale.dart';
import 'package:sigacidades/domain/repositories/locale_repository.dart';

class LocaleRepositoryImpl implements LocaleRepository {
  @override
  Future<List<Locale>> fetchLocalesByCategory(int categoryIndex) async {
    // Simulação de dados locais. Eventualmente, isso pode ser substituído por chamadas a APIs.
    switch (categoryIndex) {
      case 1:
        return [
          Locale(
              name: 'Casarão da Picanha',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Bar do Roberto',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Bar do Juca',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Bar do Rogerio',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Bar do Flavio',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Bar do Fernando',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Bar do Juca',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Bar do Marcinho',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Bar do Tulio',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Farmácia Droga Raia',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Farmácia Drogasil',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Farmácia Popular',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Supermercado Barracão',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Supermercado Confiança',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Supermercado Tauste',
              imageUrl: 'https://via.placeholder.com/164x100')
        ];
      case 2:
        return [
          Locale(
              name: 'Centro Cultural',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Museu de Arte',
              imageUrl: 'https://via.placeholder.com/164x100'),
        ];
      default:
        return [
          Locale(
              name: 'Bosque da Comunidade',
              imageUrl: 'https://via.placeholder.com/164x100'),
          Locale(
              name: 'Jardim Botânico',
              imageUrl: 'https://via.placeholder.com/164x100'),
        ];
    }
  }
}
