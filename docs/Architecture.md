# 🏗️ Architecture — SNXW Finance

## 🎯 Overview

SNXW Finance is built using **Clean Architecture** principles to ensure:

- Scalability
- Testability
- Maintainability
- Separation of concerns

The goal is to keep business logic independent from frameworks like Flutter, databases or external tools.

---

# 🧠 Architectural Style

We use:

> Clean Architecture + Feature-first modular structure

---

# 📦 High-Level Layers

## 1. Presentation Layer (UI)

Responsible for everything related to Flutter UI.

Includes:

- Screens
- Widgets
- State management (Riverpod)
- UI controllers

📌 Rules:
- No business logic here
- Only UI + state rendering

---

## 2. Application Layer (Use Cases)

This layer contains the **business actions**.

Examples:

- Add income
- Add expense
- Calculate balance
- Evaluate debt risk

📌 Rules:
- Pure Dart
- No UI
- No database code

---

## 3. Domain Layer (Core Business)

The heart of the system.

Includes:

- Entities (Income, Expense, Debt)
- Repository interfaces
- Business rules

📌 Rules:
- 100% independent from Flutter
- No external dependencies

---

## 4. Data Layer

Responsible for data handling.

Includes:

- SQLite (Drift)
- Local storage
- Repository implementations
- DTOs / Mappers

📌 Rules:
- Implements domain repositories
- Handles persistence only

---

# 🧱 Feature-First Structure

Instead of separating by type, we organize by feature:

```
lib/
 ├── features/
 │    ├── dashboard/
 │    ├── income/
 │    ├── expenses/
 │    ├── debts/
 │
 ├── core/
 ├── shared/
```

---

# 🔄 Data Flow

```
UI (Flutter)
   ↓
Riverpod State
   ↓
Use Cases (Application Layer)
   ↓
Repositories (Domain Interface)
   ↓
Data Sources (SQLite / Drift)
```

---

# 🧠 State Management

We use **Riverpod** because:

- Scalable
- Testable
- Works well with Clean Architecture
- No tight coupling with UI

---

# 🗄️ Database Strategy

We use:

- SQLite (local-first)
- Drift (type-safe abstraction)

📌 Reason:
- Offline-first design
- Full control of data
- No dependency on external APIs in MVP

---

# 📱 Platform Strategy

Flutter enables:

- Android
- iOS
- Windows
- Linux
- Web (future)

📌 MVP focus:
- Android + Desktop first

---

# 🧩 Core Design Principles

- 🔒 Offline First
- 🧱 Modular architecture
- ♻️ Reusable components
- 📉 Simplicity over complexity
- 🎯 Decision-oriented design (not just tracking)

---

# 🚫 Anti-Patterns to Avoid

- Business logic inside UI
- Direct database calls from widgets
- Massive monolithic files
- Overengineering MVP
- Tight coupling between layers

---

# 📌 Folder Mapping (Future Flutter App)

```
lib/
 ├── core/
 ├── features/
 │    ├── income/
 │    ├── expenses/
 │    ├── debts/
 │    ├── dashboard/
 │
 ├── shared/
 ├── main.dart
```

---

# 🧭 Architecture Goal

The architecture must allow us to:

- Add new financial features without breaking existing ones
- Replace database layer without touching UI
- Scale from MVP → full financial system
- Keep Copilot-generated code under control

---

# ⚡ Philosophy

> "Good architecture makes bad decisions reversible."

SNXW Finance is designed so we can iterate fast without accumulating technical debt.

---