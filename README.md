# VSCode Sample Project

This sample multi-root workspace can be used to reproduce Python test discovery errors
for <https://github.com/microsoft/vscode-python/issues/21599>

## Prerequisites

-  GNU `grep` with support for Posix regex `-P` option (`brew install grep` on MacOS)
-  `pyenv` or Python 3.9
-  `make`

## Command Line

```
# Create all virtual environments
make venv-all

# Run all tests
make test

# Operate on a single project (works in any groupN/groupN_projectX directory)
cd group1/group1_p10
# Install/update the local virtual environment
make venv
# Run tests
make test
```

## VSCode

- Ensure configuration includes `"python.experiments.optInto": ["pythonTestAdapter"]`
- Open the `root` workspace file to ensure tests get configured correctly.
- Ensure all virtual environments have been created so VSCode can scan for tests (`make venv-all`)
- Open the Test Explorer

On Windows VSCode with a Remote SSH to a Linux Workstation, test discovery generates error messages in the Python log similar to:

```
2023-07-10 14:31:48.395 [info] Using result resolver for discovery
2023-07-10 14:31:48.395 [info] Using result resolver for discovery
2023-07-10 14:31:48.395 [info] Using result resolver for discovery
2023-07-10 14:31:48.438 [error] On data received: Error occurred because the payload UUID is not recognized
2023-07-10 14:31:48.438 [error] On data received: Error occurred because the payload UUID is not recognized
2023-07-10 14:31:48.438 [error] On data received: Error occurred because the payload UUID is not recognized
2023-07-10 14:31:48.680 [info] Test server connected to a client.
2023-07-10 14:31:48.686 [info] Test server connected to a client.
2023-07-10 14:31:48.686 [info] Test server connected to a client.
```

On MacOS, the error messages were not observed.

On both operating systems, only one project's tests appeared in the explorer after discovery. Refreshing sometimes shows a different project's tests. Prior to the Python extension updates in `v2023.12.0` (VSCode `1.80.0`), tests from all projects in the workspace would be discovered.
