import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/data/models/place_model.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_state.dart';
import 'package:sigacidades/presentation/place/screens/place_page.dart';

const Color _primaryColor = Color(0xFFae35c1);
const Color _textColor = Color(0xFF080808);

class AppSearchBar extends StatefulWidget {
  final VoidCallback onMenuTap;
  final PlaceRepository placeRepository;
  final String? selectedCity;
  final VoidCallback onCloseModal;

  const AppSearchBar({
    super.key,
    required this.onMenuTap,
    required this.placeRepository,
    this.selectedCity,
    required this.onCloseModal,
  });

  @override
  AppSearchBarState createState() => AppSearchBarState();
}

class AppSearchBarState extends State<AppSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

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
          hint: 'Toque para escolher a cidade',
          button: true,
          child: Container(
            width: isTablet ? 40 : 32,
            height: isTablet ? 40 : 32,
            alignment: Alignment.center,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.menu, color: _textColor),
              onPressed: widget.onMenuTap,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: isTablet ? 56 : 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFE4E4E4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.search, color: Color(0xFF737373), size: 20),
                ),
                Expanded(
                  child: Semantics(
                    focusable: true,
                    label: 'Campo de busca do menu superior',
                    child: TextField(
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      style: TextStyle(
                        color: const Color(0xFF000000),
                        fontSize: isTablet ? 15 : 13,
                        fontWeight: FontWeight.w400,
                      ),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Pesquise por locais em $selectedCity',
                        hintStyle: TextStyle(
                          color: const Color(0xFF737373),
                          fontSize: isTablet ? 15 : 13,
                          fontWeight: FontWeight.w300,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) {
                        _executeSearch(context, selectedCity);
                      },
                    ),
                  ),
                ),
                Semantics(
                  label: 'Botão de enviar pesquisa',
                  hint: 'Toque para buscar locais em $selectedCity',
                  button: true,
                  child: GestureDetector(
                    onTap: () {
                      _executeSearch(context, selectedCity);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6D6D6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Color(0xFF737373),
                        size: 20,
                      ),
                    ),
                  ),
                ),
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
      _searchFocusNode.unfocus();
      _searchController.clear();
      SemanticsService.announce(
        'Abrindo janela de pesquisa',
        TextDirection.ltr,
      );
      _showSearchModal(query, selectedCity);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite algo para pesquisar.')),
      );
    }
  }

  void _showSearchModal(String query, String selectedCity) async {
    final normalizedQuery = removeDiacritics(query).toLowerCase();

    // Sinal de carregamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
        ),
      ),
    );

    try {
      // Pega todos os lugares da cidade especificada
      final allPlaces =
          await widget.placeRepository.fetchPlacesByCity(selectedCity);

      // Fecha o sinal de carregamento
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      // Filtra os lugares sem campos inválidos
      final searchResults = allPlaces.where((place) {
        final isValidPlace = (place as PlaceModel)
            .getInvalidFields()
            .isEmpty; // Filtra somente os lugares que são válidos
        final matchesQuery = removeDiacritics(place.name.toLowerCase())
            .contains(normalizedQuery);
        return matchesQuery && isValidPlace;
      }).toList();

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return _buildSearchResultsModal(
              bc, query, selectedCity, searchResults);
        },
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar locais: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildSearchResultsModal(
    BuildContext context,
    String query,
    String selectedCity,
    List<dynamic> searchResults,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.1,
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              // Botão fechar
              MergeSemantics(
                child: Semantics(
                  focused: false,
                  focusable: true,
                  label: 'Fechar resultados da busca',
                  hint: 'Toque duas vezes para fechar a janela de busca',
                  button: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onCloseModal();
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: _textColor,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Título
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MergeSemantics(
                      child: Semantics(
                        focused: false,
                        focusable: true,
                        header: true,
                        label: 'Resultados de busca',
                        excludeSemantics: true,
                        child: const Text(
                          'Resultados de busca',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtítulo - Agora focável para leitor de tela
                    MergeSemantics(
                      child: Semantics(
                        focused: false,
                        focusable: true,
                        label: 'Termo da busca: $query em $selectedCity',
                        excludeSemantics: true,
                        child: Text(
                          '"$query" em $selectedCity',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (searchResults.isNotEmpty)
                // Contador de resultados - Agora focável para leitor de tela
                MergeSemantics(
                  child: Semantics(
                    focused: false,
                    focusable: true,
                    label: '${searchResults.length} locais encontrados',
                    excludeSemantics: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${searchResults.length}',
                        style: const TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          if (searchResults.isEmpty)
            _buildEmptyResults()
          else
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: _buildSearchResultsList(context, searchResults),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MergeSemantics(
            child: Semantics(
              focused: false,
              focusable: true,
              label: 'Ícone de nenhum resultado encontrado',
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 68,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Texto principal com semântica apropriada
          MergeSemantics(
            child: Semantics(
              focused: false,
              focusable: true,
              label: 'Nenhum local encontrado',
              child: const Text(
                'Nenhum local encontrado',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          MergeSemantics(
            child: Semantics(
              focused: false,
              focusable: true,
              label: 'Tente buscar por outras palavras-chave',
              child: Text(
                'Tente buscar por outras palavras-chave',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList(
      BuildContext context, List<dynamic> searchResults) {
    return Scrollbar(
      thickness: 6,
      radius: const Radius.circular(8),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: searchResults.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final place = searchResults[index];
          return MergeSemantics(
            child: Semantics(
              focused: false,
              focusable: true,
              label:
                  '${place.name}: Resultado ${index + 1} de ${searchResults.length} locais encontrados',
              hint: 'Toque duas vezes para ver detalhes deste local',
              excludeSemantics: true,
              child: _buildPlaceItem(context, place, index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceItem(BuildContext context, dynamic place, int index) {
    return Hero(
      tag: 'place_${place.name ?? index}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: _primaryColor.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  SemanticsService.announce(
                    '${place.name} selecionado, carregando detalhes do local.',
                    TextDirection.ltr,
                  );
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacePage(place: place),
                    ),
                  );
                },
                splashColor: _primaryColor.withOpacity(0.1),
                highlightColor: _primaryColor.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _primaryColor.withOpacity(0.2),
                              _primaryColor.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.place_rounded,
                          color: _primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              place.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _textColor,
                              ),
                              minFontSize: 14,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (place.adress != null && place.adress.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        place.adress,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: _primaryColor,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
