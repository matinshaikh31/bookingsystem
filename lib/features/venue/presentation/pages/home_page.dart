import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/const/role.dart';
import '../../../admin/presentation/pages/admin_shell.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../booking/presentation/widgets/user_bookings_page.dart';
import '../widgets/user_venues_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final _pages = const [
    UserVenuesPage(),
    UserBookingsPage(),
    ProfilePage(showLeading: false),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.currentUser;
        if (state.isAuthenticated && user?.role == Roles.admin) {
          return const AdminShell();
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: _index,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.surface,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.stadium_outlined),
                  activeIcon: Icon(Icons.stadium_rounded),
                  label: 'Venues',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_note_outlined),
                  activeIcon: Icon(Icons.event_note_rounded),
                  label: 'Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
