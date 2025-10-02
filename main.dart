// main.dart - 扩展版本
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:convert';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter VSCode Editor',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
        primaryColor: Color(0xFF007ACC),
        cardColor: Color(0xFF252526),
        dividerColor: Color(0xFF3C3C3C),
      ),
      home: VSCodeEditor(),
    );
  }
}

class VSCodeEditor extends StatefulWidget {
  @override
  _VSCodeEditorState createState() => _VSCodeEditorState();
}

class _VSCodeEditorState extends State<VSCodeEditor> {
  String currentContent = '';
  String currentFile = '';
  List<String> openFiles = [];
  Map<String, String> fileContents = {};
  List<String> recentFiles = [];
  Map<String, String> fileTypes = {};
  
  // 侧边栏状态
  bool _showSidebar = true;
  int _activeSidebarTab = 0;
  
  // 编辑器设置
  bool _wordWrap = false;
  int _fontSize = 14;
  String _theme = 'dark';
  
  // 搜索功能
  String _searchText = '';
  bool _showSearch = false;
  
  // 终端状态
  bool _showTerminal = false;

  @override
  void initState() {
    super.initState();
    _loadSampleFiles();
  }

  void _loadSampleFiles() {
    String sampleDart = '''import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
''';
    
    String sampleHtml = '''<!DOCTYPE html>
<html>
<head>
    <title>Sample</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Hello World</h1>
        <p>This is a sample HTML file with CSS styling.</p>
        <ul>
            <li>Item 1</li>
            <li>Item 2</li>
            <li>Item 3</li>
        </ul>
    </div>
</body>
</html>''';
    
    String sampleCss = '''/* Sample CSS file */
body {
    background-color: #f5f5f5;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.header {
    background-color: #333;
    color: white;
    padding: 1rem;
    border-radius: 5px;
}

.button {
    background-color: #007ACC;
    color: white;
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

.button:hover {
    background-color: #005A9E;
}''';
    
    _openFile('lib/main.dart', sampleDart);
    _openFile('web/index.html', sampleHtml);
    _openFile('assets/style.css', sampleCss);
    _switchFile('lib/main.dart');
  }

  void _openFile(String fileName, String content) {
    if (!openFiles.contains(fileName)) {
      openFiles.add(fileName);
    }
    fileContents[fileName] = content;
    fileTypes[fileName] = _getFileType(fileName);
    setState(() {});
  }

  String _getFileType(String fileName) {
    String ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.dart': return 'dart';
      case '.html': return 'html';
      case '.css': return 'css';
      case '.js': return 'javascript';
      case '.json': return 'json';
      case '.yaml': return 'yaml';
      case '.md': return 'markdown';
      default: return 'text';
    }
  }

  void _switchFile(String fileName) {
    currentFile = fileName;
    currentContent = fileContents[fileName] ?? '';
    setState(() {});
  }

  void _closeFile(String fileName) {
    openFiles.remove(fileName);
    fileContents.remove(fileName);
    fileTypes.remove(fileName);
    if (currentFile == fileName) {
      if (openFiles.isNotEmpty) {
        _switchFile(openFiles.last);
      } else {
        currentFile = '';
        currentContent = '';
      }
    }
    setState(() {});
  }

  void _saveFile() async {
    if (currentFile.isNotEmpty) {
      try {
        Directory documentsDir = await getApplicationDocumentsDirectory();
        String filePath = path.join(documentsDir.path, currentFile);
        
        // 确保目录存在
        String dirPath = path.dirname(filePath);
        await Directory(dirPath).create(recursive: true);
        
        File file = File(filePath);
        await file.writeAsString(currentContent);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已保存: $currentFile')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  void _newFile() {
    String newFileName = 'untitled_${DateTime.now().millisecondsSinceEpoch}.dart';
    _openFile(newFileName, '');
    _switchFile(newFileName);
  }

  Future<void> _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      String fileName = path.basename(file.path);
      _openFile(fileName, content);
      _switchFile(fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧边栏
          if (_showSidebar)
            Container(
              width: 250,
              color: Color(0xFF333333),
              child: Column(
                children: [
                  // 侧边栏标签页
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      border: Border(bottom: BorderSide(color: Color(0xFF3C3C3C))),
                    ),
                    child: Row(
                      children: [
                        _buildSidebarTab('Explorer', 0),
                        _buildSidebarTab('Search', 1),
                        _buildSidebarTab('Git', 2),
                        _buildSidebarTab('Debug', 3),
                      ],
                    ),
                  ),
                  // 标签页内容
                  Expanded(
                    child: _buildSidebarContent(),
                  ),
                ],
              ),
            ),
          
          // 主编辑区域
          Expanded(
            child: Column(
              children: [
                // 标签页栏
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF2D2D2D),
                    border: Border(bottom: BorderSide(color: Color(0xFF3C3C3C))),
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...openFiles.map((file) => _buildTab(file)),
                      IconButton(
                        icon: Icon(Icons.add, size: 18),
                        onPressed: _newFile,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tight(Size(40, 40)),
                      ),
                    ],
                  ),
                ),
                // 搜索栏
                if (_showSearch)
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      border: Border(bottom: BorderSide(color: Color(0xFF3C3C3C))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '搜索...',
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchText = value;
                              });
                            },
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showSearch = false;
                              _searchText = '';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                // 编辑器
                Expanded(
                  child: currentFile.isNotEmpty
                      ? CodeEditor(
                          content: currentContent,
                          fileType: fileTypes[currentFile] ?? 'text',
                          onChanged: (value) {
                            setState(() {
                              currentContent = value;
                              fileContents[currentFile] = value;
                            });
                          },
                          fontSize: _fontSize,
                          wordWrap: _wordWrap,
                          theme: _theme,
                        )
                      : Container(
                          color: Color(0xFF1E1E1E),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.insert_drive_file, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  '打开或创建一个文件',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _newFile,
                                  child: Text('新建文件'),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _openFilePicker,
                                  child: Text('打开文件'),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                // 终端
                if (_showTerminal)
                  Container(
                    height: 200,
                    color: Color(0xFF0C0C0C),
                    child: TerminalPanel(),
                  ),
                // 状态栏
                Container(
                  height: 25,
                  decoration: BoxDecoration(
                    color: Color(0xFF007ACC),
                    border: Border(top: BorderSide(color: Color(0xFF3C3C3C))),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          currentFile.isEmpty ? 'No file' : currentFile,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.settings, size: 16, color: Colors.white),
                            onPressed: _showSettingsDialog,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints.tight(Size(24, 24)),
                          ),
                          IconButton(
                            icon: Icon(Icons.search, size: 16, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showSearch = !_showSearch;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints.tight(Size(24, 24)),
                          ),
                          IconButton(
                            icon: Icon(Icons.terminal, size: 16, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showTerminal = !_showTerminal;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints.tight(Size(24, 24)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'UTF-8',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // 顶部菜单栏
      appBar: AppBar(
        title: Text('Flutter VSCode Editor'),
        backgroundColor: Color(0xFF333333),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 8),
                    Text('新建文件'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.folder_open, size: 16),
                    SizedBox(width: 8),
                    Text('打开文件'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save, size: 16),
                    SizedBox(width: 8),
                    Text('保存'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 16),
                    SizedBox(width: 8),
                    Text('设置'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeSidebarTab = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: _activeSidebarTab == index ? Color(0xFF252526) : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: _activeSidebarTab == index ? Color(0xFF007ACC) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: _activeSidebarTab == index ? Colors.white : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    switch (_activeSidebarTab) {
      case 0: // Explorer
        return FileExplorer(
          files: openFiles,
          fileTypes: fileTypes,
          onFileSelect: _switchFile,
          onFileClose: _closeFile,
        );
      case 1: // Search
        return SearchPanel();
      case 2: // Git
        return GitPanel();
      case 3: // Debug
        return DebugPanel();
      default:
        return Container();
    }
  }

  Widget _buildTab(String fileName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: currentFile == fileName ? Color(0xFF2D2D2D) : Color(0xFF333333),
        border: Border(
          right: BorderSide(color: Color(0xFF3C3C3C)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(fileName),
            color: _getFileIconColor(fileName),
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            fileName,
            style: TextStyle(
              color: currentFile == fileName ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 14),
            onPressed: () => _closeFile(fileName),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(Size(20, 20)),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    String ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.dart': return Icons.code;
      case '.html': return Icons.language;
      case '.css': return Icons.style;
      case '.js': return Icons.code;
      case '.json': return Icons.data_object;
      case '.yaml': return Icons.text_snippet;
      case '.md': return Icons.article;
      default: return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(String fileName) {
    String ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.dart': return Colors.blue;
      case '.html': return Colors.orange;
      case '.css': return Colors.purple;
      case '.js': return Colors.yellow;
      case '.json': return Colors.green;
      case '.yaml': return Colors.cyan;
      case '.md': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'new':
        _newFile();
        break;
      case 'open':
        _openFilePicker();
        break;
      case 'save':
        _saveFile();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('编辑器设置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('字体大小: $_fontSize'),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        _fontSize = _fontSize > 8 ? _fontSize - 1 : _fontSize;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _fontSize = _fontSize < 24 ? _fontSize + 1 : _fontSize;
                      });
                    },
                  ),
                ],
              ),
              SwitchListTile(
                title: Text('自动换行'),
                value: _wordWrap,
                onChanged: (value) {
                  setState(() {
                    _wordWrap = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _theme,
                decoration: InputDecoration(labelText: '主题'),
                items: [
                  DropdownMenuItem(value: 'dark', child: Text('暗色主题')),
                  DropdownMenuItem(value: 'light', child: Text('亮色主题')),
                ],
                onChanged: (value) {
                  setState(() {
                    _theme = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }
}

class CodeEditor extends StatefulWidget {
  final String content;
  final String fileType;
  final Function(String) onChanged;
  final int fontSize;
  final bool wordWrap;
  final String theme;

  const CodeEditor({
    Key? key,
    required this.content,
    required this.fileType,
    required this.onChanged,
    this.fontSize = 14,
    this.wordWrap = false,
    this.theme = 'dark',
  }) : super(key: key);

  @override
  _CodeEditorState createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _focusNode = FocusNode();
    
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 对于支持高亮的语言，使用HighlightView
    if (widget.fileType != 'text') {
      return Container(
        color: Color(0xFF1E1E1E),
        child: HighlightView(
          widget.content,
          language: widget.fileType,
          theme: widget.theme == 'dark' ? atomOneDarkTheme : atomOneLightTheme,
          padding: EdgeInsets.all(16),
          textStyle: TextStyle(
            fontSize: widget.fontSize.toDouble(),
            height: 1.4,
          ),
        ),
      );
    }
    
    // 对于不支持高亮的文本，使用普通编辑器
    return Container(
      color: Color(0xFF1E1E1E),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: widget.fontSize.toDouble(),
          color: Colors.white,
          height: 1.4,
        ),
        keyboardType: TextInputType.multiline,
        maxLines: widget.wordWrap ? null : 1,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }
}

class FileExplorer extends StatelessWidget {
  final List<String> files;
  final Map<String, String> fileTypes;
  final Function(String) onFileSelect;
  final Function(String) onFileClose;

  const FileExplorer({
    Key? key,
    required this.files,
    required this.fileTypes,
    required this.onFileSelect,
    required this.onFileClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF252526),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(Icons.folder, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Text(
                  'WORKSPACE',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                String fileName = files[index];
                String fileType = fileTypes[fileName] ?? 'text';
                
                IconData icon;
                Color color;
                
                switch (fileType) {
                  case 'dart':
                    icon = Icons.code;
                    color = Colors.blue;
                    break;
                  case 'html':
                    icon = Icons.language;
                    color = Colors.orange;
                    break;
                  case 'css':
                    icon = Icons.style;
                    color = Colors.purple;
                    break;
                  case 'javascript':
                    icon = Icons.code;
                    color = Colors.yellow;
                    break;
                  case 'json':
                    icon = Icons.data_object;
                    color = Colors.green;
                    break;
                  case 'yaml':
                    icon = Icons.text_snippet;
                    color = Colors.cyan;
                    break;
                  case 'markdown':
                    icon = Icons.article;
                    color = Colors.blueGrey;
                    break;
                  default:
                    icon = Icons.insert_drive_file;
                    color = Colors.grey;
                }
                
                return ListTile(
                  leading: Icon(icon, color: color, size: 16),
                  title: Text(
                    fileName,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  subtitle: Text(
                    fileType.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  onTap: () => onFileSelect(fileName),
                  onLongPress: () => onFileClose(fileName),
                  dense: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPanel extends StatefulWidget {
  @override
  _SearchPanelState createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  String _searchText = '';
  String _replaceText = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF252526),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: '搜索...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Color(0xFF3C3C3C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: '替换...',
              prefixIcon: Icon(Icons.find_replace, color: Colors.grey),
              filled: true,
              fillColor: Color(0xFF3C3C3C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _replaceText = value;
              });
            },
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _searchText.isNotEmpty ? () {} : null,
                  icon: Icon(Icons.search),
                  label: Text('查找'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF007ACC),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _searchText.isNotEmpty && _replaceText.isNotEmpty ? () {} : null,
                  icon: Icon(Icons.find_replace),
                  label: Text('替换'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF007ACC),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: _searchText.isNotEmpty
                ? ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.find_in_page, color: Colors.blue),
                        title: Text('结果 1', style: TextStyle(color: Colors.white)),
                        subtitle: Text('匹配内容...', style: TextStyle(color: Colors.grey)),
                        dense: true,
                      ),
                      ListTile(
                        leading: Icon(Icons.find_in_page, color: Colors.blue),
                        title: Text('结果 2', style: TextStyle(color: Colors.white)),
                        subtitle: Text('匹配内容...', style: TextStyle(color: Colors.grey)),
                        dense: true,
                      ),
                    ],
                  )
                : ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.search_off, color: Colors.grey),
                        title: Text('输入搜索词', style: TextStyle(color: Colors.grey)),
                        dense: true,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class GitPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF252526),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.commit, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text('Source Control', style: TextStyle(color: Colors.white)),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.commit, color: Colors.green, size: 16),
                  title: Text('No changes', style: TextStyle(color: Colors.grey)),
                  dense: true,
                ),
                ListTile(
                  leading: Icon(Icons.commit, color: Colors.blue, size: 16),
                  title: Text('Fetch', style: TextStyle(color: Colors.white)),
                  subtitle: Text('获取远程更新', style: TextStyle(color: Colors.grey)),
                  dense: true,
                ),
                ListTile(
                  leading: Icon(Icons.commit, color: Colors.orange, size: 16),
                  title: Text('Push', style: TextStyle(color: Colors.white)),
                  subtitle: Text('推送更改', style: TextStyle(color: Colors.grey)),
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DebugPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF252526),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Text('Debug', style: TextStyle(color: Colors.white)),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.play_arrow, color: Colors.green, size: 16),
                  title: Text('Start Debugging', style: TextStyle(color: Colors.white)),
                  subtitle: Text('开始调试会话', style: TextStyle(color: Colors.grey)),
                  dense: true,
                ),
                ListTile(
                  leading: Icon(Icons.stop, color: Colors.red, size: 16),
                  title: Text('Stop Debugging', style: TextStyle(color: Colors.white)),
                  subtitle: Text('停止调试会话', style: TextStyle(color: Colors.grey)),
                  dense: true,
                ),
                ListTile(
                  leading: Icon(Icons.pause, color: Colors.orange, size: 16),
                  title: Text('Pause', style: TextStyle(color: Colors.white)),
                  subtitle: Text('暂停程序执行', style: TextStyle(color: Colors.grey)),
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TerminalPanel extends StatefulWidget {
  @override
  _TerminalPanelState createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  final List<String> _output = [
    'Flutter VSCode Terminal',
    'Welcome to the terminal emulator',
    'Type "help" for available commands',
    '',
    'flutter@vscode:~\$ '
  ];
  String _currentInput = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF0C0C0C),
      child: Column(
        children: [
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: Color(0xFF252526),
              border: Border(bottom: BorderSide(color: Color(0xFF3C3C3C))),
            ),
            child: Row(
              children: [
                SizedBox(width: 8),
                Icon(Icons.terminal, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Terminal', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: _output.length + 1,
                itemBuilder: (context, index) {
                  if (index == _output.length) {
                    return Row(
                      children: [
                        Text(
                          'flutter@vscode:~\$ ',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                            onChanged: (value) {
                              setState(() {
                                _currentInput = value;
                              });
                            },
                            onSubmitted: (value) {
                              _handleCommand(value);
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return Text(
                    _output[index],
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCommand(String command) {
    setState(() {
      _output.add('flutter@vscode:~\$ $command');
      
      if (command == 'help') {
        _output.add('Available commands:');
        _output.add('  help - Show this help');
        _output.add('  clear - Clear terminal');
        _output.add('  flutter doctor - Check Flutter setup');
        _output.add('  flutter run - Run Flutter app');
      } else if (command == 'clear') {
        _output.clear();
      } else if (command == 'flutter doctor') {
        _output.add('Doctor summary (to see all details, run flutter doctor -v):');
        _output.add('[✓] Flutter (Channel stable, 3.0.0, on macOS 12.0 21A389 darwin-x64)');
        _output.add('[✓] Android toolchain - develop for Android devices');
        _output.add('[✓] Xcode - develop for iOS and macOS');
        _output.add('[✓] Chrome - develop for the web');
      } else if (command == 'flutter run') {
        _output.add('Running "flutter run" in app...');
        _output.add('Launching lib/main.dart on Chrome...');
        _output.add('✓  Built build/web in 3.2s');
        _output.add('Connecting to VM Service at ws://127.0.0.1:50000/ws');
      } else {
        _output.add('Command not found: $command');
      }
      
      _output.add('flutter@vscode:~\$ ');
      _currentInput = '';
    });
  }
}