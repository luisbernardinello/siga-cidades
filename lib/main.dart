import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:provider/provider.dart'; // Import para usar o Provider

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Inicializando o PlaceRepositoryImpl.
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
        ],
        // ====================================
        // Configuração do MaterialApp
        // ====================================
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sigacidades',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),

          // initialRoute: Define a rota inicial da aplicação como a HomePage.
          initialRoute: MainScreen.routeName,

          // **Rotas nomeadas**: Definimos todas as rotas da aplicação.
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
