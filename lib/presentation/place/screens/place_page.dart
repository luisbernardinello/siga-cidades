import 'package:flutter/material.dart';
import 'package:sigacidades/domain/entities/place.dart';
import 'package:map_launcher/map_launcher.dart'; // Importa o map_launcher para abrir apps externos de mapas
import 'package:flutter_svg/flutter_svg.dart'; // Para usar icones SVG do map_launcher (icone do Google Maps e os demais)

// ====================================
// Página de detalhes de um lugar em específico
// ====================================
class PlacePage extends StatelessWidget {
  final Place place; // A instância do lugar selecionado

  const PlacePage({Key? key, required this.place}) : super(key: key);

  // ====================================
  // Função: Abre apps de mapas com o Map Launcher
  // ====================================
  Future<void> _openInMapLauncher(BuildContext context) async {
    final availableMaps = await MapLauncher
        .installedMaps; // Busca os apps de mapas instalados no dispositivo

    // Se existe algum, exibe uma lista de opções
    if (availableMaps.isNotEmpty) {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Wrap(
                // Cria uma lista de apps de mapas do dispositivo
                children: availableMaps.map((map) {
                  return ListTile(
                    // Ao clicar, abre o mapa selecionado com o marcador do lugar
                    onTap: () {
                      map.showMarker(
                        coords: Coords(
                          place.coordinates.latitude,
                          place.coordinates.longitude,
                        ),
                        title: place
                            .name, // Passa parao app de mapa o título do lugar
                        description:
                            place.adress, // Passa o endereço na descrição
                      );
                      Navigator.pop(context); // Fecha o modal depois
                    },
                    // Nome do app de mapas (ex: Google Maps, Waze, etc.)
                    title: Text(map.mapName),
                    // Ícone do app de mapas
                    leading: SvgPicture.asset(
                      map.icon,
                      height: 30, // Tamanho do ícone
                      width: 30,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    } else {
      // Se não houver apps de mapas disponíveis, exibe uma mensagem
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum aplicativo de mapas encontrado.'),
        ),
      );
    }
  }

  // ====================================
  // Widget build: Faz a interface da página
  // ====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinhamento na esquerda
          children: [
            Stack(
              children: [
                // ====================================
                // Imagem do lugar
                // ====================================
                Image.network(
                  place.imageUrl, // URL da imagem do lugar
                  width: double.infinity, // Largura total da tela
                  height: 250, // Altura fixa da imagem
                  fit: BoxFit
                      .cover, // A imagem cobre todo o espaço sem distorcer
                ),

                // ====================================
                // Botão "Voltar" posicionado sobre a imagem
                // ====================================
                Positioned(
                  top: 40, // Margem superior
                  left: 16, // Margem esquerda
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Volta para a pagina anterior
                    },
                    child: Container(
                      padding: const EdgeInsets.all(
                          8), // Espaçamento interno do botão
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(
                            0.5), // Fundo com um pouco de transparência
                        shape: BoxShape.circle, // Forma circular do botão
                      ),
                      child: const Icon(
                        Icons
                            .arrow_back, // Ícone de de seta para a esquerda, para voltar
                        color: Colors.white, // Cor branca para contraste
                        size: 24, // Tamanho do ícone
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ====================================
            // Conteúdo
            // ====================================
            Padding(
              padding: const EdgeInsets.all(
                  16.0), // Espaçamento ao redor do conteúdo
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Alinha o texto na esquerda
                children: [
                  // ====================================
                  // Nome do lugar (título principal)
                  // ====================================
                  Text(
                    place.name, // Nome do lugar
                    style: const TextStyle(
                      fontSize: 24, // Tamanho grande para destaque
                      fontWeight: FontWeight.bold, // Negrito para destaque
                    ),
                  ),
                  const SizedBox(
                      height: 8), // Espaçamento vertical entre os textos

                  // ====================================
                  // Cidade do lugar
                  // ====================================
                  Text(
                    'Cidade: ${place.city}', // Exibe a cidade
                    style: TextStyle(
                      fontSize: 18, // Tamanho médio
                      color: Colors.grey[600], // Cor cinza para o texto
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ====================================
                  // Endereço do lugar
                  // ====================================
                  Text(
                    'Endereço: ${place.adress}', // Exibe o endereço
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500, // Negrito
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ====================================
                  // Descrição do lugar
                  // ====================================
                  Text(
                    place.description, // Exibe a descrição do lugar
                    style: const TextStyle(
                      fontSize: 16, // Tamanho normal
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ====================================
                  // Botão: "Abrir localização"
                  // ====================================
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _openInMapLauncher(
                          context), // chama o método de abrir map_launcher
                      icon: const Icon(Icons.map), // Ícone de mapa no botão
                      label: const Text('Abrir localização'), // Texto no botão
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12), // Margem interna do botão
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
