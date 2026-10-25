# SwiftGPIO

Swift GPIO driver wrapping ESP-IDF's `esp_driver_gpio`. Exposes `Gpio`, a value type for configuring pins as input/output, driving output levels, and reading input state. Swift module name: **`GPIO`**.

Depends on: `SwiftPlatform`, `SwiftSupport`, `esp_driver_gpio`.

## Adding it to a project

This is a [SwiftPM](https://www.swift.org/package-manager/) package, built for ESP-IDF by
`swift_package()` from [esp-swift-support](https://github.com/nixit22/esp-swift-support). In your
app's `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nixit22/esp-swift-gpio.git", from: "0.1.0"),
],
targets: [
    .target(name: "App", dependencies: [.product(name: "GPIO", package: "esp-swift-gpio")]),
]
```

See esp-swift-support's README for the project setup (top-level `CMakeLists.txt`, `main`
component, Swift toolchain).

## Usage

```swift
import GPIO

let gpio = Gpio(gpioNum: GPIO_NUM_2)
try gpio.setOutput()
try gpio.set(level: true)  // drive high
try gpio.set(level: false) // drive low

let button = Gpio(gpioNum: GPIO_NUM_3)
try button.setInput(pullUp: GPIO_PULLUP_ENABLE, intr: GPIO_INTR_POSEDGE)
let pressed = button.getLevel()
```

See [`CLAUDE.md`](CLAUDE.md) for full API details and non-obvious patterns.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
