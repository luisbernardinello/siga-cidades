import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sigacidades/data/repositories/place_repository_impl.dart';
import 'package:sigacidades/domain/repositories/place_repository.dart';
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

// Função principal para rodar o app.
Future main() async {
  // Inicializa os Widgets
  WidgetsFlutterBinding.ensureInitialized();
  // Carrega o arquivo .env
  await dotenv.load(fileName: '.env');
  // Inicializa o backend de cache do FMTC (flutter_map_tile_caching)
  await FMTCObjectBoxBackend().initialise();
  // Cria o store para cache de tiles
  await FMTCStore('mapStore').manage.create();

  // Cria a configuração do Just Audio Background
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
  //   androidNotificationChannelName: 'Audio playback',
  //   androidNotificationOngoing: true,
  // );

  // Dá inicio ao app depois dos carregamentos iniciais
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
              ..add(SelectCategoryEvent(0)), // Evento inicial de categoria.
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
          ),

          // initialRoute: Define a rota inicial da aplicação como a HomePage.
          initialRoute: MainScreen.routeName,

          // Rotas nomeadas: Aqui é definido todas as rotas do app.
          routes: {
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
