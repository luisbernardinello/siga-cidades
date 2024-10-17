import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/data/repositories/place_repository_impl.dart';
import 'package:sigacidades/presentation/home/screens/home_page.dart';
import 'package:sigacidades/common/widgets/drawer_menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sigacidades',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // blocprovider acima de toda a árvore de widgets
    final placeRepository = PlaceRepositoryImpl();

    return BlocProvider(
      create: (context) =>
          CategoryBloc(placeRepository)..add(SelectCategoryEvent(0)),
      child: Scaffold(
        drawer: DrawerMenu(
          onCitySelected: (city) {
            // insere o evento de seleção de cidade no Bloc
            context.read<CategoryBloc>().add(SelectCityEvent(city));
          },
        ),
        body: HomePage(), // exibe a home_page
      ),
    );
  }
}
