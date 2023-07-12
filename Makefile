# Marker indicating this is a root build
ROOT_BUILD := true

include makefile.base

# Build a list of Makefiles, used to create virtual environments
VENV_MAKEFILES := $(shell find . $(FIND_PATH_FILTER) -name "Makefile" | grep -v "\./Makefile")

# Build a list of directories where Python test exist only going down two levels when building the
# directory list based on our repository layout.
# Directories that implement test but do not have python tests can add a .test file to be included.
DIRS_WITH_TESTS := $(shell find . $(FIND_PATH_FILTER) -name "test_*.py" -or -name ".test" | grep -Po "^./\K.+?/[^/]*" | sort -u)

#VSCode Workspace Generation script
GEN_VSCODE_WORKSPACES := $(SCRIPTS_DIR)/gen-workspaces.sh

# Run tests in the target directory
$(DIRS_WITH_TESTS): FORCE
	@echo "# Testing:  $@"
	@echo
	@$(MAKE) -C $@ test

# Run tests for all packages and components
.PHONY: test
test: root-venv .WAIT $(DIRS_WITH_TESTS)

# Create virtual environments in all directories with Makefiles
$(VENV_MAKEFILES): FORCE
	@echo "Making venv in $(shell dirname $@)"
	@$(MAKE) --no-print-directory -C $(shell dirname $@) venv
	@echo

# Create all virtual environments
.PHONY: venv-all
venv-all: root-venv .WAIT $(VENV_MAKEFILES)

# Configure VSCode multi-root workspaces
.PHONY: vscode-config
vscode-config: FORCE
	$(GEN_VSCODE_WORKSPACES)
