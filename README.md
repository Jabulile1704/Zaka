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
| **Add** | Amount, one of twelve categories, date, optional note. |
| **Insights** | Month total, spend per day so far, and a share-of-spend bar per category. Step back through previous months. |

The share button on **Expenses** exports everything as CSV — mail it to
yourself, drop it in Files, open it in Numbers. Columns are
`Date,Category,Note,Amount`, oldest first. Amounts are plain numbers with a
dot decimal and no currency symbol or thousands separator, so spreadsheets
read them as numbers rather than text. Notes are quoted and any embedded
quotes doubled, so commas, quotes and line breaks inside a note survive
intact.

The strip above the tab bar always shows the month-to-date total.

## Layout

```
Info.plist                  Bundle keys and the launch-screen colour
Tools/
  GenerateAppIcon.swift     Draws the app icon to PNG
Zaka/
  ZakaApp.swift             App entry, SwiftData container, splash gate
  Models/
    Expense.swift           The @Model record
    ExpenseCategory.swift   The twelve categories, with icon and colour
  Support/
    Money.swift             Rand formatting and keypad parsing
    DayGroup.swift          Buckets expenses into calendar days
    AmbientBackground.swift The colour wash the glass refracts
    CoinPalette.swift       Coin and banknote colours
  Views/
    RootView.swift          Tab shell and the month-total accessory
    ExpenseListView.swift   Expenses tab
    ExpenseFormView.swift   Add and Edit (same view, two modes)
    InsightsView.swift      Insights tab
    CoinMark.swift          The coin and banknote marks
    SplashView.swift        The launch animation
```

## Notes

Amounts accept either separator: on a South African keypad the decimal key is
`,`, so `45,50` and `45.50` both mean 45.50, while `1,234` is read as grouping
and means 1234. Display is always `R1,234.56` regardless of device region.

Currency is fixed to Rand in `Money.swift`; change `symbol` there to switch it.

## Icon and launch animation

The app icon is a two-tone rand coin — nickel ring, brass centre, milled
edge — drawn in the style of South African coinage rather than copied from
any real coin. It is vector art with no binary source to lose, so it lives in
`Tools/GenerateAppIcon.swift`. Re-run that after any change:

```bash
swift Tools/GenerateAppIcon.swift
```

It writes the light and dark 1024×1024 PNGs straight into the asset catalog.

The splash is an ordinary SwiftUI view, not a launch screen. iOS launch
screens are static by definition — the system draws them before any app code
runs — so `UILaunchScreen` is just a flat colour (`LaunchBackground`, matching
the splash), and `SplashView` animates on top of it once the app is up.

It plays **once per install**. After that it is pure delay between you and
your expenses, so `LaunchGate` records a `hasSeenSplash` flag and steps over
it on every later launch. Deleting and reinstalling brings it back; so does

```bash
xcrun simctl spawn booted defaults delete com.jabulile.zaka hasSeenSplash
```

on a simulator. The local store opens instantly, so the animation never
covers real work: it is tap-to-skip, its length is `duration` on
`SplashView`, and it reduces to a plain fade when Reduce Motion is on.

## iCloud sync

The code is in place but **sync is off**, because it cannot work on a free
Apple account. Attempting it fails at signing time:

> Personal development teams do not support the iCloud and Push
> Notifications capabilities.

So the model, the container and the entitlements are all CloudKit-ready and
the app runs local-only until the account allows otherwise. The CloudKit
configuration sits behind the `ZAKA_CLOUDKIT` compile flag rather than a
runtime check, because CloudKit fails *fatally* when the entitlement is
absent — the process dies at launch, and the failure is asynchronous, so it
cannot be caught with `try?`.

To turn it on, once enrolled in the Apple Developer Program:

1. Set `CODE_SIGN_ENTITLEMENTS = Zaka.entitlements` on the target. The file
   is already in the repo and declares the CloudKit container
   `iCloud.com.jabulile.zaka` plus `aps-environment`.
2. Add `remote-notification` to `UIBackgroundModes` in `Info.plist`, or the
   device only syncs while the app is open.
3. Add `ZAKA_CLOUDKIT` to `SWIFT_ACTIVE_COMPILATION_CONDITIONS`.

All three are needed. With the flag on and the entitlement missing the app
crashes on launch; with the entitlement on and the flag off it simply stays
local.

Every property on `Expense` carries a default value, which CloudKit requires
— it has no concept of a non-optional column without one. That change is
already committed and migrates an existing local store in place, verified
with data present.
