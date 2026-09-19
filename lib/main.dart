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

  String server = "https://darkgray-crab-751713.hostingersite.com/booknest/";

  List<dynamic> stories = [];

  bool isSearchactive = false;
  bool isexPanded = false;

  final TextEditingController _searchController = TextEditingController();

  Future<void> getStories({String query = ""}) async {
    try {
      final uri =
          "${server}getStories.php?search=${Uri.encodeComponent(query)}";

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
        body: {
          "id": id,
        },
      );

      getStories(query: _searchController.text);
    } catch (e) {
      debugPrint("Error deleting story: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getStories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Widget> get pages => [
    CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () =>
              getStories(query: _searchController.text),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: stories.isEmpty
              ? const SliverFillRemaining(
            child: Center(
              child: Text(
                "No books found",
                style: TextStyle(
                  color: Color(0xFF3B281A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
              : SliverGrid(
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.48,
              crossAxisSpacing: 14,
              mainAxisSpacing: 18,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final story = stories[index];

                return LibraryBookCard(
                  story: story,
                  server: server,
                );
              },
              childCount: stories.length,
            ),
          ),
        ),
      ],
    ),

    CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () =>
              getStories(query: _searchController.text),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 10.0,
          ),
          sliver: stories.isEmpty
              ? const SliverFillRemaining(
            child: Center(
              child: Text(
                "Start Writing...",
                style: TextStyle(
                  color: Color(0xFF3B281A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final story = stories[index];

                return Padding(
                  padding:
                  const EdgeInsets.only(bottom: 12.0),
                  child: StoryTileItem(
                    story: story,
                    server: server,
                    onDelete: () => deleteStory(
                      story["id"].toString(),
                    ),
                    onRefresh: () => getStories(
                      query: _searchController.text,
                    ),
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
        brightness: Brightness.light,
        primaryColor: Color(0xFF4B382A),
      ),
      debugShowCheckedModeBanner: false,

      home: CupertinoPageScaffold(
        backgroundColor: const Color(0xFFE8DFC9),
        child: GlassScaffold(
          bodyOverlays: [
            if (selectedIndex == 1)
              Positioned(
                bottom: 115,
                right: 28,
                child: Builder(
                  builder: (buttonContext) {
                    return SizedBox(
                      width: 54,
                      height: 54,
                      child: GlassButton.custom(
                        shape: const LiquidRoundedRectangle(
                          borderRadius: 27,
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            buttonContext,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  StoryEditorScreen(
                                    server: server,
                                  ),
                            ),
                          );

                          if (result == true) {
                            getStories(
                              query: _searchController.text,
                            );
                          }
                        },
                        child: Container(
                          color: const Color(0xFF6F4E37)
                              .withValues(alpha: 0.9),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.add,
                              color: Color(0xFFFFFDD0),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],

          bottomBar: GlassTabBar.searchable(
            settings: const LiquidGlassSettings(
              blur: 0.5,
              chromaticAberration: 1,
            ),

            isSearchActive: isSearchactive,

            tabs: const [
              GlassTab(
                icon: FaIcon(
                  FontAwesomeIcons.book,
                  size: 32,
                  color: Color(0xFF3B281A),
                ),
                activeIcon: FaIcon(
                  FontAwesomeIcons.bookOpen,
                  size: 32,
                  color: Color(0xFF5A3D28),
                ),
              ),

              GlassTab(
                icon: FaIcon(
                  FontAwesomeIcons.featherPointed,
                  size: 32,
                  color: Color(0xFF3B281A),
                ),
                activeIcon: FaIcon(
                  FontAwesomeIcons.featherPointed,
                  size: 32,
                  color: Color(0xFF5A3D28),
                ),
              ),
            ],

            selectedIndex: selectedIndex,

            onTabSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },

            searchConfig: GlassSearchBarConfig(
              controller: _searchController,
              expandWhenActive: isexPanded,
              onChanged: (query) {
                getStories(query: query);
              },
              onSearchToggle: (active) {
                setState(() {
                  isSearchactive = active;
                  isexPanded = active;

                  if (!active) {
                    _searchController.clear();
                    getStories();
                  }
                });
              },
            ),
          ),

          body: SafeArea(
            child: pages[selectedIndex],
          ),
        ),
      ),
    );
  }
}

class LibraryBookCard extends StatelessWidget {
  final dynamic story;
  final String server;

  const LibraryBookCard({
    super.key,
    required this.story,
    required this.server,
  });

  String _formatDate(dynamic dateValue) {
    if (dateValue != null &&
        dateValue.toString().trim().isNotEmpty) {
      return dateValue.toString();
    }

    final now = DateTime.now();

    return "${now.year}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final String title = story["title"] ?? "Untitled";

    final String? coverImage = story["cover_image"];

    final String dateDisplay = _formatDate(
      story["created_at"] ??
          story["date"] ??
          story["updated_at"],
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => StoryReaderScreen(
              story: story,
              server: server,
            ),
          ),
        );
      },

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,

              decoration: BoxDecoration(
                color: const Color(0xFF7A5230),

                borderRadius: BorderRadius.circular(12),

                boxShadow: [
                  BoxShadow(
                    color:
                    const Color(0xFF3B281A).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],

                image: (coverImage != null &&
                    coverImage.isNotEmpty)
                    ? DecorationImage(
                  image: NetworkImage(
                    "${server}uploads/$coverImage",
                  ),
                  fit: BoxFit.cover,
                )
                    : null,
              ),

              child: (coverImage == null ||
                  coverImage.isEmpty)
                  ? Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: const [
                  Icon(
                    CupertinoIcons.book_solid,
                    size: 38,
                    color: Color(0xFFFFFDD0),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "No Cover",
                    style: TextStyle(
                      color: Color(0xFFFFFDD0),
                      fontSize: 12,
                    ),
                  ),
                ],
              )
                  : null,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1D11),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            "Date: $dateDisplay",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF5A3D28),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryReaderScreen extends StatelessWidget {
  final dynamic story;
  final String server;

  const StoryReaderScreen({
    super.key,
    required this.story,
    required this.server,
  });

  @override
  Widget build(BuildContext context) {
    final String title = story["title"] ?? "Untitled";

    final String content = story["content"] ?? "";

    final String? coverImage = story["cover_image"];

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE8DFC9),
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: Color(0xFF7A5230),
        middle: Text(
          "Read Story",
          style: TextStyle(color: Color(0xFFFFFDD0)),
        ),
      ),

      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              if (coverImage != null &&
                  coverImage.isNotEmpty) ...[
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(12),

                  child: Image.network(
                    "${server}uploads/$coverImage",

                    width: double.infinity,

                    height: 220,

                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 16),
              ],

              Text(
                title,

                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1D11),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                content,

                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF3B281A),
                ),
              ),
            ],
          ),
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
  State<StoryTileItem> createState() =>
      _StoryTileItemState();
}

class _StoryTileItemState
    extends State<StoryTileItem> {

  bool _showDelete = false;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,

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
                    builder: (context) =>
                        StoryEditorScreen(
                          server: widget.server,

                          storyId:
                          widget.story["id"].toString(),

                          initialTitle:
                          widget.story["title"] ?? "",

                          initialContent:
                          widget.story["content"] ?? "",

                          initialImage:
                          widget.story["cover_image"],
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
                  color:
                  const Color(0xFF7A5230),

                  borderRadius:
                  BorderRadius.circular(16),
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [
                    Expanded(
                      child: Text(
                        widget.story["title"] ?? "",

                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                          Color(0xFFFFFDD0),
                        ),
                      ),
                    ),

                    const Icon(
                      CupertinoIcons.chevron_right,
                      color:
                      Color(0xFFE8DFC9),
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
                final confirm =
                await showCupertinoDialog<bool>(
                  context: context,

                  builder: (ctx) =>
                      CupertinoAlertDialog(
                        title:
                        const Text("Delete Story"),

                        content: const Text(
                          "Are you sure you want to delete this story?",
                        ),

                        actions: [
                          CupertinoDialogAction(
                            child:
                            const Text("Cancel"),

                            onPressed: () =>
                                Navigator.pop(
                                  ctx,
                                  false,
                                ),
                          ),

                          CupertinoDialogAction(
                            isDestructiveAction: true,

                            child:
                            const Text("Delete"),

                            onPressed: () =>
                                Navigator.pop(
                                  ctx,
                                  true,
                                ),
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

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 4,
                ),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    Container(
                      width: 40,
                      height: 40,

                      decoration:
                      const BoxDecoration(
                        color:
                        CupertinoColors.systemRed,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        CupertinoIcons.delete_solid,
                        color:
                        CupertinoColors.white,
                        size: 20,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      "Delete",

                      style: TextStyle(
                        color:
                        CupertinoColors.systemRed,
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
  State<StoryEditorScreen> createState() =>
      _StoryEditorScreenState();
}

class _StoryEditorScreenState
    extends State<StoryEditorScreen> {

  late TextEditingController _titleController;

  late TextEditingController _contentController;

  File? _selectedImage;

  final ImagePicker _picker =
  ImagePicker();

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(
          text: widget.initialTitle ?? "",
        );

    _contentController =
        TextEditingController(
          text: widget.initialContent ?? "",
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage =
            File(pickedFile.path);
      });
    }
  }

  Future<void> _saveStory() async {
    if (_titleController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,

        builder: (ctx) =>
            CupertinoAlertDialog(
              title:
              const Text("Missing Title"),

              content: const Text(
                "Please enter a title for your story.",
              ),

              actions: [
                CupertinoDialogAction(
                  child: const Text("OK"),

                  onPressed: () =>
                      Navigator.pop(ctx),
                ),
              ],
            ),
      );

      return;
    }

    try {
      final isEdit =
          widget.storyId != null;

      final uri =
          "${widget.server}${isEdit ? 'updateStory.php' : 'addStory.php'}";

      debugPrint("SINUSUBUKANG KUMONEKTA SA: $uri");

      var request =
      http.MultipartRequest(
        'POST',
        Uri.parse(uri),
      );

      request.fields['title'] =
          _titleController.text;

      request.fields['content'] =
          _contentController.text;

      if (isEdit) {
        request.fields['id'] =
        widget.storyId!;
      }

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _selectedImage!.path,
          ),
        );
      }

      var streamedResponse =
      await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("SERVER STATUS CODE: ${response.statusCode}");
      debugPrint("SERVER RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200 &&
          mounted) {
        Navigator.pop(
          context,
          true,
        );
      } else {
        debugPrint("Hindi 200 ang status code!");
      }
    } catch (e) {
      debugPrint(
        "MAY ERROR SA CATCH: $e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE8DFC9),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF7A5230),
        middle: Text(
          widget.storyId == null
              ? "Add New Story"
              : "Edit Story",
          style: const TextStyle(
            color: Color(0xFF5A3D28), // Coffee color na para visible at kita
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: CupertinoButton(
          padding: EdgeInsets.zero,

          onPressed: () =>
              Navigator.pop(context),

          child: const Icon(
            CupertinoIcons.chevron_left,
            size: 26,
            color:
            Color(0xFF5A3D28),
          ),
        ),

        trailing: CupertinoButton(
          padding: EdgeInsets.zero,

          onPressed: _saveStory,

          child: const Text(
            "Save",

            style: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.bold,
              color: Color(0xFF5A3D28), // Coffee color na rin ang Save button
            ),
          ),
        ),
      ),

      child: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),

          child: Column(
            children: [
              CupertinoTextField(
                controller:
                _titleController,

                placeholder:
                "Book Title",

                placeholderStyle: const TextStyle(
                  color: Color(0xFF5A3D28),
                  fontWeight: FontWeight.w500,
                ),

                padding:
                const EdgeInsets.all(16),

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Color(0xFF2C1D11),
                ),

                decoration:
                BoxDecoration(
                  color:
                  const Color(0xFFD6C8B0),

                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: _pickImage,

                child: Container(
                  width: double.infinity,
                  height: 130,

                  decoration: BoxDecoration(
                    color:
                    const Color(0xFFD6C8B0),

                    borderRadius:
                    BorderRadius.circular(10),

                    image:
                    _selectedImage != null
                        ? DecorationImage(
                      image:
                      FileImage(
                        _selectedImage!,
                      ),
                      fit:
                      BoxFit.cover,
                    )
                        : (widget.initialImage !=
                        null &&
                        widget.initialImage!
                            .isNotEmpty)
                        ? DecorationImage(
                      image:
                      NetworkImage(
                        "${widget.server}uploads/${widget.initialImage}",
                      ),
                      fit:
                      BoxFit.cover,
                    )
                        : null,
                  ),

                  child:
                  (_selectedImage == null &&
                      (widget.initialImage ==
                          null ||
                          widget.initialImage!
                              .isEmpty))
                      ? const Column(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                    children: [
                      Icon(
                        CupertinoIcons.photo,
                        size: 32,
                        color:
                        Color(0xFF5A3D28),
                      ),

                      SizedBox(
                        height: 6,
                      ),

                      Text(
                        "Add Cover Image (Optional)",

                        style:
                        TextStyle(
                          color:
                          Color(0xFF5A3D28),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                      : null,
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child:
                CupertinoTextField(
                  controller:
                  _contentController,

                  placeholder:
                  "Write your story here...",

                  placeholderStyle: const TextStyle(
                    color: Color(0xFF5A3D28),
                    fontWeight: FontWeight.w500,
                  ),

                  padding:
                  const EdgeInsets.all(16),

                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Color(0xFF2C1D11),
                  ),

                  maxLines: null,
                  expands: true,

                  keyboardType:
                  TextInputType.multiline,

                  textAlignVertical:
                  TextAlignVertical.top,

                  decoration:
                  BoxDecoration(
                    color:
                    const Color(0xFFD6C8B0),

                    borderRadius:
                    BorderRadius.circular(10),
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