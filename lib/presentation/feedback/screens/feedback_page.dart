import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Para carregar variáveis de ambiente
import 'package:sigacidades/core/utils/feedback_utils.dart'; // Para carregar o template HTML do corpo do e-mail
import 'dart:io'; // Importa a biblioteca para detectar o dispositivo

// ====================================
// FeedbackPage: Formulário para Envio de Feedback
// ====================================
// Permite aos usuários enviar feedback pelo App.
// Enviado pela lib mailer com SMTP.
class FeedbackPage extends StatefulWidget {
  static const routeName = '/feedback';

  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // ====================================
  // Chave global para gerenciar o estado do formulário
  // ====================================
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores para capturar os valores dos campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  // Regex para validação dos campos Nome e E-mail
  static final RegExp namePattern = RegExp('[a-zA-Z]');
  static final RegExp emailPattern = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  // ====================================
  // Funções de Validação do Formulário
  // ====================================
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

  // ====================================
  // Função para exibir o alerta de sucesso após o envio do feedback
  // ====================================
  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso!'),
          content: const Text('Seu feedback foi enviado com sucesso!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha a janela
              },
            ),
          ],
        );
      },
    );
  }

  // ====================================
  // Função para enviar o e-mail usando SMTP
  // ====================================
  Future<void> _sendEmail(String name, String email, String message) async {
    // Carrega as credenciais do arquivo .env
    String? username = dotenv.env['EMAIL_USERNAME'];
    String? password = dotenv.env['EMAIL_PASSWORD'];

    // Verifica se as credenciais estão presentes
    if (username == null || password == null) {
      print("Credenciais de e-mail não carregadas corretamente.");
      return;
    }

    // Identifica o dispositivo (Android ou iOS)
    String device = Platform.isAndroid
        ? 'Android'
        : Platform.isIOS
            ? 'iOS'
            : 'Outro';

    // Configura o servidor SMTP do Gmail
    final smtpServer = gmail(username, password);

    // Cria a mensagem de e-mail com formatação HTML do template da core/utils/feedback_utils.dart
    final emailMessage = Message()
      ..from = Address(username, 'Sigacidades Feedback')
      ..recipients.add('luisbernardinello@gmail.com')
      ..subject = 'Feedback enviado por $name'
      ..html = generateFeedbackEmailHTML(name, email, message, device);

    try {
      // Tenta enviar o e-mail
      final sendReport = await send(emailMessage, smtpServer);
      print('E-mail enviado: ' + sendReport.toString());
      _showSuccessDialog(); // Mostra o alerta de sucesso
    } on MailerException catch (e) {
      // Em caso de erro, log para ver no console
      print('Erro ao enviar e-mail: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        // Exibe mensagem de erro no rodapé
        const SnackBar(content: Text('Erro ao enviar feedback.')),
      );
    }
  }

  // ====================================
  // Função para processar o envio do feedback
  // ====================================
  Future<void> _sendFeedback() async {
    // Valida o formulário enviado
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final String name = _nameController.text;
      final String email = _emailController.text;
      final String feedback = _feedbackController.text;

      // Exibe uma mensagem de processamento no rodapé
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviando feedback...')),
      );

      // Envia o e-mail
      await _sendEmail(name, email, feedback);

      // Limpa os campos após o envio
      _nameController.clear();
      _emailController.clear();
      _feedbackController.clear();
    }
  }

  // ====================================
  // Interface do Formulário de Feedback
  // ====================================
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey, // Atribui a chave global ao formulário para validação
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Por favor, envie-nos o seu feedback:',
              style: TextStyle(
                color: Color(0xFF080808),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 15),

            // Campo Nome Completo
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
              ),
              validator: _validateName, // Valida o nome
            ),
            const SizedBox(height: 16),

            // Campo E-mail
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              validator: _validateEmail, // Valida o e-mail
            ),
            const SizedBox(height: 16),

            // Campo Mensagem
            TextFormField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Mensagem',
                border: OutlineInputBorder(),
              ),
              maxLines: 5, // Permite múltiplas linhas para o feedback
              validator: _validateFeedback, // Valida a mensagem
            ),
            const SizedBox(height: 24),

            // Botão Enviar
            Center(
              child: ElevatedButton(
                onPressed: _sendFeedback, // Chama a função de envio
                child: const Text('Enviar Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpa os controladores de texto, liberando a memória
    _nameController.dispose();
    _emailController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }
}
