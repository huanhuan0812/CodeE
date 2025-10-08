import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlighter/highlighter.dart' as hl;
import 'package:highlighter/highlighter.dart';

class VSCodeLayout extends StatefulWidget {
  @override
  _VSCodeLayoutState createState() => _VSCodeLayoutState();
}

class _VSCodeLayoutState extends State<VSCodeLayout> {
  int _activeActivity = 0;
  int _activeTab = 0;
  bool _sidebarVisible = true;
  bool _activityBarVisible = true;
  bool _panelVisible = false;
  
  final List<String> _activities = ['Explorer', 'Search', 'Git', 'Debug', 'Extensions'];
  final List<IconData> _activityIcons = [
    Icons.folder,
    Icons.search,
    Icons.commit,
    Icons.bug_report,
    Icons.extension,
  ];
  
  final List<String> _tabs = ['main.dart', 'utils.dart', 'config.json'];
  final List<String> _fileContents = [
    '''void main() {
  print('Hello, World!');
  
  // This is a comment
  int number = 42;
  String text = "Hello";
  
  if (number > 0) {
    print('Positive number');
  }
  
  List<int> numbers = [1, 2, 3, 4, 5];
  numbers.forEach((element) {
    print(element);
  });
}''',
    '''class Utils {
  static String formatDate(DateTime date) {
    return "\${date.year}-\${date.month.toString().padLeft(2, '0')}-\${date.day.toString().padLeft(2, '0')}";
  }
  
  static bool isEven(int number) {
    return number % 2 == 0;
  }
  
  static List<String> splitWords(String text) {
    return text.split(' ');
  }
}''',
    '''{
  "name": "My Project",
  "version": "1.0.0",
  "description": "A sample project",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}''',
  ];
  
  final List<String> _languages = ['dart', 'dart', 'json'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF1E1E1E),
        child: Column(
          children: [
            _buildTitleBar(),
            Expanded(
              child: Row(
                children: [
                  if (_activityBarVisible) _buildActivityBar(),
                  if (_sidebarVisible) _buildSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        _buildTabBar(),
                        Expanded(
                          child: _buildEditor(),
                        ),
                        if (_panelVisible) _buildPanel(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTitleBar() {
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        color: Color(0xFF3C3C3C),
        border: Border(
          bottom: BorderSide(color: Color(0xFF252526), width: 1),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Text(
            'VSCode Flutter Editor',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.minimize, size: 16, color: Colors.white70),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
              IconButton(
                icon: const Icon(Icons.crop_square, size: 16, color: Colors.white70),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.white70),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityBar() {
    return Container(
      width: 50,
      color: const Color(0xFF333333),
      child: Column(
        children: [
          const SizedBox(height: 10),
          ...List.generate(_activities.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: IconButton(
                icon: Icon(
                  _activityIcons[index],
                  color: _activeActivity == index ? Colors.blue : Colors.grey[400],
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _activeActivity = index;
                  });
                },
                padding: const EdgeInsets.all(8),
              ),
            );
          }),
          const Spacer(),
          IconButton(
            icon: Icon(
              _sidebarVisible ? Icons.arrow_back : Icons.arrow_forward,
              color: Colors.grey[400],
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _sidebarVisible = !_sidebarVisible;
              });
            },
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSidebar() {
    return Container(
      width: 220,
      color: const Color(0xFF252526),
      child: Column(
        children: [
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              _activities[_activeActivity],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: _buildSidebarContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSidebarContent() {
    switch (_activeActivity) {
      case 0: // Explorer
        return _buildExplorer();
      case 1: // Search
        return _buildSearch();
      case 2: // Git
        return _buildGit();
      case 3: // Debug
        return _buildDebug();
      case 4: // Extensions
        return _buildExtensions();
      default:
        return Container();
    }
  }
  
  Widget _buildExplorer() {
    return ListView(
      children: [
        _buildExplorerItem('📁', 'lib', true),
        _buildExplorerItem('📄', 'main.dart', false),
        _buildExplorerItem('📄', 'utils.dart', false),
        _buildExplorerItem('📁', 'assets', true),
        _buildExplorerItem('📄', 'config.json', false),
        _buildExplorerItem('📄', 'README.md', false),
      ],
    );
  }
  
  Widget _buildExplorerItem(String icon, String name, bool isFolder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Icon(
            isFolder ? Icons.folder : Icons.insert_drive_file,
            size: 16,
            color: Colors.grey[400],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearch() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search, size: 16),
              filled: true,
              fillColor: Color(0xFF3C3C3C),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildSearchResult('main.dart', 'print(\'Hello, World!\');'),
              _buildSearchResult('utils.dart', 'static String formatDate'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSearchResult(String file, String content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            file,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            content,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const Divider(height: 10),
        ],
      ),
    );
  }
  
  Widget _buildGit() {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: const Text(
            'No changes',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDebug() {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: const Text(
            'No debug sessions',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildExtensions() {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: const Text(
            'No extensions installed',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      height: 35,
      color: const Color(0xFF2D2D2D),
      child: Row(
        children: [
          ...List.generate(_tabs.length, (index) {
            return Container(
              decoration: BoxDecoration(
                color: _activeTab == index ? const Color(0xFF1E1E1E) : const Color(0xFF2D2D2D),
                border: Border(
                  right: BorderSide(color: const Color(0xFF252526), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        color: _activeTab == index ? Colors.white : Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        _closeTab(index);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(child: Container()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                size: 16,
                color: Colors.grey,
              ),
              onPressed: _addNewTab,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditor() {
    if (_tabs.isEmpty) {
      return Container(
        color: const Color(0xFF1E1E1E),
        child: const Center(
          child: Text(
            'No file selected',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }
    
    return VSCodeEditor(
      initialText: _fileContents[_activeTab],
      language: _languages[_activeTab],
      onChanged: (text) {
        // 更新文件内容
        setState(() {
          _fileContents[_activeTab] = text;
        });
      },
    );
  }
  
  Widget _buildPanel() {
    return Container(
      height: 200,
      color: const Color(0xFF2D2D2D),
      child: Column(
        children: [
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF252526), width: 1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Terminal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _panelVisible = false;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: const Text(
                '> flutter run\nBuilding flutter tool...\nRunning "flutter pub get" in flutter_tools...         \nDownloading android-arm-profile/linux-x64 tools...              \nDownloading android-arm-release/linux-x64 tools...              \nDownloading android-arm64-profile/linux-x64 tools...            \nDownloading android-arm64-release/linux-x64 tools...            \n',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _closeTab(int index) {
    if (_tabs.length == 1) return;
    
    setState(() {
      _tabs.removeAt(index);
      _fileContents.removeAt(index);
      _languages.removeAt(index);
      
      if (_activeTab >= _tabs.length) {
        _activeTab = _tabs.length - 1;
      }
    });
  }
  
  void _addNewTab() {
    setState(() {
      _tabs.add('new_file.dart');
      _fileContents.add('// New file content');
      _languages.add('dart');
      _activeTab = _tabs.length - 1;
    });
  }
}

class VSCodeEditor extends StatefulWidget {
  final String initialText;
  final String language;
  final Function(String)? onChanged;
  
  const VSCodeEditor({
    Key? key,
    this.initialText = '',
    this.language = 'dart',
    this.onChanged,
  }) : super(key: key);

  @override
  _VSCodeEditorState createState() => _VSCodeEditorState();
}

class _VSCodeEditorState extends State<VSCodeEditor> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _lineNumberScrollController = ScrollController();
  
  late String _currentText;
  List<String> _lines = [];
  double _fontSize = 14.0;
  double _lineHeight = 20.0;
  
  @override
  void initState() {
    super.initState();
    _currentText = widget.initialText;
    _controller.text = _currentText;
    _lines = _currentText.split('\n');
    _controller.addListener(_onTextChanged);
    
    _scrollController.addListener(_syncScroll);
    _lineNumberScrollController.addListener(_syncScroll);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _lineNumberScrollController.dispose();
    super.dispose();
  }
  
  void _onTextChanged() {
    setState(() {
      _currentText = _controller.text;
      _lines = _currentText.split('\n');
    });
    
    if (widget.onChanged != null) {
      widget.onChanged!(_currentText);
    }
  }
  
  void _syncScroll() {
    if (_scrollController.hasClients && _lineNumberScrollController.hasClients) {
      _lineNumberScrollController.jumpTo(_scrollController.offset);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Row(
        children: [
          // 行号区域
          Container(
            width: 50,
            color: const Color(0xFF2D2D2D),
            child: ListView.builder(
              controller: _lineNumberScrollController,
              itemCount: _lines.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  height: _lineHeight,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: _fontSize * 0.9,
                    ),
                  ),
                );
              },
            ),
          ),
          // 分割线
          Container(
            width: 1,
            color: Colors.grey[700],
          ),
          // 代码编辑区域
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildCodeWidget(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCodeWidget() {
    return Container(
      constraints: BoxConstraints(
        minHeight: _lines.length * _lineHeight,
        minWidth: 600,
      ),
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _lines.asMap().entries.map((entry) {
            int index = entry.key;
            String line = entry.value;
            return Container(
              height: _lineHeight,
              child: _buildHighlightedLine(line, widget.language),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildHighlightedLine(String line, String language) {
    try {
      List<hl.Node> nodes = hl.highlight.parse(line, language: language).nodes ?? [];
      
      List<InlineSpan> spans = nodes.map((node) {
        Color color = _getColorForToken(node.className);
        return TextSpan(
          text: node.value,
          style: TextStyle(
            color: color,
            fontSize: _fontSize,
            fontFamily: 'Monospace',
          ),
        );
      }).toList();
      
      return Text.rich(
        TextSpan(children: spans),
        style: TextStyle(fontSize: _fontSize, fontFamily: 'Monospace'),
      );
    } catch (e) {
      return Text(
        line,
        style: TextStyle(
          color: Colors.white,
          fontSize: _fontSize,
          fontFamily: 'Monospace',
        ),
      );
    }
  }
  
  Color _getColorForToken(String? className) {
    if (className == null) return Colors.white;
    
    switch (className) {
      case 'keyword':
        return const Color(0xFF569CD6);
      case 'built_in':
        return const Color(0xFF4EC9B0);
      case 'string':
        return const Color(0xFFCE9178);
      case 'comment':
        return const Color(0xFF6A9955);
      case 'number':
        return const Color(0xFFB5CEA8);
      case 'function':
        return const Color(0xFFDCDCAA);
      case 'class-name':
        return const Color(0xFF4EC9B0);
      default:
        return Colors.white;
    }
  }
}

// 完整的演示应用
class VSCodeEditorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VSCode Flutter Editor',
      theme: ThemeData.dark(),
      home: VSCodeLayout(),
    );
  }
}

void main() {
  runApp(VSCodeEditorApp());
}