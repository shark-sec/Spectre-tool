<div align="center">

# SPECTRE | Enterprise API Leak Detector

[![Roblox Studio](https://img.shields.io/badge/Roblox%20Studio-Plugin-blue?style=for-the-badge&logo=roblox)](https://roblox.com)
[![Security](https://img.shields.io/badge/Security-Static%20Analysis-red?style=for-the-badge&logo=hackerone)](https://hackerone.com)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge)](https://github.com/shark-sec)

*Advanced static analysis utility engineered for Roblox Studio to parse `LuaSourceContainers` and eradicate hardcoded credentials before deployment.*

</div>

---

## ⚡ The Origin Story

During security assessments and environment audits, a recurring vector of compromise kept surfacing: **accidental credential exposure**. Developers often hardcode production Discord Webhooks, administrative API keys, authentication tokens, and client secrets directly into scripts during fast-paced prototyping, forgetting to strip them out before publishing or opening team-create sessions to external contractors.

**Spectre** was engineered by **shark7_7** to solve this exact vulnerability class. Instead of relying on manual code reviews—which are prone to human error and blind spots across thousands of hierarchical nodes—Spectre automates the discovery pipeline with enterprise-grade precision, scanning the entire DataModel instance tree in seconds.

---

## 🛡️ What Problem Does It Solve?

Hardcoding secrets in client-server architectures introduces catastrophic attack surfaces:
* **Discord Webhook Abuse:** Attackers scrape embedded webhooks to spam malicious payloads, flood community servers, or hijack logging channels.
* **API & Token Compromise:** Exposed tokens grant unauthorized access to external backend systems, database endpoints, and third-party APIs.
* **Privilege Escalation Vectors:** Client-side scripts containing sensitive keys allow exploiters to impersonate backend systems or perform unauthorized administrative actions.

Spectre acts as an automated gatekeeper, executing deep-pattern regex scanning across every script container (`Script`, `LocalScript`, `ModuleScript`) to flag threats instantly.

---

## 🚀 Why Use Spectre?

* **Zero-Configuration Speed:** Instantly aggregates all nodes across `Workspace`, `ReplicatedStorage`, `ServerScriptService`, and other core services with a single click.
* **Precise Threat Classification:** Automatically categorizes violations into distinct vectors:
  * 🔴 **Discord Webhooks**
  * 🔑 **API Keys**
  * 🎫 **Access Tokens**
  * 🔒 **Client Secrets**
* **Instant Navigation (`Inspect Source`):** Clicking a threat card automatically focuses the asset in the explorer and opens the source code directly in your script editor.
* **Modern Developer Experience (UI/UX):** Built with custom theme elements, fluid tweens, progress tracking, and non-blocking background task scheduling (`task.spawn`) to prevent studio freezing.

---

## 🛠️ Detection Engine Architecture

Spectre evaluates code against robust regular expression signatures optimized for Lua source structures:

| Threat Type | Pattern Matcher Logic |
| :--- | :--- |
| **Discord Webhook** | `discord%.com/api/webhooks/%d+/[%w%-_]+` |
| **API Key** | `api_key%s*=%s*['\\"][%w%-_]+['\\"]` |
| **Access Token** | `token%s*=%s*['\\"][%w%-_]+['\\"]` |
| **Client Secret** | `secret%s*=%s*['\\"][%w%-_]+['\\"]` |

---

## 📦 Installation & Setup

### Option 1: Quick Install (Recommended)
1. Download the latest `.rbxmx` or `.rbxm` build from the [Releases](../../releases) tab.
2. Drop the file directly into your Roblox Studio local plugins directory:
   * **Windows:** `%localappdata%\Roblox\Plugins`
   * **Mac:** `~/Documents/Roblox/Plugins`
3. Restart Roblox Studio. The **Spectre Security Suite** toolbar will appear automatically.

### Option 2: Source Installation
1. Clone the repository or copy the raw script contents from `main.lua`.
2. Create a new `Script` in your `ServerScriptService`.
3. Right-click the script and select **Save as Local Plugin...**.

---

## ⚙️ Usage Guide

1. Open **Roblox Studio** and load your place file.
2. Navigate to the **Plugins** tab on the top ribbon.
3. Click the **Spectre Scanner** icon to open the security audit widget.
4. Click **INITIATE SYSTEM SCAN**.
5. Review real-time progress as Spectre analyzes your `LuaSourceContainers`.
6. Inspect and remediate any flagged vulnerabilities using the direct jump buttons.

---

## 👨‍💻 Author

Engineered with precision by **shark7_7**.
* GitHub: [@shark-sec](https://github.com/shark-sec)
