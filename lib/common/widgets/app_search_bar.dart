import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';

// Widget Stateful que implementa a barra de busca personalizada.
// Permite que o usuário pesquise locais com base na cidade selecionada e realiza a busca no repositório.
class AppSearchBar extends StatefulWidget {
  final VoidCallback onMenuTap; // Callback para abrir o Drawer.
  final PlaceRepository
      placeRepository; // Instância do repositório para poder buscar os locais.

  const AppSearchBar({
    Key? key,
    required this.onMenuTap,
    required this.placeRepository,
  }) : super(key: key);

  @override
  _AppSearchBarState createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  // Controlador do campo de texto.
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    // Garante que o controlador de texto seja limpo quando o widget for destruído.
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<CategoryBloc>() para ficar observando (watch) o estado do BLoC e pegar a cidade selecionada.
    final state = context.watch<CategoryBloc>().state;

    // selectedCity inicializa a cidade selecionada com base no estado atual do BLoC, campo que pode ser nulo.
    String? selectedCity;
    if (state is CategoryLoaded) {
      // se houver locais carregados, usa a cidade do primeiro local como padrão.
      selectedCity = state.filteredPlaces.isNotEmpty
          ? state.filteredPlaces.first.city
          : context.read<CategoryBloc>().selectedCity; // Cidade padrão do BLoC.
    }

    // ====================================
    // Construção da interface do AppSearchBar
    // ====================================
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
          // ====================================
          // Ícone do menu para abrir o Drawer
          // ====================================
          GestureDetector(
            onTap: widget.onMenuTap, // Chama o callback para abrir o Drawer.
            child: Icon(Icons.menu, color: Color(0xFF080808)),
          ),
          const SizedBox(width: 12),

          // ====================================
          // Campo de texto para pesquisa
          // ====================================
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
                // Mostra a cidade selecionada no placeholder.
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

          // ====================================
          // Botão de pesquisa
          // ====================================
          GestureDetector(
            onTap: () {
              _showSearchModal(context, _searchController.text, selectedCity);
              // Dá inicio a busca ao clicar no ícone da barra de pesquisa.
            },
            child: Icon(Icons.search, color: Color(0xFF131313)),
          ),
        ],
      ),
    );
  }

  // ====================================
  // Função que exibe modal: Exibir resultados da pesquisa
  // ====================================

  void _showSearchModal(
      BuildContext context, String query, String? selectedCity) async {
    // Verifica se existe uma pesquisa e cidade selecionada.
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

    // removeDiacritics chama o removeDiacritics passando a query para normalizar a string de busca, remove acentos deixa tudo minúsculo.
    final normalizedQuery = removeDiacritics(query).toLowerCase();

    // Busca os locais no repositório pela cidade selecionada.
    final allPlaces =
        await widget.placeRepository.fetchPlacesByCity(selectedCity);

    // Filtra os locais encontrados pela pesquisa.
    final searchResults = allPlaces
        .where((place) => removeDiacritics(place.name.toLowerCase())
            .contains(normalizedQuery))
        .toList();

    // Se não existir resultados, cria um lugar chamado não encontrado.
    if (searchResults.isEmpty) {
      searchResults.add(
        Place(
          name: 'Local não encontrado',
          imageUrl: 'https://via.placeholder.com/164x100',
          city: '',
        ),
      );
    }

    // ====================================
    // Exibe a janela modal com os resultados da pesquisa
    // ====================================
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
                'Resultados da Pesquisa para $selectedCity',
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
                        // Quando o usuário clica em um resultado, fecha a janela modal e vai para a página de lugar (exibe o lugar selecionado).
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
