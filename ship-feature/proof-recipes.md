# Proof recipes

Commands for Phase 5 of [`SKILL.md`](SKILL.md): drive the real build, capture
what it does, and turn the capture into something you can actually read.

Rebuild before every one of these. A stale build is the most common cause of
both a phantom bug and a phantom pass.

## Reading a capture (all platforms)

A recording is only evidence once it is frames. Sample, read in order, then
re-sample the window where something changes:

```sh
mkdir -p /tmp/frames && ffmpeg -loglevel error -i run.mov -vf fps=4 -q:v 2 /tmp/frames/%03d.png
ffmpeg -loglevel error -ss 1.4 -t 0.8 -i run.mov -vf fps=20 -q:v 2 /tmp/frames/close-%03d.png
```

Crop and enlarge before judging spacing, radius, weight or alignment:

```sh
ffmpeg -loglevel error -i shot.png -vf "crop=W:H:X:Y,scale=iw*4:ih*4:flags=neighbor" /tmp/crop.png
```

Reduce a region to one averaged pixel when the question is "is anything
bleeding through / did the color change", and compare it against a control
region or the before-capture — never against an absolute threshold, which
passes on a dimmed-but-still-broken screen:

```sh
ffmpeg -loglevel error -i /tmp/crop.png -vf scale=1:1 -f rawvideo -pix_fmt rgb24 - | xxd -p
```

Difference two captures directly:

```sh
ffmpeg -loglevel error -i before.png -i after.png \
  -filter_complex "blend=all_mode=difference" /tmp/delta.png
```

## iOS / iPadOS (simulator)

```sh
xcodebuild -scheme App -destination 'platform=iOS Simulator,name=iPhone 16' build
xcrun simctl list devices booted
xcrun simctl install booted /path/to/App.app && xcrun simctl launch booted com.you.app

xcrun simctl io booted screenshot /tmp/shot.png
xcrun simctl io booted recordVideo --codec h264 /tmp/run.mov   # SIGINT to stop
```

Record in the background and stop it deliberately:

```sh
xcrun simctl io booted recordVideo --codec h264 /tmp/run.mov & REC=$!
# ... drive the app ...
kill -INT $REC && wait $REC
```

Drive it with a UI test (`xcodebuild test -scheme AppUITests`) when the flow
has more than a couple of steps — hand-driving is fine for one screen, but it
is not repeatable and the next slice will need it again.

Inside Realm, the `ios-simulator` skill mirrors a booted simulator into a
browser pane so the accessibility tree is readable and tappable by label.

## Android

```sh
./gradlew installDebug && adb shell am start -n com.you.app/.MainActivity
adb exec-out screencap -p > /tmp/shot.png
adb shell screenrecord --time-limit 10 /sdcard/run.mp4 && adb pull /sdcard/run.mp4 /tmp/run.mp4
```

Maestro or Espresso for the multi-step flows, same reasoning as iOS.

## Web

Serve the built output, not the dev server, when the change touches build
output or anything that behaves differently under a bundler. Some browser
features (paint worklets, service workers, clipboard, media permissions) are
silently disabled on `file://` and will render a fallback that looks like your
bug — always serve over http.

Realm: `browser_open` the URL, `browser_snapshot` to get refs, `browser_act`
by ref, `browser_screenshot` for the artifact — see the `browsing` skill.

Otherwise drive Playwright (the `playwright` skill wraps the CLI): navigate,
act, `--video` for motion, full-page screenshot for stills. Set the viewport to
the device the request is about; a desktop-width capture is not proof about a
phone layout.

## Electron / desktop

Boot the **built** app against a scratch home so the run cannot touch real user
data, with the remote debugging port open:

```sh
pnpm build
APP_HOME=$(mktemp -d) DEVTOOLS_PORT=9223 <your preview/start command> &
curl -s 127.0.0.1:9223/json | jq -r '.[] | "\(.title)\t\(.webSocketDebuggerUrl)"'
```

Node 22's global `WebSocket` is enough to drive it — no Playwright needed.
`Runtime.evaluate` to query and click, `Page.captureScreenshot` with a `clip`
from `getBoundingClientRect` and `scale: 4` for corner and hairline inspection,
`Page.startScreencast` for motion.

Two traps worth the extra lines:

- **The window screenshot is not the whole app.** Native child views
  (`WebContentsView`, `BrowserView`, embedded players) do not appear in a
  capture of the host window — capture the child's own contents, or capture the
  screen.
- **Teardown by path, not by port.** Background daemons and helpers often
  outlive a SIGTERM to the main process and get re-parented to init, so the
  next run dies at a port precheck and reads as a broken harness. Stop the
  helper processes explicitly, identify survivors by their scratch home path
  before killing anything, and remove the scratch home afterwards.

## macOS screen capture (when nothing else can see it)

```sh
screencapture -R X,Y,W,H /tmp/shot.png     # region
screencapture -v -V 6 /tmp/run.mov         # 6 seconds of video
ffmpeg -f avfoundation -list_devices true -i ""   # find the screen device index
```

Needs Screen Recording permission; the first attempt on a new binary prompts
and will hang a non-interactive run.

## CLI and server

Run the real binary, against a scratch `HOME`/config dir, and assert on exit
codes and real output rather than on the code path you think ran:

```sh
HOME=$(mktemp -d) ./dist/cli command --flag; echo "exit=$?"
script -q /tmp/session.log ./dist/cli interactive-command   # captures a TTY session
```

For a server, hit it over the wire (`curl -i`) from a cold start, including the
error and unauthorized cases — not through an in-process test client, which
skips the middleware the request actually traverses.
