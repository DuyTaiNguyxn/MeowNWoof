import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meow_n_woof/app_settings.dart';
import 'package:meow_n_woof/providers/appointment_provider.dart';
import 'package:meow_n_woof/providers/vaccination_schedule_provider.dart';
import 'package:meow_n_woof/views/login.dart';
import 'package:meow_n_woof/views/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appSettings = AppSettings();
  await appSettings.loadSettings();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => appSettings),
        ChangeNotifierProvider(create: (_) => VaccinationScheduleProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettings>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meow & Woof',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: appSettings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: appSettings.locale,
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        // Nếu sau này dùng intl thì thêm delegate dịch ngôn ngữ ở đây
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
