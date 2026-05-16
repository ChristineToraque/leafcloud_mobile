# LoginApp Execution Flow

This document describes the line-by-line flow of exactly what happens once `LoginApp` is called by `runApp()` in `lib/main.dart`.

**1. `const LoginApp({super.key});` (The Constructor)**
First, Flutter creates an instance (an object) of the `LoginApp` class. Because it has the `const` keyword, Flutter optimizes it in memory.

**2. `@override Widget build(BuildContext context) {`**
Because `LoginApp` is a visual component (`StatelessWidget`), Flutter immediately and automatically calls this `build` method. This method's job is to answer the question: *"What should this app look like?"*

**3. `return MaterialApp(`**
The `build` method starts constructing the UI. It returns a `MaterialApp` widget. Think of `MaterialApp` as the "engine" or the "wrapper" for your entire app. It handles navigation, themes, and global settings.

**4. `title: 'LeafCloud Login',`**
Inside the `MaterialApp`, it sets the app's internal name. You usually see this title when you minimize the app and look at your phone's "Recent Apps" or "Task Switcher" screen.

**5. `theme: ThemeData(`**
It then sets up the global design rules (the theme) for the entire app. 

**6. `colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),`**
Inside the theme, it generates a complete color palette (light shades, dark shades, text colors) automatically, using standard Blue as the base/seed color.

**7. `useMaterial3: true,`**
Still inside the theme, this tells Flutter to use the newest version of Google's design system (Material Design 3), which gives buttons and inputs a more modern, rounded look.

**8. `home: const LoginPage(),`**
Finally, this is the most important part of the flow. The `home` property tells `MaterialApp`: *"When you are done setting up the colors and configurations, the very first screen you should show to the user is `LoginPage`."* 

**What happens next?**
Because of that last line, the flow leaves `LoginApp` and jumps directly into the `LoginPage` class, where it will start running its own `build` method to draw the actual text fields and the login button on your screen.
