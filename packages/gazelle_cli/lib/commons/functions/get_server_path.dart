import 'package:path/path.dart' as path;
import '../entities/project_configuration.dart';

/// Returns the server path of the current [projectConfiguration].
String getServerPath(final ProjectConfiguration projectConfiguration) =>
    path.join(projectConfiguration.path, "server");
