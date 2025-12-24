import 'package:saveingold_fzco/presentation/screens/get_started_screen.dart';

class AppRoutes {
  static const String getStartedScreen = '/';
  static final routes = {
    getStartedScreen: (context) => GetStartedScreen(
      autoLogin: true,
    ),
  };
}
