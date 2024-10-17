import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';

class AppSearchBar extends StatefulWidget {
  final VoidCallback onMenuTap;
  final PlaceRepository placeRepository;

  const AppSearchBar({
    // construtor, campos requeridos
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
    // pega o estado atual do BLoC para acessar a cidade selecionada
    final state = context.watch<CategoryBloc>().state;

    // inicia a cidade selecionada com base no estado do BLoC
    String? selectedCity;
    if (state is CategoryLoaded) {
      selectedCity = state.filteredPlaces.isNotEmpty
          ? state.filteredPlaces.first.city
          : context.read<CategoryBloc>().selectedCity; // usa a cidade do BLoC
    }

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
              controller: _searchController,
              style: TextStyle(
                color: Color(0xFF737373),
                fontSize: 12,
                fontFamily: 'Sora',
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                // se selectedCity for null, exibe um hint padrão sem o nome da cidade
                hintText: selectedCity != null
                    ? 'Pesquise por locais em $selectedCity'
                    : 'Pesquise por locais',
                hintStyle: TextStyle(
                  color: Color.fromARGB(255, 94, 93, 93),
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
              // passa a cidade selecionada como parâmetro para o modal
              _showSearchModal(context, _searchController.text, selectedCity);
            },
            child: Icon(Icons.search, color: Color(0xFF131313)),
          ),
        ],
      ),
    );
  }

  // função pra abrir o modal com os resultados da pesquisa
  void _showSearchModal(
      BuildContext context, String query, String? selectedCity) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Digite algo para pesquisar.')),
      );
      return;
    }

    if (selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione uma cidade antes de pesquisar.')),
      );
      return;
    }

    final normalizedQuery = removeDiacritics(query).toLowerCase();

    // busca todos os locais da cidade direto do repositorio
    final allPlaces =
        await widget.placeRepository.fetchPlacesByCity(selectedCity);

    // filtra os locais de acordo com a pesquisa
    final searchResults = allPlaces
        .where((place) => removeDiacritics(place.name.toLowerCase())
            .contains(normalizedQuery))
        .toList();

    // gambiarra que cria um local com o nome do local como não encontrado caso a pesquisa não encontre nada
    if (searchResults.isEmpty) {
      searchResults.add(
        Place(
          name: 'Local não encontrado',
          imageUrl: 'https://via.placeholder.com/164x100',
          city: '',
        ),
      );
    }
    //mostra a modal
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
                selectedCity != null
                    ? 'Resultados da Pesquisa para $selectedCity'
                    : 'Resultados da Pesquisa',
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
                    final place = searchResults[index];
                    return ListTile(
                      title: Text(place.name),
                      onTap: () {
                        Navigator.pop(context);
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
