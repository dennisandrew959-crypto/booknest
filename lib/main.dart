import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;
  List<Widget> pages = [
    Center(child: Text("Library")),
    Center(child: Text("Add Books")),
  ];
  @override

  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
          brightness: Brightness.dark
      ),
      debugShowCheckedModeBanner: false,
      home: GlassScaffold(

          bottomBar: GlassTabBar.bottom(
              settings: LiquidGlassSettings(
                  chromaticAberration: 1
              ),
              tabs: [
                GlassTab(icon: FaIcon(FontAwesomeIcons.book,size: 28),activeIcon: FaIcon(FontAwesomeIcons.bookOpen, size: 28, color: CupertinoColors.systemBlue,),), //0
                GlassTab(icon: FaIcon(FontAwesomeIcons.featherPointed,size: 28),activeIcon: FaIcon(FontAwesomeIcons.featherPointed, size: 28, color: CupertinoColors.systemBlue,),),
              ], selectedIndex: selectedIndex, onTabSelected: (page){
            setState(() {
              selectedIndex = page;
            });
          }),
          body: SafeArea(child: pages[selectedIndex])
      ),
    );
  }
}