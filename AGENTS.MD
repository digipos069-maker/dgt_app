You are working on a Flutter app project. Please follow these project rules strictly.

Main goal:
Build the app with a clean, maintainable, scalable, and professional structure.

Project Structure Rules:
- Use a clear folder structure.
- Separate UI, business logic, data, models, services, and reusable components.
- Do not put all code inside one file.
- Do not create random folders. Follow a professional Flutter architecture.
- Keep each file focused on one responsibility.

Recommended structure:

lib/
├── core/
│   ├── constants/
│   ├── themes/
│   ├── utils/
│   ├── widgets/
│   └── services/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   └── home/
│       ├── data/
│       ├── models/
│       ├── providers/
│       ├── screens/
│       └── widgets/
├── app.dart
└── main.dart

Code Quality Rules:
- Write clean and readable Dart code.
- Use meaningful names for files, classes, variables, and functions.
- Keep widgets small and reusable.
- Avoid duplicate code.
- Avoid very large widget files.
- Move repeated UI parts into reusable components.
- Move repeated logic into helper functions or services.
- Use const widgets whenever possible.
- Follow Flutter best practices.

Reusable Component Rules:
- Create shared widgets for buttons, text fields, cards, loading indicators, dialogs, and common layouts.
- Place global reusable widgets inside core/widgets.
- Place feature-specific widgets inside the feature/widgets folder.
- Components should be flexible and configurable using parameters.
- Do not hard-code text, colors, spacing, or styles when they should be reusable.

Maintainability Rules:
- Make the code easy for another developer to understand.
- Add comments only when the logic is complex.
- Keep business logic separate from UI.
- Use proper error handling.
- Use loading, success, error, and empty states where needed.
- Do not break existing features when adding new ones.
- Before changing existing code, understand the current structure first.

Scalability Rules:
- Design the app so new features can be added easily.
- Use feature-based architecture.
- Keep dependencies organized.
- Use state management clearly and consistently.
- Avoid tightly coupled code.
- Use services or repositories for API and database logic.
- Use models for structured data.
- Keep API logic outside UI files.

UI Rules:
- Make the UI responsive for different screen sizes.
- Keep design consistent across screens.
- Use theme-based colors and text styles.
- Avoid inline styling when it should come from the app theme.
- Build reusable layout patterns.

Before Coding:
- First inspect the existing project structure.
- Explain where you will add or modify files.
- Follow the existing naming and architecture style if already available.

After Coding:
- Summarize what files were created or changed.
- Explain how to test the feature.
- Mention any assumptions or TODOs.
- Make sure the code is clean, scalable, and maintainable.