REPO_URL := https://github.com/beatrix2699/pmm-shared-plugins
CLONE_DIR := $(HOME)/.codex/pmm-shared-plugins
SKILLS_DIR := $(HOME)/.agents/skills
LINK := $(SKILLS_DIR)/pmm-shared-plugins

.PHONY: install-codex upgrade

install-codex:
	@if [ -d "$(CLONE_DIR)" ]; then \
		echo "Already cloned — pulling latest..."; \
		git -C "$(CLONE_DIR)" pull --ff-only; \
	else \
		git clone $(REPO_URL) $(CLONE_DIR) --depth 1; \
	fi
	@mkdir -p $(SKILLS_DIR)
	@if [ ! -L "$(LINK)" ]; then \
		ln -s $(CLONE_DIR) $(LINK); \
		echo "Symlink created: $(LINK)"; \
	else \
		echo "Symlink already exists: $(LINK)"; \
	fi

upgrade:
	@if [ ! -d "$(CLONE_DIR)" ]; then \
		echo "Plugin not installed. Run 'make install-codex' first."; \
		exit 1; \
	fi
	@echo "Upgrading pmm-shared-plugins..."
	@git -C "$(CLONE_DIR)" fetch --depth 1 origin
	@git -C "$(CLONE_DIR)" reset --hard origin/HEAD
	@echo "Done. Now at $$(git -C $(CLONE_DIR) rev-parse --short HEAD)."
