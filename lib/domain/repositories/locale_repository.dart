import 'package:sigacidades/domain/entities/locale.dart';

abstract class LocaleRepository {
  Future<List<Locale>> fetchLocalesByCategory(int categoryIndex);
}
