# 灵动岛 · Dynamic Island for Windows

一个照着 iPhone 灵动岛做的 Windows 11 桌面悬浮岛。停在屏幕顶部正中，平时**完全点击穿透**、不抢焦点、不占任务栏；鼠标移上去才展开，动画是带过冲的弹簧曲线（Q弹）。

不是录屏、不是假数据 —— 所有内容都来自真实的系统 API。

---

## 1. 它现在能做什么

| 场景 | 岛上表现 |
| --- | --- |
| **放音乐** | 紧凑态：专辑封面 + 实时频谱条；悬停展开：大封面、标题/艺术家/专辑、可拖动进度条、上一首/播放暂停/下一首 |
| **连上蓝牙耳机** | 左侧弹出脉冲圆点 + 耳机图标 + 电量环，右侧保持音乐，形成苹果的**分离双岛**；无音乐时独占一条横幅显示「已连接 + 电量」 |
| **断开蓝牙耳机** | 横幅提示「已断开」 |
| **切换勿扰模式** | 月亮图标 + 「勿扰模式已开启 / 已关闭」横幅；开着音乐时自动变成双岛（左月亮、右音乐） |
| **插上电源充电** | **岛展开**成一整条绿色充电视图：绿色电池 + 大号百分比 + 闪电脉冲 |
| **调音量** | 喇叭图标 + 音量条横幅 |
| **Clock 闹钟 / 计时器** | **电脑自带「时钟」App 的闹钟和计时器上岛**：计时器运行时是常驻活动（倒计时 + 进度条），响铃时弹出橙色大铃铛 + 闹钟名字 |
| **闲置** | 纯黑胶囊（和 iPhone 一样什么都不显示）；鼠标悬停展开成时钟/日期 + 电量/闹钟/计时器/音乐信息胶囊 |

---

## 2. 快速开始

前置：**Windows 11 24H2 (build 26100) 或更高**、**Node.js 20+**、**.NET 10 SDK**（或仅安装 .NET 10 运行时 + SDK 用于编译桥）。

## 2. 怎么运行

### 最省事：双击

直接双击项目根目录里的 **`start（开始）.cmd`**。
它会自动检查依赖和构建产物，缺什么补什么，然后启动。已经启动过的话会提示"已在运行"而不是重复开一个（应用是单实例的）。

停止：双击 **`stop.cmd`**（会一起关掉 C# 系统桥进程）。

> 想放到桌面：右键 `start（开始）.cmd` → 发送到 → 桌面快捷方式。或者在托盘菜单里勾上**随 Windows 启动**，以后开机自动就在了。

### 或者用命令行

```powershell
cd dynamic-island
npm install                 # 装 Electron + React（只需一次）
npm run native:build        # 编译 C# 系统桥到 resources/bridge
npm run build               # 编译主进程 / 预加载 / 渲染进程
npx electron .              # 启动
```

> 国内网络建议在项目根目录放一个 `.npmrc`（已被 gitignore）加速 Electron 二进制下载：
> ```
> electron_mirror=https://npmmirror.com/mirrors/electron/
> registry=https://registry.npmmirror.com
> ```

一条龙（每次改完代码重新编译并启动）：

```powershell
npm run app                 # = native:build + build + electron .
```

开发模式（带 Vite HMR，改 UI 即时生效）：

```powershell
npm run dev
```

### 启动之后

* 岛会出现在**屏幕顶部正中**。平时是一个纯黑胶囊，鼠标移上去展开。
* **右键右下角托盘图标**：显示/隐藏、尺寸 85%~150%、逐项开关活动提示、随 Windows 启动、重连系统桥、运行诊断、退出。左键直接弹菜单。
* 启动时带 `--autostart` 参数就是开机自启模式。

**没有演示模式。** 岛只显示真实系统事件。想验证的话：随便放首歌、连上蓝牙耳机、按 Win+A 切一下勿扰、插拔电源、在「时钟」里开个计时器。

### 排错

启动不了的话，托盘菜单里点 **运行诊断**，或者跑一次性自检：

```powershell
.\resources\bridge\IslandBridge.exe --selftest
```

它会输出一份 JSON，包含系统版本、媒体会话、蓝牙设备+电量、音频端点、电源状态、以及勿扰相关的所有注册表槽位。

---

## 3. 架构

```
dynamic-island/
├─ native/IslandBridge/        C# .NET 10 + CsWinRT —— 唯一碰 WinRT 的地方
│  ├─ MediaMonitor.cs          GSMTC 媒体会话、专辑封面、进度、传输控制
│  ├─ BluetoothMonitor.cs      蓝牙音频设备接入/断开 + 电量
│  ├─ UsbMonitor.cs            USB 设备上岛（DJI 4G 上网模块，按 VID/PID 白名单）
│  ├─ PnpDevices.cs            SetupAPI：读 Windows 缓存的蓝牙电量、枚举 PnP 设备
│  ├─ FocusMonitor.cs          勿扰模式（FocusSessionManager 只读）
│  ├─ ClockMonitor.cs          「时钟」App 的闹钟 / 计时器 / 秒表
│  ├─ PowerMonitor.cs          电源与电池
│  ├─ AudioMeter.cs            Core Audio 峰值表 + 主音量
│  └─ Program.cs               NDJSON 事件流 / 命令流主循环
├─ src/main/                   Electron 主进程：透明置顶窗口、托盘、IPC
├─ src/preload/                contextBridge 安全桥
├─ src/shared/protocol.ts      主进程 ↔ 渲染进程的协议类型
└─ src/renderer/               React 19 + Framer Motion 灵动岛 UI
   └─ src/island/
      ├─ model.ts              状态机：把事件折叠成 presentation
      ├─ Island.tsx            形变外壳（弹簧驱动的 SVG 路径）
      ├─ views.tsx             各个视图
      └─ useIslandState.ts     事件 → 状态，音频峰值走 MotionValue 不触发 re-render
```

### 为什么中间要夹一个 C# 进程？

Node 没有可靠的 WinRT 通道（NodeRT 全是老版本预编译，Node 24 用不了）。PowerShell 5.1 能调 WinRT，但要靠反射 Await，而且每次轮询都要起新进程。
`.NET 10 + TargetFramework=net10.0-windows10.0.26100.0` 直接拿到强类型投影，一个常驻进程、真事件订阅、开销极低。桥和 Electron 之间是**换行分隔 JSON**，双向：stdout 出事件，stdin 进命令。

桥是**唯一**接触系统的地方，渲染进程永远只拿纯 JSON —— 系统调用崩了也拖不死 UI。

---

## 4. 系统集成细节（都是实测出来的）

### 4.1 媒体：GSMTC

`GlobalSystemMediaTransportControlsSessionManager` —— 和锁屏/音量弹窗同源。订阅 `MediaPropertiesChanged` / `PlaybackInfoChanged` / `TimelinePropertiesChanged`，任何变化立刻重发快照；另外每 3~5 秒补一次兜底轮询。
专辑封面通过 `Thumbnail.OpenReadAsync()` → `DataReader` 取出字节，SHA1 去重后只在换曲时以 data URL 发一次。
进度条不靠轮询：渲染端用 `positionMs + (now - lastUpdatedMs) * rate` 自己插值。

过滤掉了 `powershell.exe` 那种标题和艺术家都为空的幽灵会话。

### 4.2 蓝牙耳机：接入检测 + 电量 + 品牌标志

**接入判定不看蓝牙连接状态。** 这是踩过的坑：`BluetoothDevice.ConnectionStatus` 对**经典蓝牙（BR/EDR）A2DP 耳机经常一直是 Disconnected**，哪怕声音明明已经路由过去了。

真正可靠的信号是 **「这个设备占有了一个活跃的音频输出端点」**：耳机连上时，Windows 会发布 `耳机 (REDMI Buds 7S)` 这个活跃渲染端点；关机时它消失。所以现在的逻辑是：

1. 用 `MediaDevice.GetAudioRenderSelector()` 列出**当前活跃的音频输出端点**（这才是在响的那个）；
2. 拿配对列表提供身份（名字 + 蓝牙地址，地址后面读电量要用）；
3. 按名字互相包含来配对（`REDMI Buds 7S` ↔ `耳机 (REDMI Buds 7S)`）；
4. **只在状态真正变化时发事件** —— 旧版本每 2 秒无条件重发一次 "connected"，会让岛永远重复弹出。

**电量**：优先读 **Windows 自己缓存的值** —— `DEVPKEY_Bluetooth_Battery`（`{104EA319-6EE2-4701-BD47-8DDBF425BBE5}, 2`），也就是设置 ▸ 蓝牙页面显示的那个数字。实测：

```
BTHENUM\{0000111E-…}_HCIBYPASS_…\…C4600A032555_C00000000
  {104EA319-…} 2 = 100
  {104EA319-…} 7 = 2026-09-26 16:21:07
```

两个好处：**零成本**（不碰无线电、不会干扰音频），而且**经典蓝牙耳机也能读到** —— Redmi Buds 7S 走 GATT 永远返回 `no-ble-link`，但这条路能拿到 100%。用 SetupAPI（`DIGCF_ALLCLASSES` + `BTHENUM`）枚举，不需要管理员权限。

只有在 Windows 没有缓存值时才退回 GATT（`0x180F`/`0x2A19`，小米/红米额外扫厂商服务 `0xFD2D` 读左右耳/充电盒分量）。GATT 探测**放在后台、带 9 秒硬超时**，绝不阻塞轮询 —— 之前就是因为 GATT 读取卡住了整个轮询循环，导致连上耳机时岛完全没反应。

读不到就诚实显示「—」，不瞎编数字。

#### USB 设备也上岛（DJI 4G 上网模块）

USB 设备不上报音频端点，所以走另一条路：轮询 PnP 设备树，按 **VID/PID** 匹配一份**人工维护的白名单**（不能对所有 USB 设备都弹，否则插个 U 盘都来一发）。

DJI 的 4G 模块会枚举成一个 USB 复合设备，暴露 5 个接口：

```
USB\VID_2CA3&PID_4006           Baiwang USB Composite Device (0015)   ← 父节点
USB\VID_2CA3&PID_4006&MI_00     Baiwang USB DM Port (COM6)
USB\VID_2CA3&PID_4006&MI_01     Baiwang USB NMEA Port (COM9)
USB\VID_2CA3&PID_4006&MI_02     Baiwang USB AT Port (COM8)
USB\VID_2CA3&PID_4006&MI_03     Baiwang USB Modem
USB\VID_2CA3&PID_4006&MI_04     Baiwang Wireless Ethernet Adapter
```

`VID_2CA3` 就是大疆的厂商 ID。**只匹配父节点**（跳过所有 `&MI_` 子接口），所以一个物理设备只产生一条活动；名字显示成 `DJI 4G上网模块`，配上 DJI 标志。

要加别的设备，在 `UsbMonitor.cs` 的 `Rules` 里加一行 `new("VID", "PID", "显示名", "品牌logo")` 就行（PID 传 `null` 表示这个 VID 的任意产品）。

#### 品牌标志

岛会**从设备名反查品牌**，左边显示品牌标志，右边显示名字和电量图标：

```
[小米标] REDMI Buds 7S            [🔋] 82%
```

* 品牌表有 **73 条匹配规则**，按从具体到宽泛排序（`Galaxy Buds` 归三星而不是 AKG，`Redmi` 归小米，`Major IV` 归 Marshall）。
* **48 个品牌的方形标志**从 `simple-icons` 提取后随包发布（`npm run brands:sync` 重新生成），运行时不联网；SVG 内联后用 `fill: currentColor` 染色，配品牌色底。
* 拿不到免费方形标志的品牌（realme / Soundcore / Edifier / Baseus / Marshall / Skullcandy / AKG / Nothing / Logitech / Jabra / Philips / QCY …）退化成**品牌色字母块**——在 30px 这个尺寸上其实比缩成一团的字标更好认。
* 完全不认识的设备显示首字母中性块，不会瞎猜。

> Redmi 用的是小米的 Mi 标志，因为 Redmi 本身就是小米的子品牌，这也正是品牌自己的用法。

### 4.3 勿扰模式：能读，不能写（Windows 的限制）

这是整个项目里最玄学的一块，实测结论如下。

**不能写**：`Windows.UI.Shell.FocusSessionManager.TryStartFocusSession()` / `DeactivateFocus()` 全部抛
`E_ACCESSDENIED —— Feature com.microsoft.windows.focussessionmanager.1 is not available`。
这是 Windows 的 **Limited Access Feature** 门禁，第三方应用拿不到解锁令牌。所以岛上**只能弹系统快速设置**让你自己按，没法代按。

**读**：没有任何一个信号是 100% 可靠的，所以代码同时看两个，**哪个说"开"就按开算**：

| 信号 | 位置 | 性质 |
| --- | --- | --- |
| `FocusSessionManager.GetDefault().IsFocusActive` | WinRT（只读，允许） | 权威跟踪**专注会话**，但快速设置里的勿扰磁贴不一定会让它动 |
| `QuietHoursSettings.selectedProfile` | CloudStore 注册表 | 磁贴**选中的 profile**，`Unrestricted` = 关，其它 = 开 |

实测到 profile 确实会在 `Unrestricted` ↔ `PriorityOnly` 之间变，但 `IsFocusActive` 不跟着变；反过来 `IsFocusActive` 变过的时候 profile 也没动。两者语义不同，所以取并集最稳。

顺带排掉的坑：网上流传的「改 CloudStore 里 `$$windows.data.notifications.quiethourssettings` 的某个字节」在 25H2 上**已经不适用**——

* 那个路径在 build 26200 上不存在，现在叫
  `...\CloudStore\Store\DefaultAccount\Current\{8c8b63ee-…}$windows.data.donotdisturb.quiethourssettings`；
* 里面存的**不是 0/1/2 枚举**，而是 40 个字符的 profile 字符串；
* 而且这个 UTF-16 字符串的起始偏移是**奇数**（0x55），用 `Encoding.Unicode.GetString()` 从 0 开始解码出来是乱码；
* 把它从 `Unrestricted` 改成同长度的 `PriorityOnly`（长度不变、任何长度字段都不用动）**注册表写入成功且 Windows 不回滚**，但两个信号都不动 —— 说明那只是「配置」，不是「当前开关」。

**还有一个纯粹的展示 bug（已修）**：只要有一个媒体会话存在，勿扰横幅就会被渲染成"左侧一个小月亮 + 右侧音乐"的分离双岛——小到根本注意不到。现在**勿扰、响铃、充电会独占整条岛**，只有音量和耳机电量刷新这类不打扰的才走双岛。

### 4.4 时钟：闹钟 / 计时器上岛

「时钟」是打包 UWP 应用，状态在
`%LOCALAPPDATA%\Packages\Microsoft.WindowsAlarms_8wekyb3d8bbwe\Settings\settings.dat`。

这是个 ApplicationData 注册表 hive，**用 `RegLoadAppKey` 只读挂载不需要管理员权限**。里面的 `LocalState\Alarms`、`LocalState\Timers`、`LocalState\Stopwatch` 各存若干条复合值，格式是平铺的：

```
[u32 名字字符数][名字 UTF-16][NUL][值字节][下一条名字字符数]…
```

字段按类型解码（字符串 UTF-16、数字小端 int32/int64、时间和时长是 100ns ticks）就能拿到：闹钟的名字/时/分/星期位掩码/是否启用/贪睡间隔/下次触发时间，计时器的名字/总时长/开始时间/剩余时间。

每次轮询都**开→读→关**，绝不长期持有句柄，否则「时钟」自己就写不进去了。

计时器一开始倒数，岛就多一个常驻活动；归零就弹橙色响铃横幅。

### 4.5 电源：三个 API 互相矛盾，只有一个是对的

这是最容易做错的一块。Windows 上关于"插没插电"有三套说法，而这台笔记本上**它们互相矛盾**：

| 信号 | 这台机器的读数 | 含义 |
| --- | --- | --- |
| Win32 `GetSystemPowerStatus().ACLineStatus` | **1** | 电源已接上 —— **任务栏电池图标用的就是它** |
| `PowerManager.PowerSupplyStatus` | `Inadequate` | 名字看着像"没电"，其实只是"没在充电" |
| `Battery.AggregateBattery.GetReport().Status` | `Discharging` | 只要电池没在进电就报这个，包括"已经满了" |

电池 98% 且插着电时，后两个 API 一个说"供电不足"、一个说"正在放电"，只有 Win32 的 `ACLineStatus` 诚实地说"接上电了"。之前只信 WinRT 那两套，所以**插着电时岛毫无反应**。

现在：`ACLineStatus` 是主信号，充电标志只是细化。文案也跟着分三种：
* `正在充电` —— 真的在进电
* `已接通电源 / 电池已充满` —— 插着但已经满了（正常，不是故障）
* `电源功率不足`（琥珀色）—— 插着、没在充电、而且**电量还没满**，这才是真的充电器带不动

去重键也把"充满时 Charging↔Idle 反复横跳"折叠掉了，所以不会几秒弹一次。

### 4.6 音量：iPad 式音量岛

Core Audio 的 `IAudioEndpointVolume` + `IAudioMeterInformation`，手写 COM 互操作，不用第三方库。
**音量岛**：按音量键（或任何方式改变系统音量）时，岛整条变成 iPad 风格的音量条 —— 喇叭图标、可拖动的滑块、百分比。**滑块可以直接拖**，松手即生效；点喇叭图标静音/取消静音。拖动时是本地乐观更新，不会等桥的往返。

**关键坑**：这台机器的音频驱动（Intel Smart Sound / "Audio Device"）**根本不暴露 `IAudioMeterInformation`**，`Activate` 返回 `E_NOINTERFACE`。而 `IAudioEndpointVolume` 完全正常。
原来的代码把"峰值表拿不到"当成"整个音频不可用"，直接 `return false`，**连累音量岛一起死掉**。现在两者**独立挂载**：峰值表是可选的，只负责驱动频谱条；拿不到就用合成振荡兜底（所以条子一直在跳，只是不跟真实音量走）。音量则始终可用。

> 排查方法：`audio get` 命令会让桥原样回吐当前音量，不改变任何实际音量 —— 用来零影响地验证音量岛。

### 4.7 媒体时间轴：酷狗的坑

酷狗这类播放器**从不上报时间轴**，`TimelineProperties.LastUpdatedTime` 保持 `DateTimeOffset.MinValue`（约 -62 135 596 800 000 ms）。原来直接拿它做插值，算出来的播放位置是天文数字，界面上显示成 `3731909:00:54`。

三层防护：
* 桥：`LastUpdatedTime.Year < 2001` 时直接上报 `0`；
* 渲染：插值前检查时间戳落在合理区间（2001 年之后、不是未来、不超过 12 小时前），否则不插值；
* 格式化：`duration()` 对超过 24 小时的值返回 `--:--`。

时间轴不可用时进度条留空、只显示已播放时长，而不是编一个数字出来。

### 4.8 窗口、点击穿透与置顶

窗口 1100×580、透明、无边框、`focusable: false`、`skipTaskbar`、`alwaysOnTop('screen-saver')`，居中贴在屏幕最顶端。

**置顶保活**：Windows 只保证窗口在你调用 `SetWindowPos(HWND_TOPMOST)` 之后是最前的，别的应用一抢焦点就可能把它顶下去 —— 很多应用都会这么干，所以被动悬浮窗会"偶尔优先级不够"。现在有一个 **2 秒一次的看门狗**重新断言 `setAlwaysOnTop` + `moveTop()`（`moveTop` 不抢焦点），并在显示、显示器变化时也重新断言。

默认 `setIgnoreMouseEvents(true, { forward: true })` —— 鼠标事件照常转发给渲染进程，但点击全部穿透到下面的应用。
渲染进程每次 `mousemove` 算岛的矩形做命中测试，**进入用 8px 余量、离开用 34px 余量**（迟滞），避免岛长大之后指针跑到外面导致展开/收起来回抖。只有指针真在岛上时才关掉穿透。

> 踩过的坑：透明窗口如果只靠 `ready-to-show` 显示，偶尔会「窗口可见但屏幕上什么都没有」。现在同时挂了 `ready-to-show` + `did-finish-load` + 1.2 秒兜底，三重保险。

### 4.9 形变动画

岛是一个 **SVG 路径**，不是两个 div。
外观由 `[宽, 高, 间隙, 左瓣宽, 圆角]` 五个弹簧值算出：间隙为 0 时是一个完整形状；间隙打开时，两瓣的**内侧圆角随间隙一起长出来**，所以单胶囊是「真的裂开成两个」而不是两块滑开。

圆角也参与动画：矮的形态（闲置/紧凑/分离/横幅）是 `h/2` 的完整胶囊，高的展开态（音乐/耳机/计时器/时钟面板）收成 `0.3h` 的圆角矩形 —— 苹果的展开态就是圆角矩形，不是长条药丸。

内容用另一套坐标：外壳按设备像素动，内容按**岛点**排版再整体 `scale(var(--k))`，所以字号/封面/间距永远等比。
每个瓣的内容**按最终宽度排版好**，只是被生长的外壳「揭开」—— 这就是中途绝不拉伸的原因（苹果就是这么做的）。

弹簧：外壳 ζ≈0.70（一次干净利落的过冲），内容 ζ≈0.85（几乎不过冲），小控件 ζ≈0.55（更弹）。内容比外壳晚 55ms 淡入。

---

## 5. 已知限制

* **勿扰模式只能看不能切** —— 上面 4.3 说了原因，这是 Windows 的限制，不是实现偷懒。
* **耳机电量取决于耳机**：支持标准 GATT 电池服务的（大部分近几年的 TWS）能读；纯经典蓝牙且不开放 GATT 的老设备读不到，会显示「—」。
* **需要 .NET 10 运行时**（桥是框架依赖发布）。要免安装运行时就把 `IslandBridge.csproj` 改成 `<SelfContained>true</SelfContained>` 重新 publish，体积会大几十 MB。
* **桥是按 Windows 11 24H2 (26100) 投影编译的**，因为读勿扰状态需要 `FocusSessionManager`。更老的系统跑不起来（或者要降 TFM 并放弃勿扰）。
* 同时跑别的灵动岛（比如 eIsland / WinIslands）会两个都贴在顶部重叠。
* 计时器倒计时在两次桥轮询之间由渲染进程本地推算，误差在 1 秒内。

---

## 6. 自检与排错

托盘右键 → **运行诊断**，会弹出面板显示桥是否在跑、勿扰真实状态、蓝牙设备与电量、当前媒体，以及最近 40 行桥日志。

命令行一次性自检：

```powershell
.\resources\bridge\IslandBridge.exe --selftest
```

输出一份 JSON，包含系统版本、媒体会话、蓝牙设备+电量、音频端点、电源、以及所有勿扰相关的 CloudStore 槽位及其解析结果。

窗口位置/可见性问题看 `%APPDATA%\dynamic-island\window-debug.log`。
渲染进程内部状态可以通过 `window.__islandDebug` 查看（配合 `node scripts/devtools.mjs eval "JSON.stringify(window.__islandDebug)"`）。

`scripts/devtools.mjs` 是个零依赖的 CDP 小工具（Node 22+ 自带 WebSocket），可以 `eval` / `dump` DOM / `rect` / `shot` 截图，调试透明窗口很好用。

---

## 7. 许可

源代码以 **MIT** 发布，见 [LICENSE](LICENSE)。

随包分发的第三方资源（品牌标志、依赖）与**商标说明**见 [NOTICE.md](NOTICE.md)，简单说：

* 品牌标志取自 [Simple Icons](https://simpleicons.org)（**CC0**，可自由使用），但**品牌名和标志本身是各家的商标** —— 本项目只在「识别你连的设备」这个描述性用途下展示。
* **「Dynamic Island」「灵动岛」是 Apple 的商标。** 本项目是面向 Windows 的独立第三方实现，**与 Apple 无任何关联**，名称仅用于描述这套交互形态。

> 想换成别的许可（比如 Apache-2.0）只需替换 `LICENSE` 文件并在 `package.json` 里改 `"license"` 字段。所有依赖都是 MIT/Apache-2.0，没有 copyleft 限制。
