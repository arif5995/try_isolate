import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:try_isolate/bloc/post_bloc.dart';
import 'package:try_isolate/injections/injections.dart';
import 'package:try_isolate/ui/screen_one.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injections().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => PostBloc(getPostUsecase: sl())..add(PostFetched()),
        child: ScreenOne(),
      ),
    );
  }
}
