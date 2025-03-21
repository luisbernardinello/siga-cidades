import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/rendering.dart';
// Adicionado para SemanticsService
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sigacidades/core/utils/privacy_policy_text.dart';
import 'package:sigacidades/core/utils/terms_of_use_text.dart';

class AboutPage extends StatefulWidget {
  // Alterado para StatefulWidget
  static const routeName = '/about';

  // Adicionando o parâmetro focusNode
  final FocusNode? focusNode;

  const AboutPage({super.key, this.focusNode});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  // Adicionando FocusNode para o conteúdo principal
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Configura para inicializar o foco no conteúdo quando a página recebe foco
    if (widget.focusNode != null) {
      widget.focusNode?.addListener(_handlePageFocus);
    }
  }

  void _handlePageFocus() {
    // Quando a página recebe foco da navegação, transfere o foco para o conteúdo
    if (widget.focusNode != null && widget.focusNode!.hasFocus) {
      Future.microtask(() {
        if (mounted) {
          _contentFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    // Removendo o listener do focusNode da página
    if (widget.focusNode != null) {
      widget.focusNode?.removeListener(_handlePageFocus);
    }

    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    double paddingHorizontal = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
    double fontSize = isDesktop ? 18 : 16;
    double buttonFontSize = isDesktop ? 16 : 14;

    return Focus(
      focusNode: widget.focusNode,
      child: Semantics(
        label:
            'Conteúdo com informações gerais sobre o aplicativo, e formas de contato com o laboratório biblioteca falada',
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          child: SingleChildScrollView(
            child: Focus(
              // Adicionando Focus wrapper para o conteúdo principal
              focusNode: _contentFocusNode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    label: "Sobre Nós",
                    excludeSemantics: true,
                    child: Text(
                      'Sobre nós',
                      style: TextStyle(
                        color: const Color(0xFF080808),
                        fontSize: fontSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  Text(
                    "O SIGA - Guia Acessível da Cidade é um aplicativo mobile que visa oferecer informações de pontos de interesse do município, como praças, ruas, avenidas, prédios, equipamentos públicos e espaços de lazer. O seu diferencial é apresentar os dados por meio de áudios com informações gerais e, principalmente, audiodescrição detalhada de aspectos físicos e estéticos de cada local, como estilo arquitetônico, características estruturais e dimensões. Cada arquivo pode ser acessado em um mapa, o que permite ao usuário relacionar os pontos de interesse e sua localização na cidade.",
                    style: TextStyle(
                      color: const Color(0xFF080808),
                      fontSize: fontSize,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "O aplicativo busca oferecer informação acessível e diversificada e, dessa maneira, contribuir para que as pessoas conheçam melhor a cidade e possam experienciá-la com mais autonomia e independência. Nesse sentido, tem como público preferencial (mas não exclusivo) o de pessoas com deficiência visual, principalmente porque oferece o diferencial da audiodescrição e do formato sonoro dos arquivos.",
                    style: TextStyle(
                      color: const Color(0xFF080808),
                      fontSize: fontSize,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "O SIGA Guia Acessível da Cidade é uma iniciativa do projeto de extensão universitária Biblioteca Falada, da Faculdade de Arquitetura, Artes, Comunicação e Design (FAAC), da Universidade Estadual Paulista 'Júlio de Mesquita Filho' (Unesp), câmpus Bauru (SP). O projeto desenvolve ações no campo da acessibilidade à comunicação e à informação, em especial voltadas às pessoas com deficiência visual. Para tanto, produz mídia sonora acessível e audiodescrição, bem como atua na difusão do conhecimento sobre deficiência, tecnologias assistivas, Desenho Universal e comunicação acessível.",
                    style: TextStyle(
                      color: const Color(0xFF080808),
                      fontSize: fontSize,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Color(0xFFE4E4E4)),
                  const SizedBox(height: 8),
                  const Contacts(),
                  const SizedBox(height: 15),

                  // Linha divisória
                  const Divider(color: Color(0xFFE4E4E4)),
                  const SizedBox(height: 15),

                  // Botões de Política de Privacidade e Termos de Uso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(
                        context,
                        title: "Política de Privacidade",
                        onPressed: () => _showModal(
                          context,
                          "Política de Privacidade",
                          privacyPolicyText,
                        ),
                        fontSize: buttonFontSize,
                      ),
                      const SizedBox(width: 8),
                      _buildButton(
                        context,
                        title: "Termos de Uso",
                        onPressed: () => _showModal(
                          context,
                          "Termos de Uso",
                          termsOfUseText,
                        ),
                        fontSize: buttonFontSize,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String title,
    required VoidCallback onPressed,
    required double fontSize,
  }) {
    // Definir a largura do botão de acordo com o tipo de dispositivo
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    double buttonWidth;
    if (isDesktop) {
      buttonWidth = 200; // largura fixa para desktop
    } else if (isTablet) {
      buttonWidth = 180; // largura fixa para tablet
    } else {
      buttonWidth = 160; // largura fixa para celular
    }

    return Center(
      child: SizedBox(
        width: buttonWidth,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(
                0xFFae35c1), // Cor atualizada para #ae35c1 que segue o WCAG
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: onPressed,
          child: Center(
            child: AutoSizeText(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              minFontSize: fontSize - 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  void _showModal(BuildContext context, String title, String content) {
    final FocusNode modalFocusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // Anuncia o título ao abrir a modal
        SemanticsService.announce(
          'Mostrando janela de $title',
          TextDirection.ltr,
        );

        return FocusScope(
          autofocus: true,
          node: FocusScopeNode(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botão de fechar com foco
                    Focus(
                      focusNode: modalFocusNode,
                      child: Semantics(
                        label: 'Voltar.',
                        hint: 'Toque para voltar para a página Sobre.',
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.close),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Título da modal
                    Expanded(
                      child: Text(
                        title,
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
                // Conteúdo do texto
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      content,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) => modalFocusNode.dispose());
  }
}

// Mantenha a classe Contacts como está

class Contacts extends StatelessWidget {
  const Contacts({super.key});

  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get isDesktop =>
      kIsWeb ||
      (!isMobile && Platform.isLinux || Platform.isMacOS || Platform.isWindows);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          Semantics(
            label: 'Link para contatar o Biblioteca Falada por e-mail.',
            hint: 'Toque para enviar-nos um e-mail',
            excludeSemantics: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildContactIcon(
                  icon: Icons.email_outlined,
                  color: const Color(
                      0xFFae35c1), // Cor de contraste ajustada #ae35c1 seguindo o WCAG
                  size: isMobile ? 36 : 42,
                  onTap: () => _launchMail(context),
                ),
                const SizedBox(width: 21.0),
                InkWell(
                  child: Text(
                    "bibliotecafalada@gmail.com",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                  onTap: () => _launchMail(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          GridView.count(
            crossAxisCount: isMobile ? 2 : 4,
            shrinkWrap: true,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Semantics(
                label: 'Link para o site Biblioteca Falada.',
                hint: 'Toque para abrir o site do Biblioteca Falada',
                excludeSemantics: true,
                child: _buildGridItem(
                  title: "Site Biblioteca Falada",
                  imageUrl:
                      'https://firebasestorage.googleapis.com/v0/b/sigacidades.appspot.com/o/image%2Flogos%2Flogo_bf.png?alt=media&token=82c974cd-e14f-4b4b-b221-9ee4737f3cd3',
                  onTap: () =>
                      _launchUrl(context, 'https://bibliotecafalada.unesp.br/'),
                  size: size,
                ),
              ),
              Semantics(
                label: 'Link para o perfil do Instagram do Biblioteca Falada.',
                hint: 'Toque para abrir o perfil no Instagram',
                excludeSemantics: true,
                child: _buildGridItem(
                  title: "Instagram",
                  imageUrl:
                      'https://firebasestorage.googleapis.com/v0/b/sigacidades.appspot.com/o/image%2Flogos%2Flogo_instagram.png?alt=media&token=12ee4900-0279-45f3-a62b-3660fb4fc652',
                  onTap: () =>
                      _launchUrl(context, 'https://www.instagram.com/bfalada/'),
                  size: size,
                ),
              ),
              Semantics(
                label: 'Link para a página do Facebook do Biblioteca Falada.',
                hint: 'Toque para abrir a página no Facebook',
                excludeSemantics: true,
                child: _buildGridItem(
                  title: "Facebook",
                  imageUrl:
                      'https://firebasestorage.googleapis.com/v0/b/sigacidades.appspot.com/o/image%2Flogos%2Flogo_facebook.png?alt=media&token=d210d8ca-bcb4-4d93-8eeb-85710533f261',
                  onTap: () => _launchUrl(
                      context, 'https://www.facebook.com/bibliotecafalada/'),
                  size: size,
                ),
              ),
              Semantics(
                label: 'Link para o perfil do Twitter do Biblioteca Falada.',
                hint: 'Toque para abrir o perfil no Twitter',
                excludeSemantics: true,
                child: _buildGridItem(
                  title: "Twitter",
                  imageUrl:
                      'https://firebasestorage.googleapis.com/v0/b/sigacidades.appspot.com/o/image%2Flogos%2Flogo_x.png?alt=media&token=0b6aeab8-2279-4a05-b331-5b2687797e91',
                  onTap: () => _launchUrl(context, 'https://x.com/BFalada'),
                  size: size,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactIcon({
    required IconData icon,
    required Color color,
    required double size,
    required void Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, size: size, color: color),
    );
  }

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
              fontSize: isMobile ? (size.width * 0.042) : (size.width * 0.030),
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  void _launchMail(BuildContext context) async {
    // Referência ao ScaffoldMessengerState antes do await (para não usar o context depois de execução assíncrona)
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    const mail = 'mailto:bibliotecafalada@gmail.com';
    if (await canLaunchUrlString(mail)) {
      await launchUrlString(mail, mode: LaunchMode.externalApplication);
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Não encontrado aplicativo de envio de e-mail no dispositivo.',
          ),
        ),
      );
    }
  }

  void _launchUrl(BuildContext context, String url) async {
    // Referência ao ScaffoldMessengerState antes do await (para não usar o context depois de execução assíncrona)
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o link.'),
        ),
      );
    }
  }
}
