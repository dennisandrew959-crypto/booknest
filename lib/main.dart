import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
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
    } catch (e) {
      debugPrint("Error fetching stories: $e");
    }
  }

  Future<void> deleteStory(String id) async {
    try {
      final uri = "${server}deleteStory.php";
      await http.post(
        Uri.parse(uri),
        body: {"id": id},
      );
      getStories();
    } catch (e) {
      debugPrint("Error deleting story: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getStories();
  }

  List<Widget> get pages => [
    const Center(
      child: Text(
        "Library Page",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ),
    CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: getStories,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          sliver: stories.isEmpty
              ? const SliverFillRemaining(
            child: Center(
              child: Text(
                "Start Writing...",
                style: TextStyle(color: CupertinoColors.systemGrey),
              ),
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final story = stories[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: StoryTileItem(
                    story: story,
                    server: server,
                    onDelete: () => deleteStory(story["id"].toString()),
                    onRefresh: getStories,
                  ),
                );
              },
              childCount: stories.length,
            ),
          ),
        ),
      ],
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

class StoryTileItem extends StatefulWidget {
  final dynamic story;
  final String server;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const StoryTileItem({
    super.key,
    required this.story,
    required this.server,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  State<StoryTileItem> createState() => _StoryTileItemState();
}

class _StoryTileItemState extends State<StoryTileItem> {
  bool _showDelete = false;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                setState(() {
                  _showDelete = !_showDelete;
                });
              },
              onTap: () async {
                if (_showDelete) {
                  setState(() {
                    _showDelete = false;
                  });
                  return;
                }
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => StoryEditorScreen(
                      server: widget.server,
                      storyId: widget.story["id"].toString(),
                      initialTitle: widget.story["title"] ?? "",
                      initialContent: widget.story["content"] ?? "",
                      initialImage: widget.story["cover_image"],
                    ),
                  ),
                );
                if (result == true) {
                  widget.onRefresh();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.story["title"] ?? "",
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
          ),
          if (_showDelete) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () async {
                final confirm = await showCupertinoDialog<bool>(
                  context: context,
                  builder: (ctx) => CupertinoAlertDialog(
                    title: const Text("Delete Story"),
                    content: const Text("Are you sure you want to delete this story?"),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        child: const Text("Delete"),
                        onPressed: () => Navigator.pop(ctx, true),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  widget.onDelete();
                }
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.systemRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.delete_solid,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Delete",
                      style: TextStyle(
                        color: CupertinoColors.systemRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StoryEditorScreen extends StatefulWidget {
  final String server;
  final String? storyId;
  final String? initialTitle;
  final String? initialContent;
  final String? initialImage;

  const StoryEditorScreen({
    super.key,
    required this.server,
    this.storyId,
    this.initialTitle,
    this.initialContent,
    this.initialImage,
  });

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveStory() async {
    if (_titleController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text("Missing Title"),
          content: const Text("Please enter a title for your story."),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final isEdit = widget.storyId != null;
      final uri = "${widget.server}${isEdit ? 'updateStory.php' : 'addStory.php'}";

      var request = http.MultipartRequest('POST', Uri.parse(uri));
      request.fields['title'] = _titleController.text;
      request.fields['content'] = _contentController.text;

      if (isEdit) {
        request.fields['id'] = widget.storyId!;
      }

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );
      }

      var streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200 && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error saving story: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.storyId == null ? "Add New Story" : "Edit Story"),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.chevron_left,
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

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    color: CupertinoColors.darkBackgroundGray,
                    borderRadius: BorderRadius.circular(10),
                    image: _selectedImage != null
                        ? DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    )
                        : (widget.initialImage != null && widget.initialImage!.isNotEmpty)
                        ? DecorationImage(
                      image: NetworkImage(
                        "${widget.server}uploads/${widget.initialImage}",
                      ),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: (_selectedImage == null &&
                      (widget.initialImage == null || widget.initialImage!.isEmpty))
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.photo,
                        size: 32,
                        color: CupertinoColors.systemGrey,
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Add Cover Image (Optional)",
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                      : null,
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