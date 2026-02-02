import 'dart:io';

Map<String, String> loadEnvFile(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) {
    throw Exception('File .env không tồn tại: $filePath');
  }
  final lines = file.readAsLinesSync();
  final env = <String, String>{};
  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final index = line.indexOf('=');
    if (index == -1) continue;
    final key = line.substring(0, index).trim();
    final value = line.substring(index + 1).trim();
    env[key] = value;
  }
  return env;
}

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Vui lòng cung cấp tên module, ví dụ: dart run core_base_bloc/lib/auto_render/render_base.dart example');
    return;
  }

  final moduleName = args[0].toLowerCase();
  final env = loadEnvFile('.env');

  final pathView = env['PATH_VIEW']?.trim();
  final pathRouter = env['PATH_ROUTER']?.trim();
  final pathDI = env['PATH_DI']?.trim();
  final packageImport = env['PACKAGE_IMPORT']?.trim();

  if (pathView == null || pathView.isEmpty) throw Exception('PATH_VIEW cannot be left blank');
  if (pathRouter == null || pathRouter.isEmpty) throw Exception('PATH_ROUTER cannot be left blank');
  if (pathDI == null || pathDI.isEmpty) throw Exception('PATH_DI cannot be left blank');
  if (packageImport == null || packageImport.isEmpty) throw Exception('PACKAGE_IMPORT cannot be left blank');

  // Tạo root folder nếu chưa tồn tại
  final rootDir = Directory(pathView);
  if (!rootDir.existsSync()) {
    rootDir.createSync(recursive: true);
    print('Tạo folder gốc: $pathView');
  }

  // Tạo folder module
  final folderPath = '$pathView/$moduleName';
  final folder = Directory(folderPath);
  if (!folder.existsSync()) {
    folder.createSync(recursive: true);
    print('Tạo folder module: $folderPath');
  }

  // Helper: snake_case -> PascalCase
  String toPascalCase(String s) {
    return s.split('_').map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)).join();
  }

  final capModule = toPascalCase(moduleName);

  // ====================== 1. Tạo các file cơ bản ======================
  final filesToCreate = [
    // Bloc
    _FileData(
      path: '$folderPath/${moduleName}_bloc.dart',
      content: '''
import 'package:core_base_bloc/core_base_bloc.dart';
part '${moduleName}_event.dart';
part '${moduleName}_state.dart';

class ${capModule}Bloc extends Bloc<${capModule}Event, ${capModule}State> {
  ${capModule}Bloc() : super(${capModule}State()) {
    // on<${capModule}Event>((event, emit) {});
  }
}
''',
    ),
    // Event
    _FileData(
      path: '$folderPath/${moduleName}_event.dart',
      content: '''
part of '${moduleName}_bloc.dart';

class ${capModule}Event {}
''',
    ),
    // State
    _FileData(
      path: '$folderPath/${moduleName}_state.dart',
      content: '''
part of '${moduleName}_bloc.dart';

class ${capModule}State {}
''',
    ),
    // View
    _FileData(
      path: '$folderPath/${moduleName}_view.dart',
      content: '''
import 'package:core_base_bloc/core_base_bloc.dart';
import '${moduleName}_bloc.dart';
import '${moduleName}_x_controller.dart';

class ${capModule}View extends BaseView<${capModule}XController, ${capModule}Bloc, ${capModule}State> {
  static const String router = "/${capModule}View";

  ${capModule}View({super.key});

  @override
  Widget zBuildView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('$capModule View')),
    );
  }
}
''',
    ),
    // XController
    _FileData(
      path: '$folderPath/${moduleName}_x_controller.dart',
      content: '''
import 'package:core_base_bloc/core_base_bloc.dart';
import '${moduleName}_bloc.dart';

class ${capModule}XController extends BaseXController<${capModule}Bloc> {}
''',
    ),
  ];

  for (final f in filesToCreate) {
    final file = File(f.path);
    file.writeAsStringSync(f.content.trim() + '\n');
    print('Tạo file: ${f.path}');
  }

  // ====================== 2. Cập nhật Router ======================
  await _updateRouterFile(pathRouter, packageImport, moduleName, capModule);

  // ====================== 3. Cập nhật DI ======================
  await _updateDIFunction(pathDI, packageImport, capModule, moduleName);

  print('Hoàn tất! Module "$moduleName" đã được tạo và tích hợp.');
}

Future<void> _updateRouterFile(String pathRouter, String packageImport, String moduleName, String capModule) async {
  final routerFile = File(pathRouter);
  String content = '';

  if (!routerFile.existsSync() || (await routerFile.length()) == 0) {
    content = '''
import 'package:core_base_bloc/core_base_bloc.dart';
import 'package:flutter/cupertino.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        return null;
    }
  }
}
''';
  } else {
    content = await routerFile.readAsString();
  }

  final importBloc = "import '$packageImport/view/$moduleName/${moduleName}_bloc.dart';";
  final importView = "import '$packageImport/view/$moduleName/${moduleName}_view.dart';";

  if (!content.contains(importBloc)) {
    content = '$importBloc\n$content';
  }
  if (!content.contains(importView)) {
    content = '$importView\n$content';
  }

  final caseCode = '''
      case ${capModule}View.router:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => ${capModule}Bloc(),
            child: ${capModule}View(),
          ),
        );
''';

  if (!content.contains('${capModule}View.router')) {
    final switchPos = content.indexOf('switch (settings.name)');
    if (switchPos != -1) {
      final openBrace = content.indexOf('{', switchPos);
      if (openBrace != -1) {
        final insertPos = openBrace + 1;
        content = '${content.substring(0, insertPos)}\n$caseCode${content.substring(insertPos)}';
      }
    }
  }

  await routerFile.writeAsString(content.trimRight() + '\n');
  print('Đã cập nhật router: $pathRouter');
}

Future<void> _updateDIFunction(String pathDI, String packageImport, String capModule, String moduleName) async {
  final diFile = File(pathDI);
  String content = '';

  if (!diFile.existsSync() || (await diFile.length()) == 0) {
    content = '''
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
}
''';
  } else {
    content = await diFile.readAsString();
  }

  // Thêm import nếu chưa có
  final importLine = "import '$packageImport/view/$moduleName/${moduleName}_x_controller.dart';";
  if (!content.contains(importLine) && !content.contains('${moduleName}_x_controller.dart')) {
    final getItImportPos = content.indexOf("import 'package:get_it/get_it.dart';");
    if (getItImportPos != -1) {
      final endOfLine = content.indexOf('\n', getItImportPos);
      if (endOfLine != -1) {
        content = content.substring(0, endOfLine + 1) + importLine + '\n' + content.substring(endOfLine + 1);
      }
    } else {
      content = '$importLine\n$content';
    }
  }

  // Thêm register nếu chưa có
  final registerLine = '  getIt.registerLazySingleton<${capModule}XController>(() => ${capModule}XController());';

  if (content.contains('<${capModule}XController>')) {
    print('DI đã có ${capModule}XController, bỏ qua.');
  } else {
    final funcRegex = RegExp(r'void\s+setupDependencies\s*\(\s*\)\s*\{');
    final match = funcRegex.firstMatch(content);

    if (match != null) {
      final startBrace = content.indexOf('{', match.end - 1);
      final endBrace = content.lastIndexOf('}');

      if (startBrace != -1 && endBrace != -1 && endBrace > startBrace) {
        final body = content.substring(startBrace + 1, endBrace).trim();

        String newBody;
        if (body.isEmpty) {
          newBody = '\n$registerLine';
        } else {
          // Thêm vào cuối, trước dấu }
          newBody = '$body\n$registerLine\n';
        }

        content = content.substring(0, startBrace + 1) + newBody + content.substring(endBrace);
      }
    }
  }

  // Lưu lại, đảm bảo không có dòng trắng thừa ở cuối mỗi dòng
  final cleaned = content
      .split('\n')
      .map((line) => line.trimRight())
      .where((line) => line.isNotEmpty || line.trim().isEmpty) // giữ dòng trắng có ý nghĩa
      .join('\n')
      .trimRight();

  await diFile.writeAsString(cleaned + '\n');
  print('Đã cập nhật DI: $pathDI → ${capModule}XController được thêm');
}

class _FileData {
  final String path;
  final String content;

  _FileData({required this.path, required this.content});
}