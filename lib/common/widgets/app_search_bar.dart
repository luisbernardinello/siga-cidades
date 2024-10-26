import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';

// ====================================
// AppSearchBar: Barra de pesquisa customizada
// ====================================
// AppSearchBar é o widget que permite ao usuário pesquisar lugares com base na cidade selecionada no drawer
// É utilizado aqui o CategoryBloc para obter a cidade selecionada
// e o resultado é filtrado na busca de acordo com o nome dos lugares (para a cidade selecionada)
class AppSearchBar extends StatefulWidget {
  final VoidCallback onMenuTap; // Callback para abrir o Drawer.
  final PlaceRepository placeRepository; // Repository para buscar os lugares.
  final String? selectedCity; // Cidade selecionada passada pelo main screen

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
  // Controlador para receber o texto digitado pelo usuário no campo de pesquisa.
  final TextEditingController _searchController = TextEditingController();

  // Limpa o controlador
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ====================================
    // Recebe o estado atual do CategoryBloc
    // ====================================
    // CategoryBloc para determinar qual cidade foi selecionada
    final state = context.watch<CategoryBloc>().state;

    // Cidade atualmente selecionada pelo usuário.
    // Atualiza a cidade com base no CategoryBloc do estado da cidade passada do MainScreen.
    // Utilizamos Bauru como cidade padrão para a pesquisa
    String selectedCity = widget.selectedCity ?? 'Bauru';
    if (state is CategoryLoaded) {
      selectedCity = context.read<CategoryBloc>().selectedCity;
    }

    // ====================================
    // Layout da AppSearchBar
    // ====================================
    // A barra de pesquisa contem um ícone de menu na esquerda e um
    // campo de texto na direita no qual o usuário pode digitar a busca.
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center, // Alinhamento vertical dos elementos.
      children: [
        // ====================================
        // Ícone do Drawer
        // ====================================
        // O ícone permite ao usuário abrir o DrawerMenu.
        GestureDetector(
          onTap: widget.onMenuTap, // Abre o Drawer quando clicado.
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center, // Centraliza o ícone no container.
            child: const Icon(Icons.menu, color: Color(0xFF080808)),
          ),
        ),
        const SizedBox(width: 12), // Espaço entre o ícone e o campo de busca.

        // ====================================
        // Campo de busca
        // ====================================
        // O campo de busca permite que o usuário digite o nome de um local
        // e faça uma pesquisa. O contexto da pesquisa é a cidade selecionada.
        Expanded(
          child: Container(
            height: 56, // Altura do campo de busca.
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24), // Borda arredondada.
              color: const Color(0xFFE4E4E4), // Cor de fundo.
            ),
            child: Row(
              children: [
                // Campo de texto para busca
                Expanded(
                  child: TextField(
                    controller: _searchController, // Controlador do texto.
                    style: const TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: InputDecoration(
                      // Placeholder que indica a cidade selecionada.
                      hintText: 'Pesquise por locais em $selectedCity',
                      hintStyle: const TextStyle(
                        color: Color(0xFF737373),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Espaço antes do ícone de pesquisa.

                // ====================================
                // Ícone de pesquisa (lupa)
                // ====================================
                // Ao clicar no ícone, o modal de resultados da pesquisa é exibido.
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

  // ====================================
  // _showSearchModal: Exibe o modal de resultados da pesquisa
  // ====================================
  // Quando o usuário faz uma pesquisa, o método busca os locais com base
  // no texto digitado e na cidade selecionada. O resultado da busca é
  // mostrado em um modal na parte inferior da tela.
  void _showSearchModal(
      BuildContext context, String query, String selectedCity) async {
    // ====================================
    // Validações para a pesquisa
    // ====================================
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite algo para pesquisar.')),
      );
      return;
    }

    // ====================================
    // Busca pelos locais
    // ====================================
    // Normaliza a string de busca (remove acentos e converte para minusculo)
    // assim garante que a pesquisa não seja sensível
    final normalizedQuery = removeDiacritics(query).toLowerCase();
    final allPlaces =
        await widget.placeRepository.fetchPlacesByCity(selectedCity);

    // Filtra os resultados com base no nome do local.
    final searchResults = allPlaces
        .where((place) => removeDiacritics(place.name.toLowerCase())
            .contains(normalizedQuery))
        .toList();

    // ====================================
    // Exibição dos resultados em um modal
    // ====================================
    // O modal exibe a lista de locais encontrados,
    // ou msg de erro de que nenhum local foi encontrado.
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Título do modal, mostra a cidade pesquisada.
              Text(
                'Resultados da Pesquisa para $selectedCity',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Verifica se existem resultados.
              if (searchResults.isEmpty)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Local não encontrado', // Mensagem de erro.
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                // Lista os resultados da busca.
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final place = searchResults[index];
                      return ListTile(
                        title: Text(place.name),
                        onTap: () {
                          // Ao clicar em um local, vai para a pagina de detalhes do lugar.
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
