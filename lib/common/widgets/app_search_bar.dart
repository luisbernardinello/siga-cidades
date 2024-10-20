import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';

class AppSearchBar extends StatefulWidget {
  final VoidCallback onMenuTap;
  final PlaceRepository placeRepository;

  const AppSearchBar({
    Key? key,
    required this.onMenuTap,
    required this.placeRepository,
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
    // Obtemos o estado atual do CategoryBloc para usar a cidade selecionada
    final state = context.watch<CategoryBloc>().state;

    // Cidade selecionada no estado atual
    String? selectedCity;
    if (state is CategoryLoaded) {
      selectedCity = context.read<CategoryBloc>().selectedCity;
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center, // Alinhamento vertical correto
      children: [
        // Ícone do Drawer (fora da barra de busca)
        GestureDetector(
          onTap: widget.onMenuTap,
          child: Container(
            width: 32,
            height: 32,
            alignment:
                Alignment.center, // Centraliza o ícone dentro do container
            child: Icon(Icons.menu, color: Color(0xFF080808)),
          ),
        ),
        const SizedBox(width: 12),

        // Campo de busca (separado do ícone do menu)
        Expanded(
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFFE4E4E4),
            ),
            child: Row(
              children: [
                // Campo de texto para busca
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: InputDecoration(
                      hintText: selectedCity != null
                          ? 'Pesquise por locais em $selectedCity'
                          : 'Pesquise por locais',
                      hintStyle: const TextStyle(
                        color: Color(0xFF737373),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botão de pesquisa (ícone de lupa)
                GestureDetector(
                  onTap: () {
                    _showSearchModal(
                        context, _searchController.text, selectedCity);
                  },
                  child: const Icon(Icons.search, color: Color(0xFF131313)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Exibe o modal com os resultados da pesquisa
  void _showSearchModal(
      BuildContext context, String query, String? selectedCity) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite algo para pesquisar.')),
      );
      return;
    }

    if (selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione uma cidade antes de pesquisar.')),
      );
      return;
    }

    final normalizedQuery = removeDiacritics(query).toLowerCase();
    final allPlaces =
        await widget.placeRepository.fetchPlacesByCity(selectedCity);

    final searchResults = allPlaces
        .where((place) => removeDiacritics(place.name.toLowerCase())
            .contains(normalizedQuery))
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Resultados da Pesquisa para $selectedCity',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Verifica se a lista de resultados está vazia
              if (searchResults.isEmpty)
                Align(
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
                      return ListTile(
                        title: Text(place.name),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlacePage(place: place),
                            ),
                          );
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
