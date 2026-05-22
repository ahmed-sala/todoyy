# Todoyy 📝

A native **iOS To‑Do / task manager** app written in **Objective‑C** with UIKit and Storyboards. It lets you create, edit, prioritize, search, and get reminders for your tasks, with a simple workflow that moves a task from *Todo → In Progress → Done*.

> Project author: **Ahmed Salah** · Bundle ID: `com.example.Project-todo`

---

## ✨ Features

- **Create / Edit / Delete tasks** — full CRUD with confirmation dialogs for update and delete.
- **Task fields** — title, description, priority, status, creation date, and an optional reminder date.
- **Priorities** — Low, Medium, High (each shown with its own icon).
- **Status workflow** — `Todo`, `In Progress`, `Done`, with rules that constrain how a task can move between states (e.g. you can't jump straight to *Done* on a brand‑new task, and a *Done* task becomes read‑only).
- **Filtering** — a segmented control switches between **All**, **Todo**, **In Progress**, **Done**, and a **Priority** view that groups tasks into High / Medium / Low sections.
- **Search** — live search by title or description, working together with the active filter.
- **Local reminders** — schedules a local notification (via the `UserNotifications` framework) at the chosen reminder time.
- **Swipe to delete** — trailing swipe with a confirmation alert.
- **Empty state** — a friendly "No Tasks Yet" placeholder when a list is empty.
- **Polished UI** — custom‑styled search bar, segmented controls, rounded cards, and shadows.

---

## 🏗 Architecture

The app follows a lightweight **MVC** pattern with a singleton data manager.

```
View Controllers (UIKit)            Storyboard
        │                               │
        ▼                               ▼
┌──────────────────┐          ┌──────────────────────┐
│  ViewController   │  list    │   Main.storyboard    │
│  (task list)      │◄────────►│   LaunchScreen        │
└──────────────────┘          └──────────────────────┘
        │ presents
        ▼
┌──────────────────────┐
│ AddToDoViewController │  add / edit screen
└──────────────────────┘
        │ uses
        ▼
┌──────────────────┐      reads/writes      ┌──────────────────┐
│   TodoManager    │ ─────────────────────► │  NSUserDefaults  │
│  (singleton)     │                        │  (JSON-like dict)│
└──────────────────┘                        └──────────────────┘
        │ manages
        ▼
┌──────────────────┐
│    TodoItem      │  model object
└──────────────────┘
```

### Key components

| Component | Responsibility |
|-----------|----------------|
| **`TodoItem`** (`Model/`) | Plain `NSObject` model holding `uuid`, `title`, `todoDescription`, `date`, `reminderDate`, `priority`, `status`, `isReminder`. Defines the `TodoStatus` enum and `toDictionary` / `fromDictionary` serialization plus a `statusString` helper. |
| **`TodoManager`** (`Managers/`) | Singleton (`+sharedManager`) that handles all persistence. Provides `addTodo`, `getAllTodos`, `getTodosByStatus:`, `getTodoByUUID:`, `updateTodo:`, and `deleteTodoByUUID:`. Stores tasks as an array of dictionaries in **`NSUserDefaults`**. |
| **`ViewController`** | The main task list. Owns the `UITableView`, the filter `UISegmentedControl`, and the `UISearchBar`. Handles filtering, search, priority grouping, the empty state, and swipe‑to‑delete. Listens for the `"TodoUpdated"` notification to refresh. |
| **`AddToDoViewController`** | The add/edit screen. Validates input, applies the status workflow rules, requests notification permission, and schedules local reminders. Reused for both creating and editing (driven by whether its `item` property is set). |
| **`NewTableTableViewCell`** | The custom prototype cell (`NewCell`) used to render each task: image, title, description, date, priority, and status labels. |
| **`TodoTableViewCell`** | A secondary cell class (largely vestigial — the list renders with `NewTableTableViewCell`). |
| **`AppDelegate` / `SceneDelegate` / `main.m`** | Standard UIKit app lifecycle boilerplate. |

### Data flow

1. `AddToDoViewController` builds or updates a `TodoItem` and calls `TodoManager`.
2. `TodoManager` serializes items to dictionaries and persists them in `NSUserDefaults`.
3. After a change, a `"TodoUpdated"` `NSNotification` is posted.
4. `ViewController` observes that notification, reloads from `TodoManager`, and refreshes the table.

---

## 🛠 Tech Stack

- **Language:** Objective‑C
- **UI:** UIKit + Storyboards (`Main.storyboard`, `LaunchScreen.storyboard`)
- **Persistence:** `NSUserDefaults` (tasks stored as serialized dictionaries)
- **Notifications:** `UserNotifications` framework (local calendar‑based reminders)
- **Minimum iOS target:** 26.1
- **IDE:** Xcode

---

## 📂 Project Structure

```
Project todo/
├── main.m
├── AppDelegate.{h,m}
├── SceneDelegate.{h,m}
├── ViewController.{h,m}            # Main task list
├── AddToDoViewController.{h,m}     # Add / edit screen
├── NewTableTableViewCell.{h,m}     # Task list cell
├── TodoTableViewCell.{h,m}
├── Model/
│   └── TodoItem.{h,m}             # Task model + serialization
├── Managers/
│   └── TodoManager.{h,m}          # Singleton CRUD + persistence
├── Base.lproj/
│   ├── Main.storyboard
│   └── LaunchScreen.storyboard
├── Assets.xcassets/               # App icon, logo, priority icons
└── Info.plist

todo.xcdatamodeld/                 # Core Data model (present but unused)
Project todo.xcodeproj/
```

---

## 🚀 Getting Started

> **Requires macOS with Xcode.** This is an iOS app and must be built/run from Xcode on a Mac.

1. **Clone the repository**
   ```bash
   git clone https://github.com/ahmed-sala/todoyy.git
   cd todoyy
   ```
2. **Open the project**
   ```bash
   open "Project todo.xcodeproj"
   ```
3. **Select a simulator or device** in Xcode (iOS 26.1+).
4. **Build & run** with `⌘ + R`.
5. When prompted, **allow notifications** so task reminders can fire.

### Using the app

- Tap the **+** button to add a task.
- Fill in a title (required), description, priority, status, and an optional reminder time.
- Tap a task in the list to **edit** it; **swipe left** to delete.
- Use the **segmented control** to filter by status or view tasks grouped by priority.
- Use the **search bar** to find tasks by title or description.

---

## 📌 Notes & Observations

- **Persistence uses `NSUserDefaults`, not Core Data.** A Core Data model (`todo.xcdatamodeld`) exists in the project but is **not wired into the code** — all data goes through `TodoManager` → `NSUserDefaults`. It could be migrated to Core Data in the future.
- In `TodoItem.toDictionary`, the `reminderDate` value is currently serialized from `self.date` rather than `self.reminderDate` — worth noting if you build on the reminder feature.
- `TodoTableViewCell` is declared and registered but the list is rendered with `NewTableTableViewCell`; it can likely be removed.

---

## 📄 License

No license file is currently included in the repository. Add one (e.g. MIT) if you intend to share or open‑source this project.
