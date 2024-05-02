import 'dart:io';

const _dockerIgnore = """
.dockerignore
Dockerfile
build/
.dart_tool/
.git/
.github/
.gitignore
.packages
""";

/// Returns a string with Dockerfile commands.
///
/// Compiles given [mainFilePath] and exposes [exposedPort].
String generateDockerFileContent({
  required String mainFilePath,
  required int exposedPort,
}) =>
    """
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .

RUN dart pub get --offline
RUN dart compile exe $mainFilePath -o bin/server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

EXPOSE $exposedPort
CMD ["/app/bin/server"]
""";

/// Returns a file containing Docker ignore entries.
///
/// File is located at given [path].
Future<File> createDockerIgnore(String path) =>
    File(path).writeAsString(_dockerIgnore);

/// Returns a file containing Dockerfile commands.
///
/// File is located at given [path], compiles given [mainFilePath] and
/// exposes [exposedPort].
Future<File> createDockerFile({
  required String path,
  required String mainFilePath,
  required int exposedPort,
}) =>
    File(path).writeAsString(generateDockerFileContent(
      mainFilePath: mainFilePath,
      exposedPort: exposedPort,
    ));

/// Creates needed Docker files for depolyment.
///
/// Both files are created under [path], Dockerfile
/// compiles [mainFilePath] and exposes [exposedPort].
Future<File> createDockerFiles({
  required String path,
  required String mainFilePath,
  required int exposedPort,
}) async {
  final dockerIgnorePath = "$path/.dockerignore";
  final dockerFilePath = "$path/Dockerfile";

  final files = await Future.wait([
    createDockerIgnore(dockerIgnorePath),
    createDockerFile(
      path: dockerFilePath,
      mainFilePath: mainFilePath,
      exposedPort: exposedPort,
    ),
  ]);

  return files.last;
}
