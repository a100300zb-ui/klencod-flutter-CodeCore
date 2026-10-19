import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const PyRunnerApp());

class PyRunnerApp extends StatelessWidget {
  const PyRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مشغّل بايثون',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const RunnerPage(),
    );
  }
}

class RunnerPage extends StatefulWidget {
  const RunnerPage({super.key});

  @override
  State<RunnerPage> createState() => _RunnerPageState();
}

class _RunnerPageState extends State<RunnerPage> {
  // قناة الاتصال مع كود أندرويد (Kotlin) اللي بيشغّل بايثون
  static const _channel = MethodChannel('py_runner/python');

  final _codeController = TextEditingController(
    text: 'print("أهلاً من بايثون!")\n\nfor i in range(3):\n    print("رقم", i)\n',
  );
  String _output = '';
  String? _fileName;
  bool _running = false;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _output = 'جاري التشغيل...';
    });
    try {
      final result = await _channel.invokeMethod<String>(
        'runCode',
        {'code': _codeController.text},
      );
      setState(() => _output = result ?? '');
    } on PlatformException catch (e) {
      setState(() => _output = 'خطأ: ${e.message}');
    } finally {
      setState(() => _running = false);
    }
  }

  Future<void> _pickFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['py'],
    );
    if (picked == null || picked.files.single.path == null) return;

    final file = File(picked.files.single.path!);
    final content = await file.readAsString();
    setState(() {
      _codeController.text = content;
      _fileName = picked.files.single.name;
      _output = '';
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_fileName ?? 'مشغّل بايثون'),
          actions: [
            IconButton(
              tooltip: 'فتح ملف .py',
              icon: const Icon(Icons.folder_open),
              onPressed: _pickFile,
            ),
            IconButton(
              tooltip: 'مسح',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() {
                _codeController.clear();
                _output = '';
                _fileName = null;
              }),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '# اكتب كود بايثون هنا',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _running ? null : _run,
                  icon: _running
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: const Text('تشغيل'),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _output.isEmpty ? '// النتيجة هتظهر هنا' : _output,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}