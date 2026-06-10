import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/themes/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/data/repository/auth_repo_impl.dart';
import 'features/venue/data/venue_fb_repo.dart';
import 'features/venue/presentation/cubit/venue_cubit.dart';
import 'features/booking/data/booking_fb_repo.dart';
import 'features/booking/presentation/cubit/booking_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<VenueFbRepo>(
          create: (context) => const VenueFbRepo(),
        ),
        RepositoryProvider<BookingFbRepo>(
          create: (context) => const BookingFbRepo(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>(
                create: (context) => AuthCubit(authRepo: AuthRepoImpl())..checkAuth(),
              ),
              BlocProvider<VenueCubit>(
                create: (context) => VenueCubit(
                  venueFbRepo: context.read<VenueFbRepo>(),
                ),
              ),
              BlocProvider<BookingCubit>(
                create: (context) => BookingCubit(
                  bookingFbRepo: context.read<BookingFbRepo>(),
                ),
              ),
            ],
            child: MaterialApp.router(
              routerConfig: appRouter,
              title: 'Booking App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
            ),
          );
        },
      ),
    );
  }
}
