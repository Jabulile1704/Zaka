# Zaka

A personal expense tracker for iPhone. Everything is stored on the device —
no account, no network, nothing leaves the phone.

## Running it

Open `Zaka.xcodeproj` in Xcode and press Run, or from the terminal:

```bash
xcodebuild -project Zaka.xcodeproj -scheme Zaka \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Requires **iOS 26** or later — the UI is built on Liquid Glass
(`glassEffect`, `GlassEffectContainer`, the glass tab bar and its bottom
accessory), which does not exist on earlier releases.

To put it on your own iPhone you need to sign it: open the project in Xcode,
select the Zaka target → Signing & Capabilities, and pick your Apple ID team.
A free account works; the build expires after 7 days and needs a re-install.

## What's here

| Screen | What it does |
| --- | --- |
| **Expenses** | Everything you've logged, grouped by day with a per-day total. Tap a row to edit, swipe to delete. |
| **Add** | Amount, one of eight categories, date, optional note. |
| **Insights** | Month total, spend per day so far, and a share-of-spend bar per category. Step back through previous months. |

The strip above the tab bar always shows the month-to-date total.

## Layout

```
Zaka/
  ZakaApp.swift            App entry, SwiftData container
  Models/
    Expense.swift           The @Model record
    ExpenseCategory.swift   The eight categories, with icon and colour
  Support/
    Money.swift             Rand formatting and keypad parsing
    DayGroup.swift          Buckets expenses into calendar days
    AmbientBackground.swift The colour wash the glass refracts
  Views/
    RootView.swift          Tab shell and the month-total accessory
    ExpenseListView.swift   Expenses tab
    ExpenseFormView.swift   Add and Edit (same view, two modes)
    InsightsView.swift      Insights tab
```

## Notes

Amounts accept either separator: on a South African keypad the decimal key is
`,`, so `45,50` and `45.50` both mean 45.50, while `1,234` is read as grouping
and means 1234. Display is always `R1,234.56` regardless of device region.

Currency is fixed to Rand in `Money.swift`; change `symbol` there to switch it.
