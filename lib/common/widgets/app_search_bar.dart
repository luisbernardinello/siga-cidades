import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';

class AppSearchBar extends StatefulWidget {
  final VoidCallback onMenuTap;
  final PlaceRepository placeRepository;
  final String? selectedCity;

  const AppSearchBar({
    super.key,
    required this.onMenuTap,
    required this.placeRepository,
    this.selectedCity,
  });

  @override
  _AppSearchBarState createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _modalFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _modalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

    // Estado da cidade selecionada
    final state = context.watch<CategoryBloc>().state;
    String selectedCity = widget.selectedCity ?? 'Bauru';
    if (state is CategoryLoaded) {
      selectedCity = context.read<CategoryBloc>().selectedCity;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Semantics(
          label: 'Botão do menu de cidades',
          hint: 'Clique para escolher a cidade',
          button: false,
          child: GestureDetector(
            onTap: widget.onMenuTap,
            child: Container(
              width: isTablet ? 40 : 32,
              height: isTablet ? 40 : 32,
              alignment: Alignment.center,
              child: const Icon(Icons.menu, color: Color(0xFF080808)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            label: 'Campo de busca',
            hint: 'Pesquisa de locais',
            textField: true,
            child: Container(
              height: isTablet ? 64 : 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFE4E4E4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      style: TextStyle(
                        color: const Color(0xFF737373),
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w300,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Pesquise por locais em $selectedCity',
                        hintStyle: TextStyle(
                          color: const Color(0xFF737373),
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w300,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) {
                        _executeSearch(context, selectedCity);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    label: 'Botão de busca',
                    hint: 'Clique para buscar locais',
                    button: false,
                    child: GestureDetector(
                      onTap: () {
                        _executeSearch(context, selectedCity);
                      },
                      child: const Icon(Icons.search, color: Color(0xFF131313)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _executeSearch(BuildContext context, String selectedCity) {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      _modalFocusNode.requestFocus();
      _showSearchModal(context, query, selectedCity);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite algo para pesquisar.')),
      );
    }
  }

  void _showSearchModal(
      BuildContext context, String query, String selectedCity) async {
    // Anúncio inicial da busca
    SemanticsService.announce(
      'Mostrando locais encontrados para "$query" em $selectedCity',
      TextDirection.ltr,
    );

    final normalizedQuery = removeDiacritics(query).toLowerCase();
    final allPlaces =
        await widget.placeRepository.fetchPlacesByCity(selectedCity);
    final searchResults = allPlaces
        .where((place) => removeDiacritics(place.name.toLowerCase())
            .contains(normalizedQuery))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return FocusScope(
          autofocus: true,
          node: FocusScopeNode(),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botão de fechar
                    Focus(
                      focusNode: _modalFocusNode,
                      child: Semantics(
                        label: 'Botão de fechar janela de pesquisa',
                        hint: 'Clique para voltar ao campo de busca',
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _searchFocusNode.requestFocus();
                          },
                          child: const Icon(Icons.close),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Título da pesquisa
                    Expanded(
                      child: Text(
                        'Resultados da Pesquisa para "$query"',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (searchResults.isEmpty)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Local não encontrado',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final place = searchResults[index];
                        return Semantics(
                          label: 'Local encontrado: ${place.name}',
                          hint:
                              'Clique para ver mais detalhes de ${place.name}',
                          child: ListTile(
                            title: Text(
                              place.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlacePage(place: place),
                                ),
                              );
                            },
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.blueAccent,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
