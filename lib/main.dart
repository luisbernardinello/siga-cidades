import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sigacidades/data/repositories/place_repository_impl.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
import 'package:sigacidades/firebase_options.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/presentation/home/screens/home_page.dart';
import 'package:sigacidades/presentation/distances/screens/distances_page.dart';
import 'package:sigacidades/presentation/main_screen.dart';
import 'package:sigacidades/presentation/maps/screens/maps_page.dart';
import 'package:sigacidades/presentation/about/screens/about_page.dart';
import 'package:sigacidades/presentation/feedback/screens/feedback_page.dart';
import 'package:sigacidades/presentation/maps/bloc/maps_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

// Função principal para rodar o app.
Future main() async {
  // Inicializa os Widgets
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega o arquivo .env
  await dotenv.load(fileName: '.env');

  // Inicializa o backend de cache do FMTC (flutter_map_tile_caching)
  // Inicialização do FMTC apenas em plataformas com suporte FFI
  if (!kIsWeb &&
      (Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS)) {
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore('mapStore').manage.create();
  }

  // Cria a configuração do Just Audio Background
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  // Inicializa o Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Dá inicio ao app depois dos carregamentos iniciais
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializa o PlaceRepositoryImpl.
    final placeRepository = PlaceRepositoryImpl();
    return MultiProvider(
      providers: [
        // O PlaceRepository será fornecido para toda a aplicação.
        Provider<PlaceRepository>(
          create: (_) => placeRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // CategoryBloc para gerenciar o estado da HomePage e categorias.
          BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(placeRepository)
              ..add(SelectCategoryEvent(-1)), // Evento inicial de categoria.
          ),
          // MapsBloc para gerenciar o estado do MapsPage.
          BlocProvider<MapsBloc>(
            create: (context) => MapsBloc(placeRepository),
          ),
        ],
        // ====================================
        // Configuração do MaterialApp com as rotas do app
        // ====================================
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sigacidades',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            // Responsividade de tela
            useMaterial3: true,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),

          // Define a rota inicial da aplicação (HomePage).

          // initialRoute: MainScreen.routeName,
          initialRoute: '/', // Define LogoSplashScreen como rota inicial

          // Rotas nomeadas: Aqui é definido todas as rotas do app.
          routes: {
            '/': (context) => const LogoSplashScreen(),
            MainScreen.routeName: (context) => const MainScreen(),
            HomePage.routeName: (context) => const HomePage(),
            DistancesPage.routeName: (context) => const DistancesPage(),
            MapsPage.routeName: (context) => const MapsPage(),
            AboutPage.routeName: (context) => const AboutPage(),
            FeedbackPage.routeName: (context) => const FeedbackPage(),
          },
        ),
      ),
    );
  }
}

class LogoSplashScreen extends StatefulWidget {
  const LogoSplashScreen({super.key});

  @override
  State<LogoSplashScreen> createState() => _LogoSplashScreenState();
}

class _LogoSplashScreenState extends State<LogoSplashScreen> {
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();

    //Timer para colocar _animationCompleted como true depois da animação
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _animationCompleted = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double fontSize = MediaQuery.of(context).size.height * 0.045;
    return Semantics(
      label:
          'Bem vindo ao SIGA CIDADES. Notas para o uso do aplicativo. A tela principal está dividida em: menu superior, conteúdo principal da página, e menu de navegação. Use o menu superior para escolher a cidade e pesquisar pontos turísticos. O menu de navegação permite a troca de páginas, atualizando o conteúdo principal da página automaticamente.',
      hint:
          '.Animação do Logotipo do SIGA Cidades, reproduzida ao abrir a página',
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedSplashScreen(
            duration: 2000,
            splash: 'assets/marca_siga.png',
            nextScreen: const MainScreen(),
            splashTransition: SplashTransition.sizeTransition,
            splashIconSize: 150,
            backgroundColor: Colors.white,
            disableNavigation: true,
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.6, // 60% from top
            left: 18.0,
            right: 18.0,
            child: AutoSizeText(
              "Explore o mapa e ouça informações e audiodescrição de parques, ruas, praças e edifícios.",
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontWeight: FontWeight.w300,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
          if (_animationCompleted)
            Positioned(
              bottom: 80,
              child: ElevatedButton(
                onPressed: () {
                  // Para enviar o foco para a navbar
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          const MainScreen(initialFocus: true),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFae35c1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: Semantics(
                  label: 'Continuar',
                  hint: 'Toque para prosseguir para a tela principal',
                  button: true,
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
