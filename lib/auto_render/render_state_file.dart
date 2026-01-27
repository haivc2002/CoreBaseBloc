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

        // Kiểm tra xem class đã có generated code chưa
        final existingGenerated = _parseExistingGeneratedClass(lines, i);

        bodyResult.add(_generateClassWithCopyWith(
          parseResult.classInfo!,
          existingGenerated: existingGenerated,
        ));
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

// Parse existing generated class để lấy thông tin field đã có
ExistingGeneratedClass? _parseExistingGeneratedClass(List<String> lines, int startIndex) {
  final className = _extractClassName(lines[startIndex]);
  if (className == null) return null;

  var i = startIndex + 1;
  var braceCount = lines[startIndex].contains('{') ? 1 : 0;
  final existingFields = <String, ExistingFieldInfo>{};
  var constructorStartIndex = -1;

  // Bước 1: Parse field declarations
  while (i < lines.length && braceCount > 0) {
    final rawLine = lines[i];
    final trimmed = rawLine.trim();

    braceCount += '{'.allMatches(trimmed).length;
    braceCount -= '}'.allMatches(trimmed).length;

    // Phát hiện constructor
    if (trimmed.contains('$className(')) {
      constructorStartIndex = i;
      break;
    }

    // Parse field declarations (chỉ trước constructor)
    if (_isFieldDeclaration(trimmed)) {
      final fieldResult = _parseField(trimmed, i + 1);
      if (!fieldResult.hasError && fieldResult.fieldInfo != null) {
        final field = fieldResult.fieldInfo!;
        existingFields[field.name] = ExistingFieldInfo(
          type: field.type,
          name: field.name,
          isFinal: field.isFinal,
          defaultValue: null,
        );
      }
    }

    if (braceCount == 0) break;
    i++;
  }

  if (constructorStartIndex == -1 || existingFields.isEmpty) {
    return null;
  }

  // Bước 2: Parse initializer list
  i = constructorStartIndex;
  // Tìm dấu ')' đóng của constructor parameters
  while (i < lines.length && !lines[i].contains(')')) {
    i++;
  }

  // Kiểm tra có dấu ':' (initializer list) không
  var foundColon = false;
  var colonLineIndex = i;
  while (colonLineIndex < lines.length && !lines[colonLineIndex].contains(';')) {
    if (lines[colonLineIndex].contains(':')) {
      foundColon = true;
      break;
    }
    colonLineIndex++;
  }

  if (!foundColon) {
    return ExistingGeneratedClass(
      className: className,
      fields: existingFields,
    );
  }

  // Parse initializer list - ĐỌC TOÀN BỘ TEXT từ ':' đến ';'
  final initBuffer = StringBuffer();
  i = colonLineIndex;
  while (i < lines.length && !lines[i].contains(';')) {
    initBuffer.writeln(lines[i]);
    i++;
  }
  if (i < lines.length && lines[i].contains(';')) {
    initBuffer.write(lines[i]);
  }

  final fullInitText = initBuffer.toString();
  final colonIndex = fullInitText.indexOf(':');
  if (colonIndex == -1) {
    return ExistingGeneratedClass(
      className: className,
      fields: existingFields,
    );
  }

  // Lấy phần sau dấu ':'
  final afterColon = fullInitText.substring(colonIndex + 1);
  final semicolonIndex = afterColon.lastIndexOf(';');
  final initContent = semicolonIndex != -1
      ? afterColon.substring(0, semicolonIndex)
      : afterColon;

  // Parse từng initializer bằng cách đếm ngoặc
  final initializers = _parseInitializers(initContent);

  for (final init in initializers) {
    final equalsIndex = init.indexOf('=');
    if (equalsIndex == -1) continue;

    final fieldName = init.substring(0, equalsIndex).trim();
    final fullValue = init.substring(equalsIndex + 1).trim();

    // Parse "fieldName ?? defaultValue"
    final defaultValue = _extractDefaultValue(fullValue);

    if (existingFields.containsKey(fieldName) && defaultValue != null) {
      existingFields[fieldName] = ExistingFieldInfo(
        type: existingFields[fieldName]!.type,
        name: fieldName,
        isFinal: existingFields[fieldName]!.isFinal,
        defaultValue: defaultValue,
      );
    }
  }

  return ExistingGeneratedClass(
    className: className,
    fields: existingFields,
  );
}

// Parse initializers bằng cách tách theo dấu phẩy ở level ngoài cùng
List<String> _parseInitializers(String content) {
  final result = <String>[];
  final buffer = StringBuffer();
  var parenDepth = 0;
  var braceDepth = 0;
  var bracketDepth = 0;

  for (var i = 0; i < content.length; i++) {
    final char = content[i];

    if (char == '(') parenDepth++;
    else if (char == ')') parenDepth--;
    else if (char == '{') braceDepth++;
    else if (char == '}') braceDepth--;
    else if (char == '[') bracketDepth++;
    else if (char == ']') bracketDepth--;
    else if (char == ',' && parenDepth == 0 && braceDepth == 0 && bracketDepth == 0) {
      // Đây là dấu phẩy ở level ngoài cùng
      final init = buffer.toString().trim();
      if (init.isNotEmpty) {
        result.add(init);
      }
      buffer.clear();
      continue;
    }

    buffer.write(char);
  }

  // Thêm phần cuối cùng
  final lastInit = buffer.toString().trim();
  if (lastInit.isNotEmpty) {
    result.add(lastInit);
  }

  return result;
}

// Extract default value từ "fieldName ?? defaultValue"
String? _extractDefaultValue(String value) {
  final nullCoalesceIndex = value.indexOf('??');
  if (nullCoalesceIndex == -1) return null;

  return value.substring(nullCoalesceIndex + 2).trim();
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
  final scriptPath = Platform.script.toFilePath();
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
///   • Existing fields retain their custom default values.
///   • New fields get default values based on their type.
///   • If all fields are `final`, the constructor remains `const`.
///   • Manual edits to `copyWith` method may be overwritten.
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

bool _isConstDefault(String type) {
  if (type == 'int' || type == 'double' || type == 'bool' || type == 'String') {
    return true;
  }
  if (type.startsWith('List<') || type.startsWith('Map<') || type.startsWith('Set<')) {
    return true;
  }
  if (type == 'Widget') return true;
  return false;
}

bool _isFieldDeclaration(String line) {
  return (line.startsWith('final ') || !line.startsWith(RegExp(r'(final|\w+\s*\()'))) &&
      line.contains(';') &&
      !line.contains('(') &&
      !line.contains(')') &&
      !line.contains('=') &&
      !line.contains('{') &&
      !line.contains('}');
}

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
  final pattern = RegExp(r'^(final\s+)?(.+?)\s+(\w+)\s*;$');
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

String _generateClassWithCopyWith(
    ClassInfo classInfo, {
      ExistingGeneratedClass? existingGenerated,
    }) {
  final buffer = StringBuffer();

  bool allFinal = classInfo.fields.every((f) => f.isFinal);
  bool allConstDefault = classInfo.fields.every((f) {
    final type = f.type.replaceAll('?', '');
    return _isConstDefault(type);
  });
  final constKeyword = (allFinal && allConstDefault) ? 'const ' : '';

  buffer.writeln('class ${classInfo.name} with BaseCopyWith {');

  // Generate fields
  for (final field in classInfo.fields) {
    final finalKeyword = field.isFinal ? 'final ' : '';
    buffer.writeln('  $finalKeyword${field.type} ${field.name};');
  }
  buffer.writeln('');

  // Generate constructor
  buffer.writeln('  $constKeyword${classInfo.name}({');
  for (final field in classInfo.fields) {
    final pureType = field.type.replaceAll('?', '');
    buffer.writeln('    $pureType? ${field.name},');
  }
  buffer.writeln('  })');

  // Generate initializer list - GIỮ GIÁ TRỊ CŨ hoặc dùng default
  final initList = <String>[];
  for (final field in classInfo.fields) {
    final pureType = field.type.replaceAll('?', '');

    // Kiểm tra xem field này đã tồn tại với custom default value chưa
    String defaultValue;
    if (existingGenerated != null &&
        existingGenerated.fields.containsKey(field.name) &&
        existingGenerated.fields[field.name]!.defaultValue != null) {
      // GIỮ NGUYÊN giá trị default cũ
      defaultValue = existingGenerated.fields[field.name]!.defaultValue!;
    } else {
      // Field mới -> dùng default value theo type
      defaultValue = _defaultValueForType(pureType);
    }

    initList.add('${field.name} = ${field.name} ?? $defaultValue');
  }

  if (initList.isNotEmpty) {
    buffer.write(' : ${initList.join(',\n        ')}');
  }
  buffer.writeln(';');
  buffer.writeln('');

  // Generate copyWith method
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
  if (type == 'int') return '0';
  if (type == 'double') return '0.0';
  if (type == 'bool') return 'false';
  if (type == 'String') return "''";

  if (type.startsWith('List<')) return 'const []';
  if (type.startsWith('Map<')) return 'const {}';
  if (type.startsWith('Set<')) return 'const {}';

  if (type == 'DateTime') return 'DateTime.now()';
  if (type == 'Widget') return 'const SizedBox()';

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

  ClassInfo({
    required this.name,
    required this.fields,
    required this.startIndex,
    required this.endIndex,
  });
}

class FieldInfo {
  final String type;
  final String name;
  final bool isFinal;

  FieldInfo({
    required this.type,
    required this.name,
    required this.isFinal,
  });
}

class ExistingFieldInfo {
  final String type;
  final String name;
  final bool isFinal;
  final String? defaultValue;

  ExistingFieldInfo({
    required this.type,
    required this.name,
    required this.isFinal,
    this.defaultValue,
  });
}

class ExistingGeneratedClass {
  final String className;
  final Map<String, ExistingFieldInfo> fields;

  ExistingGeneratedClass({
    required this.className,
    required this.fields,
  });
}