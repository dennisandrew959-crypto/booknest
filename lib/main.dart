import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:http/http.dart' as http;

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
  String server = "http://192.168.100.202/booknest/";
  List<dynamic> stories = [];

  Future<void> getStories() async {
    try {
      final uri = "${server}getStories.php";
      final response = await http.get(Uri.parse(uri));
      if (response.statusCode == 200) {
        setState(() {
          stories = jsonDecode(response.body);
        });
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    getStories();
  }

  List<Widget> get pages => [
    const Center(child: Text("Library Page")),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: stories.isEmpty
          ? const Center(child: Text("Start Writing..."))
          : ListView.builder(
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GestureDetector(
              onTap: () async {
                // Babalik sa Editor Format para sa ginawang Story
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => StoryEditorScreen(
                      server: server,
                      storyId: stories[index]["id"].toString(),
                      initialTitle: stories[index]["title"] ?? "",
                      initialContent: stories[index]["content"] ?? "",
                    ),
                  ),
                );
                if (result == true) {
                  getStories();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stories[index]["title"] ?? "",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.chevron_right,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
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
                      minimumSize: Size.zero,
                      onPressed: () async {
                        final result = await Navigator.push(
                          buttonContext,
                          CupertinoPageRoute(
                            builder: (context) => StoryEditorScreen(
                              server: server,
                            ),
                          ),
                        );
                        if (result == true) {
                          getStories();
                        }
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

// Mismong Editor Page para sa Add, View, at Edit ng Story
class StoryEditorScreen extends StatefulWidget {
  final String server;
  final String? storyId;
  final String? initialTitle;
  final String? initialContent;

  const StoryEditorScreen({
    super.key,
    required this.server,
    this.storyId,
    this.initialTitle,
    this.initialContent,
  });

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? "");
    _contentController = TextEditingController(text: widget.initialContent ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveStory() async {
    if (_titleController.text.trim().isEmpty) return;

    try {
      final uri = "${widget.server}addStory.php";
      await http.post(
        Uri.parse(uri),
        body: {
          "title": _titleController.text,
          "content": _contentController.text,
        },
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.storyId == null ? "Add New Story" : "Story"),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.chevron_left, // Symbol na < pabalik
            size: 26,
            color: CupertinoColors.activeBlue,
          ),
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