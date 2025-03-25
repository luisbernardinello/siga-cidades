import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sigacidades/core/utils/feedback_email_text.dart';
import 'dart:io';
import 'package:logging/logging.dart';

class FeedbackPage extends StatefulWidget {
  static const routeName = '/feedback';

  // Adicionando o parâmetro focusNode
  final FocusNode? focusNode;

  const FeedbackPage({super.key, this.focusNode});

  @override
  FeedbackPageState createState() => FeedbackPageState();
}

class FeedbackPageState extends State<FeedbackPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  // FocusNodes para cada campo
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _feedbackFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  final _logger = Logger('FeedbackEmail');
  static final RegExp namePattern = RegExp('[a-zA-Z]');
  static final RegExp emailPattern = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  @override
  void initState() {
    super.initState();

    // Monitora mudanças no estado de foco
    _nameFocusNode.addListener(_onFocusChange);
    _emailFocusNode.addListener(_onFocusChange);
    _feedbackFocusNode.addListener(_onFocusChange);

    // Configura para inicializar o foco no primeiro campo quando a página recebe foco
    if (widget.focusNode != null) {
      widget.focusNode?.addListener(_handlePageFocus);
    }
  }

  void _handlePageFocus() {
    // Quando a página recebe foco da navegação, transfere o foco para o primeiro campo
    if (widget.focusNode != null && widget.focusNode!.hasFocus) {
      Future.microtask(() {
        if (mounted) {
          _nameFocusNode.requestFocus();
        }
      });
    }
  }

  void _onFocusChange() {
    // Função vazia para impedir que o sistema feche o teclado automaticamente
    // Mantemos essa função para garantir que os listeners façam efeito
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _feedbackController.dispose();

    // Limpar os FocusNodes ao destruir o widget
    _nameFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.removeListener(_onFocusChange);
    _feedbackFocusNode.removeListener(_onFocusChange);

    // Removendo o listener do focusNode da página
    if (widget.focusNode != null) {
      widget.focusNode?.removeListener(_handlePageFocus);
    }

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _feedbackFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  String? _validateName(String? name) {
    if (name == null || name.isEmpty) {
      return "Informe o seu nome!";
    } else if (!namePattern.hasMatch(name)) {
      return "O nome deve conter apenas letras";
    }
    return null;
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Informe o seu e-mail!";
    } else if (!emailPattern.hasMatch(email)) {
      return "E-mail inválido!";
    }
    return null;
  }

  String? _validateFeedback(String? feedback) {
    if (feedback == null || feedback.isEmpty) {
      return "Digite sua mensagem!";
    }
    return null;
  }

  Future<void> _sendEmail(String name, String email, String message) async {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Envio de e-mail não suportado neste dispositivo.'),
          ),
        );
      }
      return;
    }

    String? username = dotenv.env['EMAIL_USERNAME'];
    String? password = dotenv.env['EMAIL_PASSWORD'];

    if (username == null || password == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Credenciais de e-mail não carregadas corretamente."),
          ),
        );
      }
      return;
    }

    String device = !kIsWeb && Platform.isAndroid
        ? 'Android'
        : !kIsWeb && Platform.isIOS
            ? 'iOS'
            : 'Outro';

    final smtpServer = gmail(username, password);

    final emailMessage = Message()
      ..from = Address(username, 'Sigacidades Feedback')
      ..recipients.add('nuvembf@gmail.com')
      ..subject = 'Feedback enviado por $name'
      ..html = generateFeedbackEmailHTML(name, email, message, device);

    try {
      final sendReport = await send(emailMessage, smtpServer);
      _logger.info('E-mail enviado: $sendReport');

      if (mounted) {
        _showSuccessDialog();
      }
    } on MailerException catch (e) {
      _logger.severe('Erro ao enviar e-mail', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar feedback.')),
        );
      }
    }
  }

  Future<void> _sendFeedback() async {
    // Primeiro, desfocamos o teclado para evitar erros de UI
    _feedbackFocusNode.unfocus();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final String name = _nameController.text;
      final String email = _emailController.text;
      final String feedback = _feedbackController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviando feedback, por favor aguarde.')),
      );

      await _sendEmail(name, email, feedback);

      _nameController.clear();
      _emailController.clear();
      _feedbackController.clear();
    }
  }

  Future<void> _showSuccessDialog() async {
    SemanticsService.announce(
      'Feedback enviado com sucesso. Janela de confirmação aberta.',
      TextDirection.ltr,
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Focus(
                focusNode: _contentFocusNode,
                child: Semantics(
                  label: 'Voltar.',
                  hint: 'Toque para voltar à página de Feedback.',
                  button: true,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.close),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Text(
                  'Obrigado!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          content: const Text('Seu feedback foi enviado com sucesso!'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    double padding = isDesktop ? 32.0 : 16.0;
    double fontSize = isDesktop ? 19 : (isTablet ? 17 : 15);
    double buttonPadding = isDesktop ? 18 : 14;
    double fieldWidth = isDesktop ? 600 : double.infinity;
    final double buttonFontSize = isDesktop ? 20 : 18;
    final double buttonWidth = isDesktop ? 200 : 160;

    // Usamos GestureDetector para evitar que toques fora dos campos removam o foco
    return Focus(
      focusNode: widget.focusNode,
      child: GestureDetector(
        onTap: () {
          // Não remove o foco ao tocar fora dos campos
          // Isso manterá o teclado aberto
        },
        child: Semantics(
          label:
              'Conteúdo para envio de feedback sobre o aplicativo. Preencha os campos para enviar o seu feedback',
          child: SingleChildScrollView(
            // Essa configuração ajuda a manter os campos visíveis quando o teclado está aberto
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Focus(
                      focusNode: _nameFocusNode,
                      child: Semantics(
                        header: true,
                        label: 'Feedback',
                        excludeSemantics: true,
                        child: Text(
                          'Envie o seu feedback:',
                          style: TextStyle(
                            color: const Color(0xFF080808),
                            fontSize: fontSize,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Campo Nome Completo
                    Semantics(
                      label: 'Campo para digitar o seu nome completo',
                      hint: 'Obrigatório. Somente letras',
                      child: SizedBox(
                        width: fieldWidth,
                        child: TextFormField(
                          controller: _nameController,
                          // focusNode: _nameFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Nome Completo',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateName,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            // Transfere o foco para o próximo campo sem fechar o teclado
                            FocusScope.of(context)
                                .requestFocus(_emailFocusNode);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo E-mail
                    Semantics(
                      label: 'Campo para digitar o seu e-mail',
                      hint: 'Obrigatório. Informe um e-mail válido',
                      child: SizedBox(
                        width: fieldWidth,
                        child: TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            // Transfere o foco para o próximo campo sem fechar o teclado
                            FocusScope.of(context)
                                .requestFocus(_feedbackFocusNode);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo Mensagem
                    Semantics(
                      label: 'Campo para digitar a sua mensagem de feedback',
                      hint: 'Obrigatório. Digite sua mensagem ou sugestão',
                      child: SizedBox(
                        width: fieldWidth,
                        child: TextFormField(
                          controller: _feedbackController,
                          focusNode: _feedbackFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Mensagem',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                          validator: _validateFeedback,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            // Ao pressionar Done/Concluído no teclado, envia o formulário
                            _sendFeedback();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botão Enviar
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: buttonWidth,
                        child: Semantics(
                          label: 'Enviar feedback.',
                          button: true,
                          excludeSemantics: true,
                          child: ElevatedButton.icon(
                            onPressed: _sendFeedback,
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Enviar',
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: buttonFontSize,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                  0xFFae35c1), // Cor atualizada para #ae35c1 que segue o WCAG
                              padding: EdgeInsets.symmetric(
                                horizontal: buttonPadding,
                                vertical: buttonPadding / 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
