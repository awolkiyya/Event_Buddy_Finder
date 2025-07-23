import '../../futures/splash/presentation/pages/splash_page.dart';
import 'package:go_router/go_router.dart';

// import 'package:your_app_name/features/home/presentation/pages/home_page.dart';
// import 'package:your_app_name/features/auth/presentation/pages/login_page.dart';
// import 'package:your_app_name/features/splash/presentation/pages/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) =>  SplashPage(),
    ),
  ],
);
