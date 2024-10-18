import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_bloc.dart';
import 'package:sigacidades/presentation/home/bloc/home_event.dart';
import 'package:sigacidades/data/repositories/place_repository_impl.dart';
import 'package:sigacidades/presentation/home/screens/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. O PlaceRepositoryImpl implementa a lógica para acessar dados de fontes externas (ex: API, banco de dados).
    //    Aqui ele é inicializado e passado ao BLoC, tem a função de isolar a camada de apresentação (UI) para que ela não haja diretamente com os dados.
    final placeRepository = PlaceRepositoryImpl();

    return BlocProvider(
      // Fornece o CategoryBloc para a árvore de widgets (todas as páginas).
      // O Bloc é responsável por gerenciar o estado da aplicação.
      // A função create inicializa o CategoryBloc e passa o placeRepository para obter os dados.
      create: (context) => CategoryBloc(placeRepository)
        // Evento inicial de seleção da categoria (começa na categoria de Bosques e Parques).
        ..add(SelectCategoryEvent(0)),

      // HomePage como página inicial.
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sigacidades',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}
