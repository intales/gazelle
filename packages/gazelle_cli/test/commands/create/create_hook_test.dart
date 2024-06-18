import 'dart:io';

import 'package:gazelle_cli/commands/create/create_hook.dart';
import 'package:test/test.dart';

void main() {
  group('CreateHook tests', () {
    test('Should create a pre-request hook', () async {
      // Arrange
      final tmpDirPath = "tmp/create_pre_request_hook_test";
      Directory tmpDir = Directory(tmpDirPath);
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
      tmpDir = await Directory(tmpDirPath).create(recursive: true);

      // Act
      final result = await createHook(
        hookName: "authentication",
        hookType: CreateHookType.preRequest,
        path: tmpDirPath,
      );

      // Assert
      expect(File(result.hookFilePath).existsSync(), isTrue);
      expect(result.hookName, "authenticationPreRequestHook");

      // Clean up
      await tmpDir.delete(recursive: true);
    });

    test('Should create a post-response hook', () async {
      // Arrange
      final tmpDirPath = "tmp/create_post_response_hook_test";
      Directory tmpDir = Directory(tmpDirPath);
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
      tmpDir = await Directory(tmpDirPath).create(recursive: true);

      // Act
      final result = await createHook(
        hookName: "custom_header",
        hookType: CreateHookType.postResponse,
        path: tmpDirPath,
      );

      // Assert
      expect(File(result.hookFilePath).existsSync(), isTrue);
      expect(result.hookName, "customHeaderPostResponseHook");

      // Clean up
      await tmpDir.delete(recursive: true);
    });
  });
}
