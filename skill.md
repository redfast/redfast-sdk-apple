---
name: engage
description: Guide for integrating the Recurly Engage Apple SDK (V3) for iOS and tvOS. Use when the user asks about redfast-ui, redfast-core, redfast-ui-push, redfast-ui-iap, PromptManager, PromptOverlay, PromptInline, PromptOverlayTrigger, PromptEvent, PromptResult, RedfastPushManager, Swift Package Manager setup, APNs/FCM push notifications, or StoreKit 2 in-app purchases on iOS or tvOS.
---

# Integration guide — Recurly Engage Apple SDK

This guide walks through how to integrate the SDK end-to-end using the patterns demonstrated in the Redflix example app. For the full API reference see [`api.md`](./api.md).

---

## Architecture overview

The recommended pattern is a **single shared trigger + single `.promptOverlay` at the root**. Each screen writes a `PromptOverlayTrigger` to a shared observable; the root view holds the single overlay modifier that resolves and displays the prompt.

```
App root
  └── TabView  ◄── .promptOverlay(trigger: $sharedData.trigger)
        ├── HomeView   → sets trigger on .task / button tap
        ├── LatestView → sets trigger on .task
        └── DetailView → sets trigger on .task / button tap
```

This avoids stacking multiple overlays in the view hierarchy and ensures only one prompt is ever shown at a time.

---

## Step 1 — Initialize the SDK

Initialize `PromptManager` once at app startup, before any view appears.

```swift
// redflixApp.swift
import SwiftUI
import redfast_ui

@main
struct RedflixApp: App {
    @StateObject private var redfastStatus = RedfastStatus()

    var body: some Scene {
        WindowGroup {
            RedflixTabBar()
                .environmentObject(redfastStatus)
        }
    }
}

class RedfastStatus: ObservableObject {
    @Published var isInitialized = false

    init() {
        PromptManager.initPrompt(appId: AppConstants.appId, userId: AppConstants.userId) { result in
            guard result.code == .OK else { return }
            self.isInitialized = true
        }
    }
}
```

`PromptManager.initPrompt` is safe to call before any view appears. `PromptManager.shared` is available as soon as the `completion` closure fires with `.OK`.

---

## Step 2 — Create the shared trigger state

Define a lightweight observable that any view in the hierarchy can write to.

```swift
// SharedData.swift
import SwiftUI
import redfast_ui

class SharedData: ObservableObject {
    @Published var trigger: PromptOverlayTrigger?
}
```

---

## Step 3 — Attach `.promptOverlay` at the root

Apply the modifier **once** at the highest point in the view tree — typically the root `TabView` or `NavigationStack`. Pass a binding to `sharedData.trigger` and handle the result in the `onEvent` closure.

```swift
// RedflixTabBar.swift
import SwiftUI
import redfast_ui

struct RedflixTabBar: View {
    @StateObject var sharedData = SharedData()

    var body: some View {
        TabView {
            HomeView()
                .environmentObject(sharedData)
                .tabItem { Label("Home", image: "home") }

            LatestView()
                .environmentObject(sharedData)
                .tabItem { Label("Latest", image: "latest") }
        }
        .tint(.white)
        .promptOverlay(trigger: $sharedData.trigger) { result in
            switch result.code {
            case .BUTTON1:
                // handle accept — result.value carries deep link, result.meta carries custom metadata
                break
            case .BUTTON2:
                break
            case .BUTTON3, .DISMISS, .TIMEOUT:
                break
            default:
                break
            }
        }
    }
}
```

The modifier automatically handles display, dismiss, suppression, and impression/goal tracking for `.MODAL`, `.BOTTOM_BANNER`, and `.INTERSTITIAL` prompt types.

---

## Step 4 — Trigger prompts from screens

Set `sharedData.trigger` when a screen becomes active. Use `.task` so the trigger fires after the view has appeared and data has loaded.

```swift
// HomeView.swift
struct HomeView: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        ScrollView { /* content */ }
            .task {
                await viewModel.fetchMovies()
                sharedData.trigger = .screen("HomeViewController")
            }
    }
}
```

```swift
// DetailView.swift
struct DetailView: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        ScrollView { /* content */ }
            .task {
                sharedData.trigger = .screen("detail")
            }
    }
}
```

The screen name must match the trigger configured in Recurly Engage exactly. If no prompt is configured for that screen `onEvent` is not called.

---

## Step 5 — Trigger prompts from button clicks

Write a `.button(clickId)` trigger in the button's action handler. The click ID must match the trigger configured in Recurly Engage.

```swift
// DetailView.swift
struct DetailView: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        VStack {
            Button("PURCHASE") { sharedData.trigger = .button("purchase") }
            Button("RENT")     { sharedData.trigger = .button("rent") }
        }
    }
}
```

A button trigger can be used in addition to a screen trigger — for example, when a prompt is configured to fire only when both a specific screen is active **and** a specific button is tapped.

---

## Step 6 — Display inline prompts

`PromptInline` is a drop-in SwiftUI view for zone-based inline content. Place it anywhere in the layout; it renders the image, handles impression tracking, and calls `onEvent` on tap or dismiss.

```swift
// HomeView.swift
import redfast_ui

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Platform-specific inline banner at the top of the feed
                #if os(iOS)
                PromptInline(zone: "redflix-banner-phone")
                #elseif os(tvOS)
                PromptInline(zone: "redflix-banner")
                #endif

                // rest of content
            }
        }
    }
}
```

The `zone` string must match the Zone ID configured in Recurly Engage. If no prompt is active for that zone `PromptInline` renders as `EmptyView` with no layout impact.

---

## Step 7 — Show a specific prompt directly

When you need more control — for example to resolve a prompt yourself and then decide whether to show it — use `getTriggerablePrompts` and set the trigger to `.prompt(...)`.

```swift
// LatestView.swift
struct LatestView: View {
    @EnvironmentObject var sharedData: SharedData

    var body: some View {
        content
            .task {
                await viewModel.fetchMovies()

                // Resolve prompts for this screen manually before showing
                let prompts = PromptManager.shared.getTriggerablePrompts(
                    screenName: "latest",
                    type: .MODAL
                )
                sharedData.trigger = .prompt(prompts.first)
            }
    }
}
```

This is useful when you want to inspect prompt properties (deep link, metadata, SKU) before deciding whether to display it, or when you want to pass a pre-fetched `Prompt` object directly.

---

## Complete file structure

The Redflix example app arranges these files like this:

```
redflixApp.swift       — SDK init, RedfastStatus
RedflixTabBar.swift    — SharedData, single .promptOverlay
View/Home/
  HomeView.swift       — .task screen trigger, PromptInline
View/Latest/
  LatestView.swift     — getTriggerablePrompts + .prompt trigger
View/Detail/
  DetailView.swift     — .task screen trigger, button triggers
```

---

## Push notifications (iOS only)

To add push support, uncomment the `AppDelegate` block in `redflixApp.swift` and add `@UIApplicationDelegateAdaptor`:

```swift
// redflixApp.swift
import redfast_ui
import redfast_ui_push

@main
struct RedflixApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // ...
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // FirebaseApp.configure()  // uncomment if using FCM
        RedfastPushManager.shared.configure()
        return true
    }
}
```

`PromptManager.initPrompt` must be called before `RedfastPushManager.shared.configure()`. In the Redflix pattern, `initPrompt` runs in `RedfastStatus.init()` which is created as a `@StateObject` before the `AppDelegate` fires on subsequent app launches — for the very first launch, the ordering is guaranteed because `RedfastStatus` is initialized in the `App` struct before the scene is built.

`RedfastPushManager` handles permission requests, token registration, and impression/goal tracking automatically with no additional code.

---

## In-app purchases (iOS only)

When a prompt result includes an `inAppProductId`, call `purchase` in the `onEvent` closure of `.promptOverlay`:

```swift
.promptOverlay(trigger: $sharedData.trigger) { result in
    if case .BUTTON1 = result.code, let sku = result.inAppProductId {
        Task {
            let iapResult = await PromptManager.shared.purchase(sku)
            if iapResult == .successful {
                // unlock content
            }
        }
    }
}
```

The conversion goal is reported to Recurly Engage automatically on a successful purchase.

---

## Common mistakes

| Mistake | Fix |
|---|---|
| Multiple `.promptOverlay` modifiers in the view hierarchy | Apply it once at the root `TabView` or `NavigationStack` |
| Setting `trigger` before `PromptManager.shared` is ready | Wait for the `.OK` callback in `initPrompt` before navigating to a screen that sets a trigger |
| Screen name doesn't match | Must match the trigger string configured in Recurly Engage exactly, including case |
| `PromptInline` not rendering | Check that the Zone ID matches and a prompt is active for that zone in Recurly Engage |
| Push not working | Ensure `initPrompt` is called before `RedfastPushManager.shared.configure()` |
