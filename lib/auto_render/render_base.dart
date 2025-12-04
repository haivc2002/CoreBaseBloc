import 'dart:io';
import 'dart:convert';

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

  final pathView = env['PATH_VIEW'];
  final pathRouter = env['PATH_ROUTER'];
  final pathDI = env['PATH_DI'];
  final packageImport = env['PACKAGE_IMPORT'];

  if (pathView == null || pathView == "") throw Exception('pathView cannot be left blank');
  if (pathRouter == null || pathRouter == "") throw Exception('pathRouter cannot be left blank');
  if (pathDI == null || pathDI == "") throw Exception('pathDI cannot be left blank');
  if (packageImport == null || packageImport == "") throw Exception('packageImport cannot be left blank');

  // Load config.json
  // final configFile = File('core_base_bloc/lib/auto_render/render_base.json');
  // if (!await configFile.exists()) {
  //   print('Không tìm thấy file render_base.json');
  //   return;
  // }
  //
  // final config = jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
  // if (config['pathView'] == null || config['pathView'] == "") {
  //   throw Exception('pathView trong render_base.json không được để trống');
  // }
  //
  // final pathView = config['pathView'] as String;
  // final pathRouter = config['pathRouter'] as String;
  // final pathDI = config['pathDI'] as String;
  // final packageImport = config['packageImport'] as String;

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
  final files = [
    // Bloc
    _createFile('$folderPath/${moduleName}_bloc.dart', '''
import 'package:core_base_bloc/core_base_bloc.dart';
part '${moduleName}_event.dart';
part '${moduleName}_state.dart';

class ${capModule}Bloc extends Bloc<${capModule}Event, ${capModule}State> {
  ${capModule}Bloc() : super(${capModule}State()) {
    // on<${capModule}Event>((event, emit) {});
  }
}
'''),

    // Event
    _createFile('$folderPath/${moduleName}_event.dart', '''
part of '${moduleName}_bloc.dart';

class ${capModule}Event {}
'''),

    // State
    _createFile('$folderPath/${moduleName}_state.dart', '''
part of '${moduleName}_bloc.dart';

class ${capModule}State {}
'''),

    // View
    _createFile('$folderPath/${moduleName}_view.dart', '''
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
'''),

    // XController
    _createFile('$folderPath/${moduleName}_x_controller.dart', '''
import 'package:core_base_bloc/core_base_bloc.dart';
import '${moduleName}_bloc.dart';

class ${capModule}XController extends BaseXController<${capModule}Bloc> {}
'''),
  ];

  for (final f in files) {
    print('Tạo file: ${f.path}');
  }

  // ====================== 2. Cập nhật Router ======================
  final routerFile = File(pathRouter);
  String routerContent = '';

  if (!routerFile.existsSync() || await routerFile.length() == 0) {
    routerContent = '''
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
    routerFile.createSync(recursive: true);
  } else {
    routerContent = routerFile.readAsStringSync();
  }

  // Thêm import
  final importBloc = "import '$packageImport/view/$moduleName/${moduleName}_bloc.dart';";
  final importView = "import '$packageImport/view/$moduleName/${moduleName}_view.dart';";

  if (!routerContent.contains(importBloc)) {
    routerContent = '$importBloc\n$routerContent';
  }
  if (!routerContent.contains(importView)) {
    routerContent = '$importView\n$routerContent';
  }

  // Thêm case route
  final switchCase = '''
      case ${capModule}View.router:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => ${capModule}Bloc(),
            child: ${capModule}View(),
          ),
        );
''';

  if (!routerContent.contains(switchCase.trim())) {
    final switchIndex = routerContent.indexOf('switch (settings.name)');
    if (switchIndex != -1) {
      final braceIndex = routerContent.indexOf('{', switchIndex);
      if (braceIndex != -1) {
        final insertPos = braceIndex + 1;
        routerContent = '${routerContent.substring(0, insertPos)}\n$switchCase${routerContent.substring(insertPos)}';
      }
    }
  }

  routerFile.writeAsStringSync(routerContent);
  print('Đã cập nhật router: $pathRouter');

  // ====================== 3. Cập nhật DI ======================
  final diFile = File(pathDI);
  String diContent = '';

  if (!diFile.existsSync() || (await diFile.length()) == 0) {
    diContent = '''import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
}
''';
    diFile.parent.createSync(recursive: true);
  } else {
    diContent = diFile.readAsStringSync();
  }

  final importLine = "import '$packageImport/view/$moduleName/${moduleName}_x_controller.dart';";
  if (!diContent.contains(importLine)) {
    final getItImport = "import 'package:get_it/get_it.dart';";
    final pos = diContent.indexOf(getItImport);
    if (pos != -1) {
      final insertPos = diContent.indexOf('\n', pos) + 1;
      diContent = diContent.substring(0, insertPos) + importLine + '\n' + diContent.substring(insertPos);
    } else {
      diContent = importLine + '\n' + diContent;
    }
  }

  // 2. Dòng register cần thêm
  final registerLine = '  getIt.registerLazySingleton<${capModule}XController>(() => ${capModule}XController());';

  if (diContent.contains('<${capModule}XController>')) {
    print('DI đã có ${capModule}XController, bỏ qua.');
  } else {
    final setupRegex = RegExp(r'void\s+setupDependencies\(\)\s*\{');
    final match = setupRegex.firstMatch(diContent);

    if (match != null) {
      final braceOpenPos = diContent.indexOf('{', match.start);
      final braceClosePos = diContent.lastIndexOf('}');
      final inside = diContent.substring(braceOpenPos + 1, braceClosePos);

      if (inside.trim().isEmpty) {
        // Hàm rỗng → thêm dòng đầu tiên
        final newInside = '\n$registerLine\n';
        diContent = diContent.substring(0, braceOpenPos + 1) + newInside + diContent.substring(braceClosePos);
      } else {
        // Có nội dung → tìm dòng cuối cùng có register, thêm ngay sau nó (cùng format)
        final lines = inside.split('\n');
        var lastRegisterLineIndex = -1;

        for (var i = lines.length - 1; i >= 0; i--) {
          if (lines[i].trim().startsWith('getIt.registerLazySingleton')) {
            lastRegisterLineIndex = i;
            break;
          }
        }

        if (lastRegisterLineIndex != -1) {
          lines.insert(lastRegisterLineIndex + 1, registerLine);
        } else {
          lines.insert(0, registerLine);
        }

        final newInside = lines.join('\n');
        diContent = '${diContent.substring(0, braceOpenPos + 1)}\n$newInside${diContent.substring(braceClosePos)}';
      }
    }
  }

  diContent = '${diContent.split('\n').map((line) {
    return line.trimRight();
  }).join('\n').trim()}\n';

  diFile.writeAsStringSync(diContent);
  print('Đã cập nhật DI: $pathDI → ${capModule}XController được thêm đúng chuẩn!');
}

File _createFile(String path, String content) {
  final file = File(path);
  file.writeAsStringSync('${content.trim()}\n');
  return file;
}