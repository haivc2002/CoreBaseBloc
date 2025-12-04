import 'dart:io';
import 'package:path/path.dart' as p;

/// ------------------------------------------------------------
/// AUTO STATE GENERATOR (render_state_file.dart)
/// ------------------------------------------------------------
/// EX:
/// class ExampleState {
///   final String? text;
/// }
/// Run in terminal dart run <path for render_state_file> <path to ExampleState>

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: dart run render_state_file.dart <file_path>');
    exit(1);
  }

  final filePath = arguments[0];
  final file = File(filePath);
  if (!file.existsSync()) {
    print('Error: File not found: $filePath');
    exit(1);
  }

  try {
    final content = file.readAsStringSync();
    final result = generateStateCode(content, filePath);

    if (result.hasError) {
      print('Render failed: ${result.errorMessage}');
      exit(1);
    }

    file.writeAsStringSync(result.content);
    print('Successfully updated: $filePath');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

// Kết quả trả về: nội dung mới + lỗi (nếu có)
class RenderResult {
  final String content;
  final bool hasError;
  final String errorMessage;

  RenderResult.success(this.content)
      : hasError = false,
        errorMessage = '';

  RenderResult.error(this.errorMessage)
      : hasError = true,
        content = '';
}

RenderResult generateStateCode(String originalContent, String filePath) {
  final header = _buildHeader(filePath);
  final lines = originalContent.split('\n');
  final bodyResult = <String>[];
  var i = 0;
  var skipBaseCopyWith = false;

  while (i < lines.length) {
    final trimmed = lines[i].trim();

    // Bỏ qua header cũ
    if (i == 0 && trimmed.startsWith('/// ------------------------------------------------------------')) {
      while (i < lines.length && lines[i].trim().isNotEmpty) {
        i++;
      }
      if (i < lines.length && lines[i].trim().isEmpty) i++;
      continue;
    }

    // Bỏ qua mixin BaseCopyWith cũ
    if (trimmed.startsWith('mixin BaseCopyWith')) {
      skipBaseCopyWith = true;
      i++;
      continue;
    }
    if (skipBaseCopyWith) {
      if (trimmed == '}') skipBaseCopyWith = false;
      i++;
      continue;
    }

    // Xử lý class
    if (trimmed.startsWith('class ') && !trimmed.contains('extends')) {
      final parseResult = _parseClass(lines, i);
      if (parseResult.hasError) {
        return RenderResult.error(parseResult.errorMessage!);
      }
      if (parseResult.classInfo != null && parseResult.classInfo!.fields.isNotEmpty) {
        _addSeparatorIfNeeded(bodyResult);
        bodyResult.add(_generateClassWithCopyWith(parseResult.classInfo!));
        i = parseResult.classInfo!.endIndex + 1;
        continue;
      }
    }

    // Bỏ qua phương thức copyWith cũ
    if (_isOldCopyWithMethod(lines, i)) {
      i = _skipMethodBlock(lines, i);
      continue;
    }

    bodyResult.add(lines[i]);
    i++;
  }

  // Dọn dẹp dòng trống cuối
  _trimTrailingEmptyLines(bodyResult);

  // Thêm BaseCopyWith mixin
  if (bodyResult.isNotEmpty && bodyResult.last.trim().isNotEmpty) {
    bodyResult.add('');
  }
  bodyResult.add(_getBaseCopyWithMixin());

  // Ghép header + body
  final finalLines = <String>[];
  finalLines.addAll(header.split('\n'));
  finalLines.add('');
  finalLines.addAll(bodyResult);

  return RenderResult.success('${finalLines.join('\n').trim()}\n');
}

void _addSeparatorIfNeeded(List<String> lines) {
  while (lines.isNotEmpty && lines.last.trim().isEmpty) {
    lines.removeLast();
  }
  if (lines.isNotEmpty) lines.add('');
}

void _trimTrailingEmptyLines(List<String> lines) {
  while (lines.isNotEmpty && lines.last.trim().isEmpty) {
    lines.removeLast();
  }
}

String _buildHeader(String filePath) {
  final scriptPath = Platform.script.toFilePath(); // path thật của file render_state_file.dart
  final relativeScript = p.relative(scriptPath, from: Directory.current.path);
  final relativeTarget = p.relative(filePath, from: Directory.current.path);

  final command = 'dart run $relativeScript $relativeTarget';

  return '''
/// ------------------------------------------------------------
/// AUTO-GENERATED STATE FILE
/// ------------------------------------------------------------
/// File: $filePath
///
/// ⚙️ How to automatically update this file:
///   Run the following command:
///     $command
///
/// This script will automatically generate or update:
///   • `copyWith` methods for state classes
///   • The `BaseCopyWith` mixin
///
/// 💡 Notes:
///   • Only classes with fields will have `copyWith` generated.
///   • If all fields are `final`, the constructor remains `const`.
///   • If any field is non-final, the constructor will remove `const`.
///   • Manual edits to generated sections may be overwritten.
/// ------------------------------------------------------------
''';
}


bool _isOldCopyWithMethod(List<String> lines, int index) {
  final trimmed = lines[index].trim();
  return RegExp(r'.*copyWith\(').hasMatch(trimmed);
}

int _skipMethodBlock(List<String> lines, int startIndex) {
  var i = startIndex;
  var braceCount = 0;

  // Tìm dấu {
  while (i < lines.length && !lines[i].contains('{')) i++;
  if (i >= lines.length) return i;

  braceCount += '{'.allMatches(lines[i]).length;
  braceCount -= '}'.allMatches(lines[i]).length;
  i++;

  while (i < lines.length && braceCount > 0) {
    braceCount += '{'.allMatches(lines[i]).length;
    braceCount -= '}'.allMatches(lines[i]).length;
    i++;
  }
  return i;
}

// Kết quả parse class: có thể có lỗi
class ClassParseResult {
  final ClassInfo? classInfo;
  final bool hasError;
  final String? errorMessage;

  ClassParseResult.success(this.classInfo)
      : hasError = false,
        errorMessage = null;

  ClassParseResult.error(this.errorMessage)
      : hasError = true,
        classInfo = null;
}

ClassParseResult _parseClass(List<String> lines, int startIndex) {
  final classLine = lines[startIndex];
  final className = _extractClassName(classLine);
  if (className == null) {
    return ClassParseResult.error('Không thể trích xuất tên class tại dòng ${startIndex + 1}');
  }

  final fields = <FieldInfo>[];
  var i = startIndex + 1;
  var braceCount = classLine.contains('{') ? 1 : 0;
  var inConstructor = false;
  var hasConstructor = false;

  while (i < lines.length && (braceCount > 0 || fields.isEmpty)) {
    final rawLine = lines[i];
    final trimmed = rawLine.trim();

    // Cập nhật brace count
    braceCount += '{'.allMatches(trimmed).length;
    braceCount -= '}'.allMatches(trimmed).length;

    // Phát hiện constructor
    if (trimmed.contains('$className(')) {
      hasConstructor = true;
      inConstructor = true;
    }
    if (inConstructor && trimmed.contains(')')) {
      inConstructor = false;
    }

    // Chỉ parse field nếu không trong constructor và chưa có constructor
    if (!inConstructor && !hasConstructor && _isFieldDeclaration(trimmed)) {
      final field = _parseField(trimmed, i + 1);
      if (field.hasError) {
        return ClassParseResult.error('Lỗi khai báo field tại dòng ${i + 1}: ${field.errorMessage}');
      }
      fields.add(field.fieldInfo!);
    }

    if (braceCount == 0 && i > startIndex) {
      return ClassParseResult.success(ClassInfo(
        name: className,
        fields: fields,
        startIndex: startIndex,
        endIndex: i,
      ));
    }
    i++;
  }

  return ClassParseResult.success(ClassInfo(
    name: className,
    fields: fields,
    startIndex: startIndex,
    endIndex: i - 1,
  ));
}

String? _extractClassName(String line) {
  final match = RegExp(r'class\s+(\w+)').firstMatch(line);
  return match?.group(1);
}

bool _isFieldDeclaration(String line) {
  // Hỗ trợ: final Type name;  hoặc  Type name;
  return (line.startsWith('final ') || !line.startsWith(RegExp(r'(final|\w+\s*\()'))) &&
      line.contains(';') &&
      !line.contains('(') &&
      !line.contains(')') &&
      !line.contains('=') &&
      !line.contains('{') &&
      !line.contains('}');
}

// Kết quả parse field
class FieldParseResult {
  final FieldInfo? fieldInfo;
  final bool hasError;
  final String? errorMessage;

  FieldParseResult.success(this.fieldInfo)
      : hasError = false,
        errorMessage = null;

  FieldParseResult.error(this.errorMessage)
      : hasError = true,
        fieldInfo = null;
}

FieldParseResult _parseField(String line, int lineNumber) {
  // Biểu thức: (final )?<Type> <name>;
  final pattern = RegExp(r'^(final\s+)?([\w\?<>\[\]]+)\s+([\w]+)\s*;');
  final match = pattern.firstMatch(line);

  if (match == null) {
    return FieldParseResult.error('Khai báo không hợp lệ, thiếu ";" hoặc cú pháp sai');
  }

  final type = match.group(2)!;
  final name = match.group(3)!;
  final isFinal = match.group(1) != null;

  return FieldParseResult.success(FieldInfo(
    type: type,
    name: name,
    isFinal: isFinal,
  ));
}

String _generateClassWithCopyWith(ClassInfo classInfo) {
  const mapAutoDefault = {
    'DateTime': 'DateTime.now()',
    'Widget': 'const SizedBox()',
    'bool': 'false'
  };

  final buffer = StringBuffer();
  final hasNonFinal = classInfo.fields.any((f) => !f.isFinal);
  final constKeyword = hasNonFinal ? '' : 'const ';

  buffer.writeln('class ${classInfo.name} with BaseCopyWith {');

  for (final field in classInfo.fields) {
    final finalKeyword = field.isFinal ? 'final ' : '';
    buffer.writeln('  $finalKeyword${field.type} ${field.name};');
  }
  buffer.writeln('');

  // constructor
  buffer.writeln('  $constKeyword${classInfo.name}({');

  for (final field in classInfo.fields) {
    final isNullable = field.type.endsWith('?');
    final pureType = field.type.replaceAll('?', '');
    final autoDefault = mapAutoDefault[pureType];

    if (isNullable) {
      buffer.writeln('    this.${field.name},');
    } else {
      if (autoDefault != null) {
        buffer.writeln('    $pureType? ${field.name},');
      } else {
        final dv = _defaultValueForType(pureType);
        buffer.writeln('    $pureType ${field.name} = $dv,');
      }
    }
  }

  buffer.writeln('  })');

  // initializer list
  final initList = <String>[];

  for (final field in classInfo.fields) {
    final isNullable = field.type.endsWith('?');
    final pureType = field.type.replaceAll('?', '');
    final autoDefault = mapAutoDefault[pureType];

    if (!isNullable && autoDefault != null) {
      initList.add('${field.name} = ${field.name} ?? $autoDefault');
    }
  }

  if (initList.isNotEmpty) {
    buffer.write(' : ${initList.join(',\n   ')}');
  }

  buffer.writeln(';');
  buffer.writeln('');

  // CopyWith
  buffer.writeln('  ${classInfo.name} copyWith({');
  for (final field in classInfo.fields) {
    buffer.writeln('    Object? ${field.name} = BaseCopyWith._undefined,');
  }
  buffer.writeln('  }) {');
  buffer.writeln('    return ${classInfo.name}(');
  for (final field in classInfo.fields) {
    buffer.writeln('      ${field.name}: isUndefined(${field.name})'
        ' ? this.${field.name}'
        ' : ${field.name} as ${field.type},');
  }
  buffer.writeln('    );');
  buffer.writeln('  }');

  buffer.write('}');
  return buffer.toString();
}


String _defaultValueForType(String type) {
  if (type.endsWith('?')) return 'null';

  if (type == 'int') return '0';
  if (type == 'double') return '0.0';
  if (type == 'bool') return 'false';
  if (type == 'String') return "''";

  if (type.startsWith('List<')) return 'const []';
  if (type.startsWith('Map<')) return 'const {}';
  if (type.startsWith('Set<')) return 'const {}';

  // Nếu là class object → default là null (vì không biết khởi tạo)
  return 'null';
}

String _getBaseCopyWithMixin() => '''
mixin BaseCopyWith {
  static const _undefined = Object();
  bool isUndefined(Object? value) => identical(value, _undefined);
}
''';

class ClassInfo {
  final String name;
  final List<FieldInfo> fields;
  final int startIndex;
  final int endIndex;
  ClassInfo({required this.name, required this.fields, required this.startIndex, required this.endIndex});
}

class FieldInfo {
  final String type;
  final String name;
  final bool isFinal;
  FieldInfo({required this.type, required this.name, required this.isFinal});
}