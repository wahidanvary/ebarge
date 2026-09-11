# Development Environment Baseline

> This document records the known working development environment for the Ebarge project.
> AI agents and developers must not upgrade or change these versions without first evaluating project compatibility and potential regression risks.

## Baseline Date

2026-08-10

## Operating System

* OS: Microsoft Windows 10 Pro 64-bit
* Version: 22H2
* Build: 10.0.19045.6456
* System locale: en-US

## Project Location

```text
D:\FlutterProjects\ebarge
```

> The local project path is machine-specific and must not be treated as a required path for other developers or CI environments.

---

# Flutter

* Channel: stable
* Flutter Version: 3.44.7
* Framework Revision: 84fc5cbb22
* Framework Date: 2026-07-17
* Flutter SDK Path: E:\sdkflutter

## Flutter Engine

* Engine Revision: 69c8c61792
* Engine Hash: 7076f47b1d1a3a0edfd8837b17dc15be6abab661

## Dart

* Dart Version: 3.12.2

## DevTools

* DevTools Version: 2.57.0

---

# Java

## Command-Line Java

* Java Version: 24.0.1
* Runtime: Java(TM) SE Runtime Environment
* JVM: Java HotSpot(TM) 64-Bit Server VM

## Flutter Android Build JDK

Flutter currently uses the JDK bundled with Android Studio:

```text
C:\Program Files\Android\Android Studio\jbr\bin\java
```

* Runtime: OpenJDK Runtime Environment
* Version: 25.0.2

> Important: Flutter Android builds do not currently use the Java version returned by the system `java -version` command. Flutter is configured to use Android Studio's bundled JBR.

---

# Android Development Environment

* Android SDK Location: D:\sdk
* ANDROID_HOME: D:\sdk
* Android SDK Version Reported by Flutter: 35.0.1
* Installed Platform Reported by Flutter: android-36
* Build Tools Version: 35.0.1
* Emulator Version: 36.1.9.0
* Android Studio bundled JDK: OpenJDK 25.0.2

## Android Licenses

Current status:

```text
Some Android licenses are not accepted.
```

Required command:

```bash
flutter doctor --android-licenses
```

> This should be resolved before defining the final clean environment baseline.

---

# Flutter Package Mirrors

Current configuration:

* Pub Mirror: https://pub.flutter-io.cn
* Flutter Storage Mirror: https://storage.flutter-io.cn

> These mirrors are part of the current development environment. Do not change them without verifying that dependency resolution and Flutter SDK downloads remain functional for this project.

---

# Git

* Git Version: 2.50.0.windows.1

Git repository status:

```text
Not initialized at the time this baseline was created.
```

---

# Development Tools

## Android Studio

* Android Studio is installed.
* Flutter currently uses the JDK bundled with Android Studio for Android builds.

## Visual Studio

* Edition: Visual Studio Community 2026
* Version: 18.8.12021.73
* Windows SDK: 10.0.26100.0

## Browsers

* Google Chrome 150.0.7871.182
* Microsoft Edge 150.0.4078.83

---

# Available Development Targets

At the time of the baseline:

* Windows Desktop
* Chrome Web
* Microsoft Edge Web

No physical Android device was reported as connected during the environment check.

---

# Flutter Doctor Baseline

Status:

```text
Doctor found issues in 1 category.
```

Issue:

* Some Android SDK licenses are not accepted.

---

# Environment Change Policy

Before changing any of the following, the developer or AI agent must first assess project compatibility:

* Flutter version
* Dart version
* Android Gradle Plugin
* Gradle version
* compileSdk / targetSdk
* Android Studio JDK
* Java configuration
* Pub mirror
* Flutter storage mirror
* Major package versions

Any intentional environment change must be documented in an Architecture Decision Record or project change log.
