import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:sigacidades/domain/repositories/locale_repository.dart';
import 'package:sigacidades/domain/entities/locale.dart';

class AppSearchBar extends StatefulWidget {
  final VoidCallback onMenuTap;
  final LocaleRepository localeRepository;

  const AppSearchBar({
    Key? key,
    required this.onMenuTap,
    required this.localeRepository,
  }) : super(key: key);

  @override
  _AppSearchBarState createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Color(0xFFE4E4E4),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onMenuTap,
            child: Icon(Icons.menu, color: Color(0xFF080808)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller:
                  _searchController, // controller para armazenar o texto recebido independente da pagina
              style: TextStyle(
                color: Color(0xFF737373),
                fontSize: 12,
                fontFamily: 'Sora',
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                hintText: 'Pesquise por locais',
                hintStyle: TextStyle(
                  color: Color(0xFF737373),
                  fontSize: 12,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              // onTap executa a pesquisa e abre o modal
              _showSearchModal(context, _searchController.text);
            },
            child: Icon(Icons.search, color: Color(0xFF131313)),
          ),
        ],
      ),
    );
  }

  //  abre o modal com os resultados da pesquisa
  void _showSearchModal(BuildContext context, String query) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Digite algo para pesquisar.')),
      );
      return;
    }

    // diacritics remove os acentos e converte para lowercase para a busca
    final normalizedQuery = removeDiacritics(query).toLowerCase();

    // Precisamos aguardar o resultado da busca de locais, pois a função é assíncrona
    final allLocales = [
      ...await widget.localeRepository.fetchLocalesByCategory(0),
      ...await widget.localeRepository.fetchLocalesByCategory(1),
      ...await widget.localeRepository.fetchLocalesByCategory(2),
    ];

    // filtra os locais
    final searchResults = allLocales
        .where((locale) => removeDiacritics(locale.name.toLowerCase())
            .contains(normalizedQuery))
        .toList();

    if (searchResults.isEmpty) {
      searchResults.add(
        Locale(
            name: 'Local não encontrado',
            imageUrl: 'https://via.placeholder.com/164x100'),
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Resultados da Pesquisa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final locale = searchResults[index];
                    return ListTile(
                      title: Text(locale.name),
                      onTap: () {
                        Navigator.pop(context);
                        // Quando clicar em um resultado, você pode definir a lógica de navegação
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
