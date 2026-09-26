# NOTICE

本项目的**源代码**以 [MIT](LICENSE) 许可发布。下面是随包分发的第三方内容，以及商标方面的说明。

## 第三方资源

| 内容 | 位置 | 许可 |
| --- | --- | --- |
| 品牌方形标志（49 个 SVG） | `src/renderer/src/assets/brands/` | 取自 [Simple Icons](https://simpleicons.org)，**CC0 1.0 Universal**（公有领域奉献） |
| 运行时依赖 | `package.json` | Electron / React / Framer Motion / Vite / electron-vite — 全部 **MIT** |
| 构建期依赖 | `package.json` | TypeScript — **Apache-2.0**（仅构建期，不进产物） |
| .NET 系统桥 | `native/IslandBridge/` | 使用 `Microsoft.Windows.SDK.NET`（**MIT**） |

Simple Icons 的**图标文件本身**是 CC0，可以自由复制、修改、商用，无需署名。
`npm run brands:sync` 会从 `simple-icons` 包重新提取这些文件。

## 商标声明

**品牌标志与品牌名称是其各自所有者的商标**，本项目仅在「识别你连接的设备」这一描述性用途下展示它们。CC0 只覆盖 Simple Icons 对图标文件的著作权，**不授予任何商标权**，也不代表这些品牌与本项目有任何关联、赞助或背书。

涉及的商标包括但不限于：Xiaomi / Redmi、DJI、Apple、Beats、Sony、Samsung、JBL、Bose、Sennheiser、Huawei、HONOR、OPPO、vivo、OnePlus、Google、realme、Soundcore / Anker、Edifier、Baseus、Marshall、Skullcandy、AKG、Nothing、Logitech、Jabra、Philips、QCY、Audio-Technica、Denon、Sonos、Razer、HyperX、Corsair、SteelSeries 等。

**「Dynamic Island」与「灵动岛」是 Apple Inc. 的商标。** 本项目是一个面向 Windows 的、独立的第三方复刻实现，**与 Apple 没有任何关系**，也未获得其授权、赞助或认可。名称中的「Dynamic Island」仅用于描述这套交互形态。

如需以商业产品形式分发，建议：

1. 保留本文件与 `LICENSE`；
2. 不要把品牌标志用作你自己产品的图标或宣传素材；
3. 在显著位置保留「非官方、与 Apple 无关」的说明。
