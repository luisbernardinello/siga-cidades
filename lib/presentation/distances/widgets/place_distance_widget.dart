import 'package:flutter/material.dart';
import 'package:sigacidades/domain/entities/place.dart';

// ====================================
// Widget para as distâncias dos lugares
// ====================================
class PlaceDistanceWidget extends StatelessWidget {
  final Place place;
  final double distance;

  const PlaceDistanceWidget({
    Key? key,
    required this.place, // Instância do lugar que será exibido
    required this.distance, // Distância calculada do lugar em relação ao usuário
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 16), // Margem ao redor do card
      child: ListTile(
        title: Text(
          place.name, // Nome do lugar exibido como título
          style:
              const TextStyle(fontWeight: FontWeight.bold), // Texto em negrito
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinha o conteúdo na esquerda
          children: [
            Text(
                '${place.category} - ${place.city}'), // Exibe a categoria e a cidade
            // Exibe a distância formatada (em metros ou quilômetros)
            Text(
              _formatDistance(distance), // Formata a distância
              style: const TextStyle(
                color:
                    Color(0xFFFFA500), // Cor laranja escuro para acessibilidade
                fontWeight: FontWeight.w600, // Negrito
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função que formata a distância: se menor que 1000 metros, exibe em metros, caso contrário será em quilômetros.
  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} metros'; // Exibe em metros sem as nenhuma casa decimal decimais
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km'; // Exibe em quilômetros com 2 casas decimais
    }
  }
}
