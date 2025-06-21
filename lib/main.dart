import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meow_n_woof/app_settings.dart';
import 'package:meow_n_woof/providers/appointment_provider.dart';
import 'package:meow_n_woof/providers/vaccination_schedule_provider.dart';
import 'package:meow_n_woof/services/appointment_service.dart';
import 'package:meow_n_woof/services/auth_service.dart';
import 'package:meow_n_woof/services/image_upload_service.dart';
import 'package:meow_n_woof/services/medical_record_service.dart';
import 'package:meow_n_woof/services/pet_service.dart';
import 'package:meow_n_woof/services/species_breed_service.dart';
import 'package:meow_n_woof/services/user_service.dart';
import 'package:meow_n_woof/services/vaccination_service.dart';
import 'package:meow_n_woof/views/login.dart';
import 'package:meow_n_woof/views/home.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appSettings = AppSettings();
  await appSettings.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => appSettings),
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider<UserService>(
          create: (context) => UserService(context.read<AuthService>()),
        ),
        Provider<PetService>(
          create: (context) => PetService(context.read<AuthService>()),
        ),
        Provider<SpeciesBreedService>(
          create: (context) => SpeciesBreedService(),
        ),
        Provider<ImageUploadService>(
          create: (context) => ImageUploadService(),
        ),
        Provider<MedicalRecordService>(
          create: (context) => MedicalRecordService(context.read<AuthService>()),
        ),
        Provider<AppointmentService>(
          create: (context) => AppointmentService(context.read<AuthService>()),
        ),
        Provider<VaccinationService>(
          create: (context) => VaccinationService(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(create: (_) => VaccinationScheduleProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettings>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meow & Woof',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          primary: const Color(0xFF1976D2),
          onPrimary: Colors.white,
          secondary: Colors.orange,
          onSecondary: Colors.black,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blueGrey,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(
          secondary: Colors.amber,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
          ),
        ),
      ),
      themeMode: appSettings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: appSettings.locale,
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          // Lắng nghe sự thay đổi của AuthService
          final authService = Provider.of<AuthService>(context);

          if (authService.currentUser != null) {
            print('Người dùng đã đăng nhập: ${authService.currentUser?.fullName}');
            return const HomeScreen();
          } else {
            print('Người dùng chưa đăng nhập');
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}