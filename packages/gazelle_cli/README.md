# Gazelle CLI

Gazelle CLI is a command-line tool to help you scaffold, manage and deploy
applications created with [Gazelle](https://docs.gazelle-dart.dev/).

## Warning
This tool is currently under heavy development, please report any bug or issue
with it.

## Installation
To install the CLI, just use:
```shell
dart pub global activate gazelle_cli
```

## Available commands
```
Gazelle CLI for Gazelle framework.

Usage: gazelle <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  create      Creates a Gazelle project.
  dockerize   Generates Dockerfile for current project.

Run "gazelle help <command>" for more information about a command.
```

### Dockerize
```
Generates Dockerfile for current project.

Usage: gazelle dockerize [arguments]
-h, --help    Print this usage information.
-p, --port    Specifies exposed port in Dockerfile.
              (defaults to "3000")

Run "gazelle help" to see global options.
```

### Create
```
Creates a Gazelle project.

Usage: gazelle create [arguments]
-h, --help    Print this usage information.
-n, --name    The name of the project you want to build.
-p, --path    The path where you want to build the project.

Run "gazelle help" to see global options.
```
