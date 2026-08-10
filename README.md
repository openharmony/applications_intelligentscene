# IntelligentScene

## Introduction

**IntelligentScene** (bundle name: `com.ohos.intelligentscene`) is a pre-installed **system application** in OpenHarmony. For each real-world scenario (Do Not Disturb, Sleep, Study, and more), it maintains a dedicated **Intelligent Scene** profile: notification and incoming-call policies, automatic enable conditions such as timers, and linkage with system settings after the scene takes effect (for example dark mode). It adapts phone and tablet form factors.

This application is a system preset app. Capabilities take effect only when `const.intelligentscene.enable=true`. Users enter through **Settings → Intelligent Scene** or the Control Center secondary panel.

### Core Capabilities

**Intelligent Scene state management**
- Supports preset scenes such as Do Not Disturb, Sleep, and Study, plus custom scenes.
- Uses `StateManager` for enable/disable state machines and writes the **currently active scene** into system SettingsData so Settings, Control Center, and related processes can read it.

**Do Not Disturb**
- When a scene is active, manages notification DND policies: notification allowlists, sound/vibration allowlists, contact allow/block lists, repeated callers, and reject-call policies.
- Uses `NotDisturbAdapter` / `NotDisturbTimerManager` to push DND (Focus) policies to the system Notification service and manage DND timers.

**Settings linkage**
- When a scene is enabled, applies that scene’s configured linkage items to system settings (for example dark mode) and handles Live View presentation.
- Uses `SettingLinkageManager` for each linkage state machine.

**Activation management (condition-based auto enable)**
- **Rules**: User-configured mappings of *trigger condition → which Intelligent Scene to enable*. After conditions are saved, `ActivationManager` builds a rule set and posts it to the system rule engine (Awareness / ECA). When conditions match, the engine callbacks the app to enable the target scene.
- **Condition triggers** typically include:
  - **Time conditions**: e.g. enable Sleep every day 22:00–07:00;
  - **Temporary time conditions**: e.g. enable DND for 1 hour;

**Config business**
- **Local current-open state**: runtime state persisted by this app—which scene is currently on, how it was enabled, and which condition triggered it. The data model is `CurrentOpenedMode` (`modeId` is `'0'` when closed), read/written by `LocalSceneManager`. Enable/disable flows use it for process recovery (know the last open state after restart) and conflict handling (for example how to treat an already-open scene when enabling a new one).
- **Allow-disturb config**: apps and contacts still allowed to ring or notify while DND is on for a scene (`AllowDisturbManager`).
- **Contact policies**: call allow/block lists and related policies (`ContactAdapter`).

**Intelligent Scene configuration**
- Provides **template configs** for each preset scene (via `ModeConfigAdapter`, which resolves a config class by `modeId`, for example Sleep → `SleepModeConfig`; custom scenes use the default `BaseModeConfig`): default capability flags (whether DND is supported) and which Settings home-page groups are shown by default (for example Study mode shows “Enable method”, “Allow disturb”, and similar groups).

**Data management**
- Owns in-app models and persistence:
  - **Scene entities** (name, icons, deletable flag, etc., `MODE_DATA_TABLE`);
  - **Per-scene config items** (DND policy, linkage settings, trigger conditions, etc., `MODE_CONFIG_DATA_TABLE`);
  - **Contact policies** (`CONTACT_DATA`), and more.
- Uses **this application’s own** relational database (OpenHarmony RDB) `IntelligentScene.db` (security level S2; see `DbConfig` / `RDB_STORE_CONFIG` under `common`). Cross-process shared state is written separately to system SettingsData.

## Architecture

IntelligentScene uses a layered and modular design organized by product form, business features, and common capabilities:
![Architecture](./docs/figures/IntelligentScene_en.png)

### Application Layer Design

Three layers: product, feature, and common.

| Layer | Main path | Description |
| ----- | --------- | ----------- |
| Product | `product/phone` | Single phone/tablet HAP entry: declares Ability / UIExtension / Service; hosts Settings home, scene detail, Control Center panel, DND pages; implements stubs and static subscribers. **Modify entry UI mainly in this layer.** |
| Feature | `feature/*` | One HAR per business capability: scene enable/disable, DND, linkage, condition activation, config I/O, preset templates, RDB tables. **Modify a business path mainly in the matching feature.** |
| Common | `common` | Shared infrastructure used across features (not a user-facing feature by itself): EventBus, shared list-row/dialogs, this app’s RDB wrappers, logging, `PermissionVerifyUtil`. **Modify this layer for cross-feature reuse.** |

**Product-layer modules** (`product/phone`)

| Capability | Module / path | Description |
| ---------- | ------------- | ----------- |
| App entry | `entryability/` | Full-screen `EntryAbility`; `IntelligentSceneUIExtSettingAbility` for **Settings** embed; `SceneControlUIExtAbility` for **Control Center** secondary panel. |
| Resident service | `serviceability/` | Resident `IntelligentSceneServiceExtAbility`; `DataExtAbility` DataShare provider. |
| Settings home | `pages/settinghome/` | Settings → Intelligent Scene list / detail / edit. |
| Control Center | `pages/controlcenter/` | Control Center secondary panel (quick toggles, “More settings”). |
| Do Not Disturb | `pages/nodisturb/` | Notification allowlist, contact policy, incoming-call policy pages. |

**Feature-layer modules** (`feature/*`)

| Capability | Module / path | Description |
| ---------- | ------------- | ----------- |
| Intelligent Scene state management | StateManager (`statemanage`) | Enable/disable a scene by `modeId`; update local current-open state; write SettingsData (for example focus-related keys); chain DND and settings linkage |
| Do Not Disturb | NotDisturbAdapter, NotDisturbTimerManager (`notdisturb`) | Sync DND profiles and timed DND with Notification |
| Settings linkage | SettingLinkageManager (`configlinkage`) | Apply dark mode and other system settings when a scene takes effect; Live View |
| Activation management | ActivationManager (`activationmanage`) | Publish user time/app conditions to the rule engine; maintain auto-enable and recommendation rule sets |
| Config business | LocalSceneManager, AllowDisturbManager, ContactAdapter (`configmanage`) | Current-open state, allow-disturb allowlists, contact policies |
| Intelligent Scene configuration | ModeConfigAdapter (`modeconfig`) | Preset-scene defaults and home-page group visibility |
| Data management | ModeDataManager, ConfigDataManager (`datamanage`) | Scene/config/contact models and `IntelligentScene.db` access |

**Common-layer modules** (`common`)

| Capability | Module / path | Description |
| ---------- | ------------- | ----------- |
| Utils / constants | `constant/`, `utils/` | Business constants: `ModeConstant` (scene `modeId`, enable/disable flags), `DbConfig` (`IntelligentScene.db` name and table fields), `EventBusNameConstant`, and more; shared helpers: `SettingsDataUtils`, `JsonUtil`, device-form checks |
| RDB | `rdbstore/` | App DB access: `RdbStoreHelper` opens EL2 `IntelligentScene.db` (and backup) for create-table, CRUD, backup/restore, and corruption handling |
| EventBus | `common/EventBus` | In-process event bus (`on` / `emit` / `detach`) for setting-item toggles, semi-modal close, and similar state transfer |
| IPC Stub | `stub/` | IPC stub base `BaseServiceStub` for product Service stubs (auth + dispatch) |
| UI infrastructure | `basecomponent/`, `framework/` | Page-level reusable controls (`ConfirmDialogComponent`, Toast via `PromptManager`, link text, symbol icons); Settings-detail page infrastructure (`PageRouter` / `PageLoader`, `SettingPage` / `SettingItemStandard` / `SettingGroup` / `SettingSheet` / `SettingDialog`, and state models) |
| Logging / permission | `utils/LogUtil`, `utils/PermissionVerifyUtil` | Unified logging; IPC caller allowlist checks |

### Relationship with Other Applications

Exported components (`EntryAbility`, `IntelligentSceneUIExtSettingAbility`, `SceneControlUIExtAbility`, `IntelligentSceneServiceExtAbility`, and related entries with `exported=true`) may be started via Want / UIExtension / Service by system peers. **Prerequisites**: the app is installed and `const.intelligentscene.enable=true`. Service/IPC callers must pass the `PermissionVerifyUtil` allowlist (for example `com.ohos.sceneboard`).

By scenario:

| Scenario | Description |
| -------- | ----------- |
| User opens full Intelligent Scene settings | **Settings**, when Intelligent Scene is installed and the feature switch is on, launches **UIExtension** `IntelligentSceneUIExtSettingAbility` (or Want with `uri: intelligent_scene_entry`, etc.) for home/detail pages |
| User opens Control Center scene panel | **SceneBoard** (Control Center host), under the same install/switch conditions, launches **UIExtension** `SceneControlUIExtAbility` for quick toggles; “More settings” jumps to the Settings entry |
| Desktop/system needs shared cross-process state | Settings, Control Center, Desktop read/write system **SettingsData** (`@ohos.settings` / DataShare) keys written by this app (for example focus-related keys, current scene state); wrappers: `SettingsDataUtils`, `SettingsDataKeyConstant` |
| Trusted system access to resident service / DataShare | Allowlisted bundles bind **Service** (`IntelligentSceneServiceExtAbility`) or **DataShare** (`DataExtAbility`); callers that fail `PermissionVerifyUtil` are rejected |

## Build

This project is a multi-module HAP application built with Hvigor. The output is the `com.ohos.intelligentscene` system app package.

### Environment Requirements
- OpenHarmony SDK (`compileSdkVersion` 26.0.0; `compatibleSdkVersion` / `targetSdkVersion` 20 in this project)
- DevEco Studio or command-line Hvigor toolchain
- System signing materials (see `signature/`)

### Build Commands

Run from the project root:

```bash
# Open the project in DevEco Studio and Build, or use the hvigor CLI
hvigorw assembleHap
```

## IntelligentScene Development

IntelligentScene is developed in **ArkTS**, with UI based on the ArkUI Stage model. The application uses `product` for Ability entry and pages, the feature layer for scene state, DND, linkage, and related business, and `common` for shared infrastructure. See: [ArkUI Development Overview](https://gitcode.com/openharmony/docs/blob/master/en/application-dev/ui/arkts-ui-development-overview.md)

### Developing on Existing Modules

Typical scenarios: customize scene enable/disable logic, extend DND allowlists, change Control Center / Settings UI, or refine linkage presentation.

Locate changes by boundary: `product/phone` (entry and pages), `feature/statemanage` (scene state), `feature/notdisturb` (DND), `feature/configlinkage` (settings linkage), `feature/activationmanage` (activation), `feature/configmanage` (config business), `feature/modeconfig` (scene config), `feature/datamanage` (data), or `common` (shared).

Common modification scenarios:

**Scenario 1: Modify the scene enable/disable path**

- Control Center entry: `product/phone/src/main/ets/pages/controlcenter/ControlCenterPage.ets`
- State machine: `feature/statemanage/src/main/ets/manager/StateManager.ets`
- DND policies: `feature/notdisturb/`

 For example, add a custom pre-check when enabling a scene in `StateManager.startScene()`:
```typescript
 // StateManager.ets — startScene is the scene-enable entry
 public startScene(modeId: string, operType: number, sourceType?: number, updateTime?: number): string {
   // [Add custom pre-check]
   if (!this.customPreCheck(modeId)) {
     return '';
   }

   // Existing flow: state validation → write SettingsData → link DND / system settings
   // ...
 }
```
**Scenario 2: Modify the settings linkage path**

- Linkage management: `feature/configlinkage/src/main/ets/manager/SettingLinkageManager.ets`
- Live View logic lives in the same module

 For example, add another system-settings linkage after a scene is enabled in `SettingLinkageManager.effectModeLinkedSettings()`:
```typescript
 // SettingLinkageManager.ets — applies linkage for the active scene
 public async effectModeLinkedSettings(modeId: string): Promise<void> {
   LogUtil.showInfo(TAG, `effectModeLinkedSettings mode:${modeId}`);
   let darkModeState: SettingsLinkageState = await SystemSettingManager.getSystemSettingByType(modeId,
     ConfigType.SYSTEM_SETTINGS_DARK_MODE);
   this.darkModeStateMachine.convertState(darkModeState);

   let eyeProtectState: SettingsLinkageState = await SystemSettingManager.getSystemSettingByType(modeId,
     ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
   this.eyeProtectStateMachine.convertState(eyeProtectState);

   // [Add custom linkage]
   // let customState: SettingsLinkageState = await SystemSettingManager.getSystemSettingByType(
   //   modeId, ConfigType.YOUR_CUSTOM_SETTING);
   // this.customStateMachine.convertState(customState);
 }
```
**Scenario 3: Modify configuration / data**

- Preset scene config: `feature/modeconfig/`
- Business config: `feature/configmanage/`
- Data access: `feature/datamanage/`

 For example, change default group visibility via `ModeConfigAdapter.getGroupVisible()`:
```typescript
 // ModeConfigAdapter.ets — getGroupVisible controls whether a Settings home group is shown
 public getGroupVisible(modeId: string, groupId: HomeGroupId): boolean {
   const modeConfig: BaseModeConfig = this.getConfigByModeId(modeId);
   if (groupId === HomeGroupId.INTELLIGENT_EXPERIENCE) {
     return false;
   }
   // [Change point] adjust group visibility as needed
   // if (groupId === HomeGroupId.SYSTEM_FUNCTION) {
   //   return true;
   // }
   return modeConfig.supportGroupIdSet.has(groupId);
 }
```
**Scenario 4: Modify UI components**

- Settings home / scene detail: `product/phone/src/main/ets/pages/settinghome/`
- Control Center secondary panel: `product/phone/src/main/ets/pages/controlcenter/`
- DND-related pages: `product/phone/src/main/ets/pages/nodisturb/`
- Shared dialogs / list rows: `common/src/main/ets/`

 For example, the Control Center page composes the title bar, scene list, and “More settings”:
```typescript
 // ControlCenterPage.ets — Control Center secondary panel composition
 @Component
 struct ControlCenterPage {
   build() {
     Column() {
       TitleBarComponent({ /* props */ })
       ModeListComponent({ /* props */ })
       BottomButtonComponent({
         onButtonClick: () => {
           this.jumpSettings();
         },
       })
     }
   }
 }
```
Common entry points:

| Target | Path |
| ------ | ---- |
| Settings home / scene list & detail | `product/phone/src/main/ets/pages/settinghome/` |
| Control Center secondary panel | `product/phone/src/main/ets/pages/controlcenter/` |
| DND / notification allowlist / call policy UI | `product/phone/src/main/ets/pages/nodisturb/` |
| Intelligent Scene state management | `feature/statemanage/` |
| Do Not Disturb | `feature/notdisturb/` |
| Settings linkage | `feature/configlinkage/` |
| Activation management | `feature/activationmanage/` |
| Config business | `feature/configmanage/` |
| Intelligent Scene configuration | `feature/modeconfig/` |
| Data management | `feature/datamanage/` |
| Caller allowlist | `common/src/main/ets/utils/PermissionVerifyUtil.ets` |

### Developing New Feature Capabilities

Use a concrete end-to-end example: **add a new preset scene that can auto-enable on a time condition** (example name: Commute), including step order and dependencies.

> **Note**: Structure is `product + feature + common`, entry in `product/phone`. New business usually extends an existing feature; add a new product directory only for a new HAP form.

#### Example goal

Users should: see “Commute” in Settings → configure “enable at 08:00 on weekdays” → at 08:00 the system enables that scene (DND/linkage follow that scene’s config).

Required chains: **business data + enable path**, **system entry for Settings/Control Center**, **user-facing UI**. Order: **business first → entry second → UI last**.

**Step 1: Extend business capabilities (how this scene works in the feature layer)**

| Problem to solve | Description |
| ---------------- | ----------- |
| System must know the Commute entity | Add preset `modeId`, default name/icon, and default template in `feature/modeconfig` / `feature/datamanage`; otherwise list and RDB have no scene |
| Time conditions must actually fire | After `feature/configmanage` persists conditions, call `ActivationManager.updateIntelligentSceneRuleSet()` to post to the rule engine; **DB-only save never fires at the scheduled time** |
| Enable must apply DND/linkage | Ensure `StateManager.startScene(commute modeId)` chains `notdisturb` and `configlinkage`; extend the related feature if Commute needs differentiated policies |

Suggested order:

1. Persist entity and config in the feature layer (`modeconfig`, `datamanage`, `configmanage`).
2. Rule publish and enable/disable via `activationmanage` and `statemanage`.
3. Optionally create a new `feature/xxx` HAR and declare dependencies in `build-profile.json5` and `product/phone/oh-package.json5`.
4. **Do not finish full UI before business works**—pages would only bind empty data.

**Step 2: Configure / verify Ability entry (so system apps can find this capability)**

Even if business logic lives in a HAR, **Settings/Control Center only launch Abilities declared under product**. Check `product/phone/src/main/module.json5`:

- Existing exported components cover the path: full-screen `EntryAbility`, Settings embed `IntelligentSceneUIExtSettingAbility`, Control Center `SceneControlUIExtAbility`, background Service `IntelligentSceneServiceExtAbility`.
- New UIExtension/Service scenarios must declare **name, type, permissions, exported**, or external Want **cannot start them**.
- Permissions are sufficient (for example `ACCESS_SYSTEM_SETTINGS` for SettingsData).

Existing entry sketch:

```json
{
  "module": {
    "name": "phone",
    "type": "entry",
    "mainElement": "EntryAbility",
    "deviceTypes": [
      "default",
      "tablet"
    ],
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "exported": true
      }
    ],
    "extensionAbilities": [
      {
        "name": "IntelligentSceneUIExtSettingAbility",
        "srcEntry": "./ets/entryability/IntelligentSceneUIExtSettingAbility.ets",
        "type": "sys/commonUI"
      },
      {
        "name": "SceneControlUIExtAbility",
        "srcEntry": "./ets/entryability/SceneControlUIExtAbility.ets",
        "type": "sys/commonUI"
      },
      {
        "name": "IntelligentSceneServiceExtAbility",
        "srcEntry": "./ets/serviceability/IntelligentSceneServiceExtAbility.ets",
        "type": "service"
      }
    ]
  }
}
```

**Step 3: Customize UI (user sees and configures step-1 business)**

After business data and Ability reachability are ready, update product pages to expose Commute, for example:

| UI | Path | Purpose |
| -- | ---- | ------- |
| Settings home list adds a “Commute” card | `pages/settinghome/` | Detail entry and master switch |
| Condition page for 08:00 on weekdays | condition sheets / pages integrated with `configmanage` | Persist time condition and trigger rule publish |
| Control Center list shows Commute toggle | `pages/controlcenter/` | Quick enable/disable |
| Optional standalone DND allowlist pages | `pages/nodisturb/` | Configure who may disturb |

To add an independent page:

1. Add the page under `product/phone/src/main/ets/pages/`;
2. Register it in `resources/base/profile/main_pages.json` if system routing is required;
3. Launch via Navigation / Want / Settings navigation.

**Step relationship**: Step 1 makes “auto enable at 08:00” real; step 2 makes Settings/Control Center able to enter; step 3 lets users configure and see it. Missing any step yields “UI but no effect”, “logic but unreachable”, or “entry but no data”.

## Directory
```text
intellligentscene7.0
├─AppScope                              # App-level config and i18n resources
│  ├─app.json5                          # bundleName, version, etc.
│  └─resources/                         # Global strings / icons
├─common                                # Common layer (cross-feature infra)
│  └─src/main/ets/
│     ├─basecomponent/                  # Shared UI: confirm dialog, Toast, link text, symbol icons
│     ├─constant/                       # Business constants: ModeConstant(modeId/enable), SettingsData keys, DbConfig fields, EventBus names
│     ├─framework/                      # EventBus state bus; PageRouter nav; SettingPage/Item/Group/Sheet/Dialog
│     ├─rdbstore/                       # RdbStoreHelper(EL2 IntelligentScene.db)/El1RdbStoreHelper: open/CRUD/backup
│     ├─utils/                          # LogUtil, PermissionVerifyUtil allowlist, SettingsDataUtils
│     └─stub/                           # BaseServiceStub (IPC base for product stubs)
├─feature                               # Feature layer
│  ├─statemanage/                       # Scene enable/disable state machine, SettingsData writes
│  ├─notdisturb/                        # DND profile / notification allowlist, timed DND
│  ├─configlinkage/                     # Link dark-mode etc. when scene is active; Live View
│  ├─activationmanage/                  # Post time/app rules to engine; recommendation rule set
│  ├─configmanage/                      # Current-open state, allow-disturb allowlist, contact policies
│  ├─modeconfig/                        # Preset scene defaults, Settings home group visibility
│  └─datamanage/                        # Scene/config/contact models; IntelligentScene.db access
├─product                               # Product layer
│  └─phone/                             # Phone / tablet HAP
│     └─src/main/ets/
│        ├─entryability/                # UIAbility / UIExtension
│        ├─serviceability/              # Service / DataShare
│        ├─pages/                       # Settings home, Control Center, DND pages
│        ├─stub/                        # IPC Stub implementations
│        └─subscriber/                  # Static subscribers
├─docs/figures/                         # Architecture figures
├─hvigor                                # Build tool configuration
├─signature                             # Signing certificates and profile
├─build-profile.json5                   # Project-level config
├─build.sh
├─oh-package.json5
├─OAT.xml                               # Open-source compliance audit
├─LICENSE
├─README.md                             # English documentation
└─README_zh.md                          # Chinese documentation
```

## Constraints
- **Language**: ArkTS
- **Runtime form**: system preinstalled app (`com.ohos.intelligentscene`), depends on SettingsData, Notification, and system settings
- **Device types**: phone, tablet (see `product/phone/src/main/module.json5`)
- **Feature switch**: `const.intelligentscene.enable` must be enabled
- **Permissions** (see `product/phone/src/main/module.json5`):

  | Permission | Grant mode | Concrete usage |
  | ---------- | ---------- | -------------- |
  | ohos.permission.ACCESS_SYSTEM_SETTINGS | system | Read/write SettingsData keys for the current scene and DND, used to sync which scene is on and whether DND is enabled so Settings and Control Center stay consistent |
  | ohos.permission.MANAGE_SETTINGS | system | Manage system settings when a scene applies linkage (e.g. dark mode) |
  | ohos.permission.MANAGE_SECURE_SETTINGS | system | Read/write secure SettingsData (`USER_SECURITY`): focus enable/disable and current scene ID; dark-mode linkage; Live View state; and restricted DataShare access |
  | ohos.permission.NOTIFICATION_CONTROLLER | system | When DND is on for a scene, set DND profiles and notification allowlists on Notification |
  | ohos.permission.GET_BUNDLE_INFO | system | Resolve name/icon for apps listed on the “allowed notifications” page |
  | ohos.permission.GET_INSTALLED_BUNDLE_LIST | system | Enumerate installed apps for allowlist selection |
  | ohos.permission.READ_CONTACTS | user | Read contacts when configuring call DND policies |
  | ohos.permission.RUNNING_LOCK | system | Hold running lock during timed/condition tasks so enable/disable is not suspended early |
  | ohos.permission.START_SYSTEM_DIALOG | system | Show system confirm dialogs (e.g. confirm enabling a scene) |
  | ohos.permission.START_ABILITIES_FROM_BACKGROUND | system | On time condition fire or rule-engine callback, start Service/Ability from background to auto-enable |
  | ohos.permission.START_INVISIBLE_ABILITY | system | Start invisible Settings components for configuration jumps |

- **External calls**: Service / IPC only for allowlisted bundles
- **Form adaptation**: phone / tablet layouts differ; validate both when changing UI

## Contributing

Contributions of code and documentation are welcome. See [Contributing](https://gitcode.com/openharmony/docs/blob/master/en/contribute/contribution.md).

## Related Repositories

- [applications_settings](https://gitcode.com/openharmony/applications_settings) (Settings app; hosts the Intelligent Scene settings entry)
- [window_scene_board](https://gitcode.com/openharmony-sig/window_scene_board) (SceneBoard; Control Center host)
- [arkui_ace_engine](https://gitcode.com/openharmony/arkui_ace_engine)
