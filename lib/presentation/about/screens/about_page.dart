import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

// ====================================
// Classe AboutPage com Contatos (Sobre nós)
// ====================================

class AboutPage extends StatelessWidget {
  static const routeName = '/about';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Seção: Título "Sobre Nós"
              const Text(
                'Sobre',
                style: TextStyle(
                  color: Color(0xFF080808),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "O SIGA - Guia Acessível da Cidade é um aplicativo mobile que visa oferecer informações de pontos de interesse do município, como praças,"
                " ruas, avenidas, prédios, equipamentos públicos e espaços de lazer. O seu diferencial é apresentar os dados por meio de áudios com informações gerais e"
                ", principalmente, audiodescrição detalhada de aspectos físicos e estéticos de cada local, como estilo arquitetônico, características estruturais e dimensões."
                " Cada arquivo pode ser acessado em um mapa, o que permite ao usuário relacionar os pontos de interesse  e sua localização na cidade.",
                style: TextStyle(
                  color: Color(0xFF080808),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "O aplicativo busca oferecer informação acessível e diversificada e, dessa maneira, contribuir para que as pessoas conheçam melhor"
                " a cidade e possam experienciá-la com mais autonomia e independência. Nesse sentido, tem como público preferencial (mas não exclusivo)"
                " o de pessoas com deficiência visual, principalmente porque oferece o diferencial da audiodescrição e do formato sonoro dos arquivos.",
                style: TextStyle(
                  color: Color(0xFF080808),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "O SIGA Guia Acessível da Cidade é uma iniciativa do projeto de extensão universitária Biblioteca Falada, da Faculdade de Arquitetura"
                ", Artes, Comunicação e Design (FAAC), da Universidade Estadual Paulista “Júlio de Mesquita Filho” (Unesp), câmpus Bauru (SP)."
                " O projeto desenvolve ações no campo da acessibilidade à comunicação e à informação, em especial voltadas às pessoas com deficiência visual."
                " Para tanto, produz mídia sonora acessível e audiodescrição, bem como atua na difusão do conhecimento sobre deficiência, tecnologias assistivas,"
                " Desenho Universal e comunicação acessível.",
                style: TextStyle(
                  color: Color(0xFF080808),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 15),
              // Linha divisória
              Container(
                width: double.infinity,
                height: 2,
                color: const Color(0xFFE4E4E4),
              ),
              const SizedBox(height: 8),
              const Contacts(),
            ],
          ),
        ));
  }
}

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = isMobilePlatform(); // Verifica se é mobile

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Contatos',
            style: TextStyle(
              color: Color(0xFF080808),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Botão de e-mail
              _buildContactIcon(
                icon: Icons.email_outlined,
                color: Colors.purple,
                size: 40,
                onTap: () => _launchMail(context),
              ),
              const SizedBox(width: 21.0),
              // Texto de e-mail
              InkWell(
                child: const Text(
                  "bibliotecafalada@gmail.com",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
                onTap: () => _launchMail(context),
              ),
            ],
          ),
          const SizedBox(height: 2),
          // Grid de redes sociais
          GridView.count(
            crossAxisCount: isMobile ? 2 : 4,
            shrinkWrap: true,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            physics:
                const NeverScrollableScrollPhysics(), // Desabilita o scroll do grid
            children: [
              _buildGridItem(
                title: "Site Biblioteca Falada",
                imageUrl:
                    'https://firebasestorage.googleapis.com/v0/b/mapasonoro-ba939.appspot.com/o/image%2Fcategorias%2Flogo_bf.png?alt=media&token=39c6d7b5-dd3d-4561-8266-f5f12f46bb7a',
                onTap: () => _launchUrl('https://bibliotecafalada.unesp.br/'),
                size: size,
              ),
              _buildGridItem(
                title: "Instagram",
                imageUrl:
                    'https://firebasestorage.googleapis.com/v0/b/mapasonoro-ba939.appspot.com/o/image%2Fcategorias%2Finstagram.png?alt=media&token=2912925d-053f-4f65-b1b5-81ba15aaea85',
                onTap: () => _launchUrl('https://www.instagram.com/bfalada/'),
                size: size,
              ),
              _buildGridItem(
                title: "Facebook",
                imageUrl:
                    'https://firebasestorage.googleapis.com/v0/b/mapasonoro-ba939.appspot.com/o/image%2Fcategorias%2Flogo_facebook.png?alt=media&token=4e7e04d0-540b-42cf-8805-0cf07ee3a555',
                onTap: () =>
                    _launchUrl('https://www.facebook.com/bibliotecafalada/'),
                size: size,
              ),
              _buildGridItem(
                title: "Twitter",
                imageUrl:
                    'https://firebasestorage.googleapis.com/v0/b/mapasonoro-ba939.appspot.com/o/image%2Fcategorias%2Flogo_twitter.PNG?alt=media&token=37b0f890-95c3-48e2-8f5c-3d5af156eaeb',
                onTap: () => _launchUrl('https://twitter.com/BFalada'),
                size: size,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para ícone de contato
  Widget _buildContactIcon({
    required IconData icon,
    required Color color,
    required double size,
    required void Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }

  // Widget para item de grid
  Widget _buildGridItem({
    required String title,
    required String imageUrl,
    required void Function() onTap,
    required Size size,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            imageUrl,
            width: size.width * 0.18,
            height: size.height * 0.15,
          ),
          AutoSizeText(
            title,
            semanticsLabel: title,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: isMobilePlatform()
                  ? (size.width * 0.042)
                  : (size.width * 0.030),
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  // Função para abrir o e-mail
  void _launchMail(BuildContext context) async {
    const mail = 'mailto:bibliotecafalada@gmail.com';
    if (await canLaunchUrlString(mail)) {
      await launchUrlString(mail, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Não encontrado aplicativo de envio de e-mail no dispositivo.')),
      );
    }
  }

  // Função para abrir URL externa
  void _launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }
}

// Função para detectar a plataforma
bool isMobilePlatform() {
  return Platform.isAndroid || Platform.isIOS;
}
