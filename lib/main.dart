import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;

  List<Widget> pages = const [
    Center(child: Text("Library Page")),
    Center(child: Text("Start Writing...")),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        child: Stack(
          children: [
            GlassScaffold(
              bottomBar: GlassTabBar.bottom(
                settings: const LiquidGlassSettings(
                  chromaticAberration: 1,
                ),
                tabs: const [
                  GlassTab(
                    icon: FaIcon(FontAwesomeIcons.book, size: 28),
                    activeIcon: FaIcon(
                      FontAwesomeIcons.bookOpen,
                      size: 28,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                  GlassTab(
                    icon: FaIcon(FontAwesomeIcons.featherPointed, size: 28),
                    activeIcon: FaIcon(
                      FontAwesomeIcons.featherPointed,
                      size: 28,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ],
                selectedIndex: selectedIndex,
                onTabSelected: (page) {
                  setState(() {
                    selectedIndex = page;
                  });
                },
              ),
              body: SafeArea(child: pages[selectedIndex]),
            ),

            if (selectedIndex == 1)
              Positioned(
                bottom: 130,
                right: 28,
                child: Builder(
                  builder: (buttonContext) {
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () {
                        Navigator.push(
                          buttonContext,
                          CupertinoPageRoute(
                            builder: (context) => const AddBookScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.activeBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.add,
                          color: CupertinoColors.white,
                          size: 26,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveStory() {
    print("Title: ${_titleController.text}");
    print("Content: ${_contentController.text}");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Add New Story"),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveStory,
          child: const Text(
            "Save",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              CupertinoTextField(
                controller: _titleController,
                placeholder: "Book Title",
                padding: const EdgeInsets.all(16),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),

              Expanded(
                child: CupertinoTextField(
                  controller: _contentController,
                  placeholder: "Write your story here...",
                  padding: const EdgeInsets.all(16),
                  style: const TextStyle(fontSize: 16, height: 1.4),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: BoxDecoration(
                    color: CupertinoColors.darkBackgroundGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}