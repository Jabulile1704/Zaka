# DevOps

What is automated, what is manual, and what cannot be automated on this
Apple account.

---

## Pipeline

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs on every push
to `main`, every pull request, and on demand.

| Job | Does | Fails when |
| --- | --- | --- |
| **Logic tests** | `swift test` — 11 tests | Amount parsing or EAN-13 encoding breaks |
| **App tests on a simulator** | `xcodebuild test` — 26 tests | The app stops compiling, or the model, grouping, CSV or card logic breaks |

Both run on `macos-latest` and sign nothing (`CODE_SIGNING_ALLOWED=NO`), so
no certificates live in the repository.

The simulator is chosen at run time from whatever the image provides rather
than hardcoded, so a runner image refresh does not break the build.

**Known risk:** the app targets iOS 26 and uses Liquid Glass. If the runner
image ships an older Xcode, the build job fails for want of the SDK rather
than for anything wrong with the code. Both jobs print their toolchain
version first so that failure is obvious rather than mysterious.

## What is not automated

| Stage | State | Why |
| --- | --- | --- |
| Install to device | Manual `devicectl` over USB | Free account; no TestFlight |
| Release | None | Not on the App Store |
| Versioning | Manual in the project | One user, no release cadence |
| Crash reporting | None | No backend, nothing phones home |
| Monitoring | None | No server to monitor |

Nothing here phones home by design: there is no analytics, no telemetry and
no network calls. The trade is that a crash in the field leaves no trace.

## Environments

One. The app on the phone is the only environment — no dev, staging or
production split, because there is no server and a single user.

The simulator stands in for a test environment. It diverges in two ways that
have mattered:

- **No camera** — the barcode scanner cannot run there at all.
- **Few share targets** — which is exactly why the CSV share bug
  ([#12](../../issues/12)) got through.

Treat a green simulator run as necessary, not sufficient.

## Deploying to the phone

```bash
xcodebuild -project Zaka.xcodeproj -scheme Zaka -configuration Debug \
  -destination 'platform=iOS,id=<device-udid>' \
  -derivedDataPath build-device -allowProvisioningUpdates build

xcrun devicectl device install app --device <device-udid> \
  build-device/Build/Products/Debug-iphoneos/Zaka.app
```

Find the UDID with `xcrun devicectl list devices`.

> **Install over the top. Never delete the app first.**
> Deleting it destroys the expense database. Installing over an existing copy
> keeps the container intact.

## The Apple account ceiling

The project runs on a **free** personal team, which caps three things:

1. **Provisioning expires every 7 days** ([#18](../../issues/18)) — the app
   stops launching until reinstalled.
2. **No iCloud or push entitlement** ([#17](../../issues/17)) — sync is
   written and switched off behind the `ZAKA_CLOUDKIT` flag.
3. **No TestFlight** — so no over-the-air distribution.

All three clear with the Apple Developer Program. None is a code problem.

## Backups

There is no server, so the only copies of the data are:

- The SQLite store in the app container on the phone.
- Whatever an iPhone backup captured — `Library/Application Support` is
  included in iCloud and Finder backups.
- CSVs exported by hand from the share button.

**Export before anything risky**, especially before the weekly reinstall.

Backups must not live inside the working tree. `backup/` is in `.gitignore`
after real expense data was committed to a public repository once already
([#15](../../issues/15)).

## Secrets

None in the repository: no API keys, no tokens, no certificates. The commit
identity is a GitHub noreply address, so no personal email is exposed.

The only sensitive material this project has ever handled is the expense data
itself, and the lesson from [#15](../../issues/15) is that it belongs nowhere
near the repo.
