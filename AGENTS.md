# Ebarge - AI Agent Instructions

## Project Overview

Ebarge is an educational gamification application built with Flutter.

The application provides:

- Digital educational textbooks
- Interactive learning content
- Azbazi educational quiz-games
- AI-assisted question generation
- User accounts
- Educational progress tracking
- Rankings
- Virtual currencies
- Zafran economy
- CafeBazaar in-app purchases
- Notes and annotations
- Educational content management

The main mobile application is implemented using Flutter and Dart.

---

# Technology Stack

## Main Application

- Flutter
- Dart
- Android
- iOS
- Windows
- Web
- SQLite/local database

## Backend / API

The application communicates with the Ebarge backend through HTTP APIs.

## Payment

CafeBazaar / Poolakey integration is used for in-app purchases.

## Mathematics / Formula Rendering

KaTeX assets are included for rendering mathematical expressions.

---

# Repository Structure

Important directories:

- `lib/azbazi/`
  - Azbazi game engine and gameplay logic

- `lib/database/`
  - Local database and SQL queries

- `lib/models/`
  - Application data models

- `lib/providers/`
  - State management and data providers

- `lib/screens/`
  - Main application screens

- `lib/services/`
  - Application services and external integrations

- `lib/widgets/`
  - Reusable UI components

- `assets/`
  - Images, fonts, KaTeX and application assets

- `flutter_poolakey/`
  - Local Poolakey Flutter plugin

- `image_painter/`
  - Local image annotation package

- `fieldssettings/`
  - Local settings UI package

- `cupertino_settings/`
  - Local settings UI package

- `docs/`
  - Project documentation

---

# Important Rules

## 1. Understand Before Modifying

Before changing code:

1. Inspect the relevant files.
2. Understand existing architecture.
3. Identify dependencies.
4. Identify database/API implications.
5. Explain the proposed change when the task is complex.

Do not rewrite large parts of the application without understanding the existing implementation.

---

## 2. Preserve Existing Functionality

Ebarge is an existing production-oriented application.

Do not remove or rewrite existing functionality unless explicitly requested.

Prefer:

- Small changes
- Incremental refactoring
- Backward-compatible changes
- Reusing existing components

---

## 3. Flutter Rules

Follow modern Flutter/Dart practices.

Before introducing a new dependency:

1. Check whether an existing package or implementation already solves the problem.
2. Check compatibility with the current Flutter version.
3. Avoid unnecessary dependencies.

Do not upgrade Flutter, Gradle, Android Gradle Plugin, Kotlin or major packages unless explicitly requested.

---

## 4. Database

Database changes are high-risk.

Before modifying:

- database schema
- SQL queries
- migrations
- models related to persistence

inspect all usages first.

Never delete existing data structures without an explicit migration strategy.

---

## 5. API

Before changing API-related code:

- inspect existing request structure
- inspect response models
- inspect authentication
- inspect error handling

Do not invent API endpoints.

---

## 6. UI

Preserve the existing Ebarge visual language unless redesign is explicitly requested.

Pay attention to:

- Persian RTL layout
- Persian typography
- responsive layouts
- accessibility
- existing colors
- existing icons
- existing assets

---

## 7. AI Features

AI-generated educational content must be treated as potentially unreliable.

AI-generated questions must be validated before becoming trusted educational content.

Do not silently change AI prompts or question-generation logic without documenting the effect.

---

## 8. Git

The repository uses:

- `main` = stable/production branch
- `develop` = development branch

Never directly modify `main` for normal development.

Normal workflow:

feature branch
→ develop
→ testing
→ main

Use descriptive commit messages.

---

## 9. Security

Never:

- hard-code API keys
- hard-code passwords
- commit secrets
- expose private credentials
- modify `.gitignore` to allow secret files

Never commit:

- `.env`
- private keys
- signing credentials
- production secrets
- local machine configuration containing credentials

---

## 10. Before Finishing a Task

After making changes:

1. Run formatting if appropriate.
2. Run static analysis.
3. Run relevant tests.
4. Inspect `git diff`.
5. Report exactly what changed.
6. Report any remaining warnings/errors.

Do not claim a task is complete if validation has not been performed.

---

# Agent Behavior

When uncertain:

- inspect the repository first
- do not guess
- ask for clarification when necessary
- prefer minimal safe changes

When a task is large:

1. Analyze
2. Create a plan
3. Implement incrementally
4. Validate
5. Summarize changes

Never perform destructive operations without explicit confirmation.