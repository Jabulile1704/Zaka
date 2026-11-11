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
| **App tests on a simulator** | `xcodebuild test` — 37 tests | The app stops compiling, or the model, grouping, CSV or card logic breaks |

Both run on `macos-latest` and sign nothing (`CODE_SIGNING_ALLOWED=NO`), so
no certificates live in the repository.

The simulator is chosen at run time from whatever the image provides rather
than hardcoded, so a runner image refresh does not break the build.

**Known risk:** the app targets iOS 26 and uses Liquid Glass. If the runner
image ships an older Xcode, the build job fails for want of the SDK rather
than for anything wrong with the code. Both jobs print their toolchain
version first so that failure is obvious rather than mysterious.

## Releases

[`.github/workflows/release.yml`](../.github/workflows/release.yml) runs when
a tag like `v1.0.0` is pushed:

1. Runs the whole CI workflow — both test suites — by calling it, not by
   copying it.
2. Checks the tag against `MARKETING_VERSION`. `v1.1.0` on a 1.0 app fails
   here, before anything is built.
3. Builds a Release configuration for the simulator and zips it.
4. Publishes a GitHub Release with notes generated from merged pull requests.

```bash
git tag v1.0.0 && git push origin v1.0.0
```

**This is delivery, not deployment.** The published build is unsigned and
runs only in the simulator. Putting it on a phone or the App Store needs a
certificate from the paid Apple Developer Program; signing and a TestFlight
upload slot in after the build step once the account exists.

## Project board

The [board](https://github.com/users/Jabulile1704/projects/6) has six
columns and a Sprint field with one-week iterations.

| Column | Meaning | Moved by |
| --- | --- | --- |
| Backlog | Known work, not yet shaped | Automation, when an issue opens |
| Ready | Shaped and unblocked | Hand |
| In Progress | On a branch | Hand |
| In Review | Pull request open | Automation |
| Testing | CI green, being checked on a device | Automation |
| Done | Merged to `main` | Automation |

[`.github/workflows/board.yml`](../.github/workflows/board.yml) makes the
automated moves. It finds a pull request's issues from `Closes #N` in the
body, so that line is what ties a pull request to its card.

It needs a repository secret named `PROJECT_TOKEN`: a personal access token
with the `project` scope. The built-in `GITHUB_TOKEN` cannot write to a
user-level project. **Without the secret every job skips rather than
fails**, and the board has to be moved by hand:

```bash
.github/scripts/board-status.sh 24 "In Review"
```

## What is not automated

| Stage | State | Why |
| --- | --- | --- |
| Install to device | Manual `devicectl` over USB | Free account; no TestFlight |
| App Store release | None | Not on the App Store; GitHub Releases are automated |
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
