# SwiftGPIO

Swift GPIO driver wrapping ESP-IDF's `esp_driver_gpio`. Exposes `Gpio`, a value type for configuring pins as input/output, driving output levels, and reading input state. Swift module name: **`GPIO`**.

Depends on: `SwiftPlatform`, `SwiftSupport`, `esp_driver_gpio`.

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
