import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:microchek_app/firebase_options.dart';
import 'package:microchek_app/pages/dashboard.dart';
import 'package:microchek_app/pages/login.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InstitutionProvider()),
      ],
      child: const MyApp(),
      
    )
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Micro-Check App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoginPage(),
    );
  }
}

class TrialButton extends StatelessWidget {
  const TrialButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () async {
          bool valid = await checkUserLogin('test@gmail.com', 'francis', context);
          if (valid){
            try{
              InstitutionProvider instProvider = Provider.of<InstitutionProvider>(context,listen:false);
              final user = await getUserCredentials();
              if (!await checkInstitution(user!.uid)){
                await createNewInstitution(user.uid, 'test', 'test@gmail.com', 'none', 'online');
              }                
              await fetchInstitutionData(user.uid, instProvider);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GhanaCardValidationPage()));
            }
            catch(e){
              debugPrint('Login in issues: $e');
            }
            
          }
        },
        child: const Text('Click to sign in')
      )
    );
  }
}