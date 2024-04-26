# Gazelle CLI

Gazelle CLI is a command-line tool to help you scaffold, manage and deploy
applications created with [Gazelle](https://docs.gazelle-dart.dev/).

## Warning
This tool is currently under heavy development, please report any bug or issue
with it.

## Available commands
```
Gazelle CLI for Gazelle framework.

Usage: gazelle <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
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
