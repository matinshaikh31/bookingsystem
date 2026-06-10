import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/themes/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/data/repository/auth_repo_impl.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: AuthRepoImpl())..checkAuth(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        title: 'Booking App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
