import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sigacidades/core/utils/feedback_email_text.dart';
import 'dart:io';

class FeedbackPage extends StatefulWidget {
  static const routeName = '/feedback';

  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();

  static final RegExp namePattern = RegExp('[a-zA-Z]');
  static final RegExp emailPattern = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _feedbackController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Envio de e-mail não suportado neste dispositivo.')),
      );
      return;
    }

    String? username = dotenv.env['EMAIL_USERNAME'];
    String? password = dotenv.env['EMAIL_PASSWORD'];

    if (username == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Credenciais de e-mail não carregadas corretamente.")),
      );
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
      ..recipients.add('luisbernardinello@gmail.com')
      ..subject = 'Feedback enviado por $name'
      ..html = generateFeedbackEmailHTML(name, email, message, device);

    try {
      final sendReport = await send(emailMessage, smtpServer);
      print('E-mail enviado: ' + sendReport.toString());
      _showSuccessDialog();
    } on MailerException catch (e) {
      print('Erro ao enviar e-mail: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar feedback.')),
      );
    }
  }

  Future<void> _sendFeedback() async {
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
                  label: 'Botão de fechar janela de confirmação',
                  hint: 'Clique para voltar à página de feedback',
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
              Expanded(
                child: Text(
                  'Obrigado!',
                  style: const TextStyle(
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
    double buttonPadding = isDesktop ? 16 : 12;
    double fieldWidth = isDesktop ? 600 : double.infinity;

    return Semantics(
      label:
          'Página de Feedback, preencha os campos para enviar o seu feedback',
      focusable: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Página de Feedback',
                  child: Text(
                    'Envie o seu feedback:',
                    style: TextStyle(
                      color: const Color(0xFF080808),
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
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
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateName,
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
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateEmail,
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
                      decoration: const InputDecoration(
                        labelText: 'Mensagem',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: _validateFeedback,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botão Enviar
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    child: ElevatedButton.icon(
                      onPressed: _sendFeedback,
                      icon: const Icon(Icons.send),
                      label: const Text('Enviar Feedback'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: buttonPadding,
                            vertical: buttonPadding / 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
