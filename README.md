## Setup core

📦 Setup Core
Using Generic Configuration (.env)

To keep the core package flexible and reusable across multiple projects (including monorepos), the core_base_bloc package does not contain hard-coded paths.
Instead, each project must provide its own configuration via a .env file placed at the same directory level as the core_base_bloc package.

This allows different projects to have different folder structures while reusing the same core logic.

📁 Folder Structure Example

Your project should have this structure:

project_root/

├── .env                     ← project-level configuration (NOT inside core)

├── core_base_bloc/          ← shared core package (do not modify)

└── app/ or lib/             ← your main application


The .env file must sit next to the core_base_bloc folder — not inside it.

📝 Create .env File

Add a .env file with the following keys:

PATH_VIEW=
PATH_ROUTER=
PATH_DI=
PACKAGE_IMPORT=


Below is the template for a standard Flutter project:

PATH_VIEW=lib/view
PATH_ROUTER=lib/core/router/app_router.dart
PATH_DI=lib/core/di/di.dart
PACKAGE_IMPORT=core_base_bloc

🔍 Field Descriptions
Key	Description
PATH_VIEW	Base directory where generated module folders will be created.
PATH_ROUTER	Path to your global router file where routes should be automatically injected.
PATH_DI	Path to your Dependency Injection setup file (GetIt).
PACKAGE_IMPORT	The import prefix used for core package references (usually the package name).# CoreBaseBloc
