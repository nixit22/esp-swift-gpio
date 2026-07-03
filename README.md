# SwiftGPIO

SwiftGPIO provides small, Swifty helpers around the ESP-IDF GPIO C API. It exposes a concise, type-safe interface for configuring GPIO pins, reading input levels and driving outputs from Swift.

## Features
- Configure a GPIO pin as input or output.
- Configure pull-up / pull-down and interrupt type when setting a pin as input.
- Read pin level as a `Bool`.
- Set pin output level using a `Bool`.
- Reset a pin to its default state.

## API

All APIs surface ESP-IDF errors as Swift typed throws (`throws(Error)`), and are methods on the `Gpio` struct (exported via the `GPIO` module). `Gpio` is a plain value type — no ownership or lifetime management required.

- `init(gpioNum: gpio_num_t)` — bind to a pin number.
- `setOutput() throws(Error)` — configure the pin as an output.
- `setInput(pullUp: gpio_pullup_t = GPIO_PULLUP_DISABLE, pulldown: gpio_pulldown_t = GPIO_PULLDOWN_DISABLE, intr: gpio_int_type_t = GPIO_INTR_DISABLE) throws(Error)` — configure the pin as an input with optional pull / interrupt settings.
- `getLevel() -> Bool` — return `true` when the pin reads high, `false` when low.
- `set(level: Bool) throws(Error)` — set the output level (high when `true`).
- `reset() throws(Error)` — reset the pin to its default state.

These are thin wrappers over the `gpio_config`, `gpio_get_level`, `gpio_set_level`, and `gpio_reset_pin` C functions.

## Usage examples

Basic output example:

```swift
import GPIO

let gpio = Gpio(gpioNum: GPIO_NUM_2)
try gpio.setOutput()
try gpio.set(level: true)  // drive high
try gpio.set(level: false) // drive low
```

Basic input example:

```swift
let button = Gpio(gpioNum: GPIO_NUM_3)
try button.setInput(pullUp: GPIO_PULLUP_ENABLE, intr: GPIO_INTR_POSEDGE)
let pressed = button.getLevel()
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.