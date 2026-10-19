import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const FinderApp());

class Repo {
  Repo.fromJson(Map<String, dynamic> j)
      : name = j['name'] ?? '', fullName = j['full_name'] ?? '',
        description = (j['description'] ?? '').toString(), htmlUrl = j['html_url'] ?? '',
        stars = j['stargazers_count'] ?? 0, language = j['language'] ?? 'Dart',
        updated = DateTime.tryParse(j['updated_at'] ?? '') ?? DateTime.now();
  final String name, fullName, description, htmlUrl, language;
  final int stars;
  final DateTime updated;
}

class FinderApp extends StatelessWidget {
  const FinderApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false, title: 'KlenCode Project Finder',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xff17634d)),
        home: const FinderHome());
}

class FinderHome extends StatefulWidget {
  const FinderHome({super.key});
  @override
  State<FinderHome> createState() => _FinderHomeState();
}

class _FinderHomeState extends State<FinderHome> {
  final search = TextEditingController(text: 'flutter');
  List<Repo> repos = [];
  bool loading = false;
  String? error;
  int minimumStars = 0;

  Future<void> findProjects() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() { loading = true; error = null; });
    final q = Uri.encodeQueryComponent('${search.text.trim()} language:Dart filename:pubspec.yaml');
    final uri = Uri.parse('https://api.github.com/search/repositories?q=$q&sort=stars&order=desc&per_page=20');
    try {
      final response = await http.get(uri, headers: {'Accept': 'application/vnd.github+json'});
      if (response.statusCode != 200) throw Exception();
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final found = (data['items'] as List).map((e) => Repo.fromJson(e)).where((r) => r.stars >= minimumStars).toList();
      if (mounted) setState(() { repos = found; loading = false; });
    } catch (_) {
      if (mounted) setState(() { error = 'تعذر البحث. تحقق من الإنترنت أو حدّ الاستخدام في GitHub.'; loading = false; });
    }
  }

  String summary(Repo r) => '''ملخص المشروع

الاسم: ${r.fullName}
الوصف: ${r.description.isEmpty ? 'لا يوجد وصف في GitHub.' : r.description}
اللغة: ${r.language}
النجوم: ${r.stars}
آخر تحديث: ${r.updated.year}-${r.updated.month}-${r.updated.day}

لماذا يناسب Klencode؟
يظهر أنه مشروع Flutter/Dart ويحتوي على pubspec.yaml، لذلك يمكن تجربته داخل Klencode.

طريقة البناء:
1. حمّل المشروع وافتح مجلده في Klencode.
2. شغّل: flutter pub get
3. شغّل: flutter build apk --debug
4. الملف: build/app/outputs/flutter-apk/app-debug.apk

ملاحظة: راجع README وحل أي حزم أو إعدادات خاصة.''';

  void showSummary(Repo repo) => showDialog(context: context, builder: (_) => AlertDialog(
    title: Text(repo.name), content: SingleChildScrollView(child: Text(summary(repo), textDirection: TextDirection.rtl, style: const TextStyle(height: 1.7))),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))]));

  void showUrl(String url) => showDialog(context: context, builder: (_) => AlertDialog(
    title: const Text('رابط المشروع'), content: SelectableText(url),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))]));

  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(
    appBar: AppBar(title: const Text('KlenCode Project Finder'), centerTitle: true),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('ابحث تلقائيًا عن مشاريع Flutter التي يمكن تجربتها وبناؤها داخل Klencode IDE.', style: TextStyle(fontSize: 16, height: 1.6)))),
      const SizedBox(height: 12),
      TextField(controller: search, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'كلمة البحث', hintText: 'weather shop notes', border: OutlineInputBorder()), onSubmitted: (_) => findProjects()),
      const SizedBox(height: 8),
      DropdownButtonFormField<int>(value: minimumStars, decoration: const InputDecoration(labelText: 'الحد الأدنى للنجوم', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 0, child: Text('كل المشاريع')), DropdownMenuItem(value: 10, child: Text('10 نجوم أو أكثر')), DropdownMenuItem(value: 100, child: Text('100 نجمة أو أكثر'))], onChanged: (v) => setState(() => minimumStars = v ?? 0)),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: loading ? null : findProjects, icon: const Icon(Icons.search), label: Text(loading ? 'جاري البحث...' : 'بحث تلقائي')),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
      const SizedBox(height: 12),
      if (!loading && repos.isEmpty && error == null) const Text('اكتب كلمة ثم اضغط بحث تلقائي.', textAlign: TextAlign.center),
      ...repos.map((repo) => Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(repo.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        Text(repo.description.isEmpty ? 'لا يوجد وصف' : repo.description, maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8), Text('★ ${repo.stars}   •   ${repo.language}', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8), Row(children: [Expanded(child: FilledButton(onPressed: () => showSummary(repo), child: const Text('تلخيص وبناء'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: () => showUrl(repo.htmlUrl), child: const Text('رابط GitHub')))])
      ]))))
    ]),
  ));
}