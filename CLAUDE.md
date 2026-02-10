# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

newspack-docker is a Docker-based local development environment for Newspack WordPress plugins and themes. It provides containerized PHP/Apache/MySQL with all dependencies needed to develop, build, and test Newspack projects.

**This repository serves as a monorepo-like workspace** where all Newspack plugins and themes are cloned into the `repos/` directory. Agents can make changes across multiple plugins from this single location.

## Working Across Multiple Repositories

### Repository Locations

All Newspack repositories are cloned to `./repos/<project-name>/`. Each is an independent Git repository hosted at `github.com/Automattic/<project-name>`.

### Newspack Ecosystem

The Newspack product consists of these interconnected plugins and themes:

**Core Plugin:**
- `newspack-plugin` - The main Newspack plugin. Provides the setup wizard, reader management, donations, data events API, and integrations with other plugins. Most other plugins depend on utilities from this plugin.

**Content & Publishing:**
- `newspack-blocks` - Custom Gutenberg blocks for news sites (Homepage Posts, Carousel, Author List, etc.)
- `newspack-listings` - Directory and listing functionality for events, places, and marketplaces
- `newspack-sponsors` - Sponsored content management and labeling

**Reader Revenue:**
- `newspack-popups` - Campaigns/prompts system for reader engagement (popups, inline prompts, overlays)

**Newsletters:**
- `newspack-newsletters` - Newsletter authoring and sending via ESP integrations (Mailchimp, ActiveCampaign, Constant Contact, etc.)

**Advertising:**
- `newspack-ads` - Google Ad Manager integration and ad placement management
- `super-cool-ad-inserter-plugin` - Programmatic ad insertion into content

**Multi-site & Network:**
- `newspack-network` - Synchronization system for multi-site Newspack networks (Hub/Node architecture)
- `newspack-multibranded-site` - Support for multiple brands within a single WordPress site

**Manager (SaaS):**
- `newspack-manager` - Server-side component for Newspack-as-a-service
- `newspack-manager-client` - Client plugin that connects sites to Newspack Manager

**Syndication:**
- `republication-tracker-tool` - Tracks content republication across sites

**Themes:**
- `newspack-theme` - Primary Newspack theme and base for additional style variations
- `newspack-joseph` - Newspack theme variation built on top of `newspack-theme`
- `newspack-katharine` - Newspack theme variation built on top of `newspack-theme`
- `newspack-nelson` - Newspack theme variation built on top of `newspack-theme`
- `newspack-sacha` - Newspack theme variation built on top of `newspack-theme`
- `newspack-scott` - Newspack theme variation built on top of `newspack-theme`

### Plugin Relationships

Understanding how plugins interact is crucial for cross-repo changes:

- **newspack-plugin** is the foundation. It provides:
  - Data Events API (used by newspack-network, newspack-newsletters)
  - Reader data management (used by newspack-popups, newspack-newsletters)
  - Webhooks system (used by newspack-network)
  - Configuration managers for other plugins

- **newspack-popups** uses reader data from newspack-plugin to target campaigns

- **newspack-newsletters** integrates with newspack-popups for subscription prompts

- **newspack-network** uses the Data Events API from newspack-plugin to sync data across sites

- **newspack-blocks** is used across all Newspack sites for content presentation

### Common Patterns Across Repos

**File Structure:**
```
<plugin-name>/
├── <plugin-name>.php      # Main plugin file with header and bootstrap
├── includes/              # PHP classes
│   ├── class-<name>.php   # Main plugin class
│   └── class-*.php        # Feature classes
├── src/                   # JavaScript/React source
├── dist/ or build/        # Compiled assets (gitignored)
├── composer.json          # PHP dependencies
├── package.json           # JS dependencies
└── phpunit.xml            # Test configuration
```

**Naming Conventions:**
- PHP classes: `class-newspack-<feature>.php` with `Newspack_<Feature>` class name
- Hooks: `newspack_<plugin>_<action>` for actions, same for filters
- Options: `newspack_<plugin>_<option_name>`

**Coding Standards:**
- WordPress Coding Standards + VIP Go standards
- Pre-commit hooks via composer (run `composer install` in each repo)
- ESLint + Prettier for JavaScript
- Stylelint for CSS/SCSS

## Key Commands

All commands use the `n` script from the repository root.

### Container Management
```bash
n start           # Start containers (PHP 8.3)
n start 8.2       # Start with PHP 8.2
n stop            # Stop containers
n restart         # Stop and start
```

### First-Time Setup
```bash
cp default.env .env           # Create local config
./build-image.sh              # Build Docker image (PHP 8.3)
./build-image-82.sh           # Build PHP 8.2 image
./clone-repos.sh              # Clone all Newspack repos to ./repos/
n start                       # Launch containers
n install                     # Install WordPress
n ci-build all                # Build all projects
```

### Building Projects
```bash
n build                       # Build current project (from within repo folder)
n build newspack-plugin       # Build specific project
n build newsletters           # 'newspack-' prefix can be omitted
n ci-build                    # npm ci + build for current project
n ci-build all                # Build all projects
```

### Testing
```bash
n test-php                    # Run PHPUnit tests (from within repo folder)
n test-php -- --filter=test_name  # Run specific test
n test-js                     # Run JS tests
```

**Note:** `n` commands require a TTY. In non-interactive contexts (CI, agents), run tests directly via Docker:
```bash
docker exec newspack_dev bash -c "cd /newspack-repos/newspack-plugin && ./vendor/bin/phpunit"
docker exec newspack_dev bash -c "cd /newspack-repos/newspack-plugin && ./vendor/bin/phpunit --filter=test_name"
```

### Development
```bash
n watch                       # Watch mode for current project
n composer <cmd>              # Run composer in current project
n npm <cmd>                   # Run npm in current project
```

### WordPress CLI
```bash
n wp <command>                # Run WP-CLI command
n shell                       # WP-CLI interactive shell
n db                          # MySQL interactive shell
n sh                          # Container bash (as apache user)
n rsh                         # Container bash (as root)
```

### Multi-Site
```bash
n sites-add <name>            # Create additional site at name.local
n sites-list                  # List additional sites
n sites-drop <name>           # Remove site
```

### Working Across Repos
```bash
n pull                        # Git pull all repos
n branch <name>               # Switch all repos to branch
n trunk                       # Switch all repos to trunk
n alpha                       # Switch all repos to alpha
n release                     # Switch all repos to release
```

## Architecture

### Directory Structure
- `repos/` - Cloned Newspack repositories (plugins + themes), mounted at `/newspack-repos/` in container
- `html/` - Main WordPress site, mounted at `/var/www/html`
- `additional-sites-html/` - Additional WordPress sites
- `manager-html/` - Newspack Manager site
- `bin/` - Shell scripts mounted at `/var/scripts/` in container
- `config/` - Apache, PHP, MySQL configuration

### Docker Services
- `wordpress` (container: `newspack_dev`) - Apache + PHP + WordPress
- `db` - MariaDB 10.8.2
- `mailhog` - Email capture at http://localhost:8025
- `adminer` - Database UI at http://localhost:8088

### Context-Aware Commands
The `n` script detects your current working directory:
- From `repos/<project>/` - commands target that project
- From `additional-sites-html/<site>/` - commands target that site
- From `manager-html/` - commands target the manager site
- Otherwise - commands target the main site

Use `ncd <name>` (install with `n cd-install`) for quick navigation between projects.

### Caching
- Memcached enabled via `html/wp-content/object-cache.php`
- Batcache for page caching via `advanced-cache.php`

### X-Debug
Configured on port 9003 with IDE key `DOCKERDEBUG`. Path mapping: `/newspack-repos/<project>` maps to local `repos/<project>`.

## Agent Workflow for Cross-Repository Changes

When making changes that span multiple plugins:

### 1. Understand the Change Scope
Before making changes, identify which repos are affected:
- Check for hooks/filters that connect plugins (grep for `do_action`, `apply_filters`, `add_action`, `add_filter`)
- Look for direct function calls between plugins
- Check if changing an API that other plugins consume

### 2. Make Changes in Dependency Order
If Plugin A depends on Plugin B:
1. Make changes to Plugin B first
2. Build Plugin B: `n build <plugin-b>`
3. Test Plugin B in isolation
4. Make changes to Plugin A
5. Build and test Plugin A

### 3. Testing Cross-Plugin Changes
```bash
# Rebuild affected plugins
n build newspack-plugin
n build newspack-popups

# Run PHP tests for each
cd repos/newspack-plugin && n test-php
cd repos/newspack-popups && n test-php
```

### 4. Git Workflow for Multi-Repo Changes
Each repo in `repos/` is independent. For related changes:
1. Create branches with the same name across repos for easier tracking
2. Commit to each repo separately
3. Reference related PRs in commit messages/PR descriptions

Example:
```bash
# In each affected repo
cd repos/newspack-plugin
git checkout -b feature/my-feature
# ... make changes, commit ...

cd repos/newspack-newsletters
git checkout -b feature/my-feature
# ... make changes, commit ...
```

### 5. Finding Code Across Repos
```bash
# Search all repos for a hook
grep -r "newspack_reader_logged_in" repos/

# Find where a function is defined
grep -rn "function get_reader_data" repos/

# Find all usages of a class
grep -rn "Newspack_Popups" repos/
```

## Common Integration Points

### Data Events API (newspack-plugin)
Used for async event processing:
```php
// Registering an event handler
Newspack\Data_Events::register_handler('reader_logged_in', 'my_handler');

// Dispatching an event
Newspack\Data_Events::dispatch('reader_logged_in', $data);
```

### Reader Data (newspack-plugin)
Central reader/user management:
```php
// Get current reader
$reader = Newspack\Reader_Activation::get_current_reader();

// Check reader status
Newspack\Reader_Activation::is_reader_logged_in();
```

### Webhooks (newspack-plugin)
For external integrations:
```php
Newspack\Webhooks::send('endpoint_id', $payload);
```

### Configuration Managers
newspack-plugin provides configuration managers for other plugins:
- `Newspack_Popups_Configuration_Manager`
- `Newspack_Ads_Configuration_Manager`
- `Newspack_Theme_Configuration_Manager`

## GitHub Information

All repositories are under the Automattic GitHub organization:
- URL pattern: `https://github.com/Automattic/<repo-name>`
- Default branch: `trunk` (some older repos may use `master`)
- PR target: Usually `trunk` branch

### Contributing Guidelines
- Follow WordPress Coding Standards + VIP Go standards
- Run `composer install` in a repo to set up pre-commit hooks
- Reference issue numbers in commits
- Don't modify changelog or .pot files (maintained by Newspack team)
