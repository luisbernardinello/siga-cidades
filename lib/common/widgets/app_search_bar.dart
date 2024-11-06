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
  AppSearchBarState createState() => AppSearchBarState();
}

class AppSearchBarState extends State<AppSearchBar> {
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
          label: 'Botão do menu superior para escolha de cidades.',
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
                  child: Semantics(
                    focusable: true,
                    label: 'Campo de busca do menu superior',
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
                ),
                Semantics(
                  label: 'Botão de pesquisa do menu superior',
                  hint: 'Clique para buscar locais em $selectedCity',
                  button: false,
                  child: GestureDetector(
                    onTap: () {
                      _executeSearch(context, selectedCity);
                    },
                    child: const Icon(Icons.search, color: Color(0xFF131313)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _executeSearch(BuildContext context, String selectedCity) {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      _showSearchModal(query, selectedCity);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite algo para pesquisar.')),
      );
    }
  }

  void _showSearchModal(String query, String selectedCity) async {
    final normalizedQuery = removeDiacritics(query).toLowerCase();
    final allPlaces =
        await widget.placeRepository.fetchPlacesByCity(selectedCity);
    final searchResults = allPlaces
        .where((place) => removeDiacritics(place.name.toLowerCase())
            .contains(normalizedQuery))
        .toList();

    if (!mounted) return;

    // Exibe o modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return FocusScope(
          node: FocusScopeNode(),
          child: Builder(
            builder: (BuildContext innerContext) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (searchResults.isNotEmpty) {
                  _modalFocusNode.requestFocus();
                  SemanticsService.announce(
                    'Mostrando locais encontrados para "$query" em $selectedCity',
                    TextDirection.ltr,
                  );
                }
              });

              return Container(
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(innerContext).size.height * 0.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Focus(
                          focusNode: _modalFocusNode,
                          autofocus: true,
                          child: Semantics(
                            label: 'Botão de fechar janela de pesquisa',
                            hint: 'Clique para voltar ao campo de busca',
                            button: true,
                            child: GestureDetector(
                              onTap: () {
                                _searchFocusNode.requestFocus();
                                Navigator.pop(innerContext);
                              },
                              child: const Icon(Icons.close),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
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
                          itemBuilder: (innerContext, index) {
                            final place = searchResults[index];
                            return Semantics(
                              label: 'Local encontrado: ${place.name}',
                              hint: 'Toque para mais detalhes',
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
                                  Navigator.pop(innerContext);
                                  Navigator.push(
                                    innerContext,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PlacePage(place: place),
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
              );
            },
          ),
        );
      },
    );
  }
}
