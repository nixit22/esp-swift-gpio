# SwiftGPIO

Swift GPIO driver wrapping `esp_driver_gpio`. Swift module name: **`GPIO`**.

Depends on: `SwiftPlatform`, `SwiftSupport`, `esp_driver_gpio`

## Files

| File | Role |
|---|---|
| `src/GPIO.swift` | `Gpio` struct — the public Swift API |
| `src/gpio.c` / `src/gpio.h` | C glue for SOC-conditional types |
| `module.modulemap` | Clang module `ESP_GPIO` — umbrella over `src/gpio.h` |

## Public API

`Gpio` is a value type (`struct`) — no ownership or lifetime management required.

```swift
let gpio = Gpio(gpioNum: GPIO_NUM_2)
try gpio.setOutput()
try gpio.set(level: true)
let high = gpio.getLevel()
try gpio.setInput(pullUp: GPIO_PULLUP_ENABLE, intr: GPIO_INTR_POSEDGE)
try gpio.reset()
```

ISR support (internal access level — wired up via `SwiftPlatform.IsrHandler`):
```swift
try gpio.setIsrHandler(handler)   // installs IsrHandler on this pin
try gpio.removeIsrHandler()
```

## Non-obvious patterns

**`gpio_config_t` initializer** — `gpio.h` provides `gpio_config_create()` with `__attribute__((swift_name(...)))` to work around `gpio_hys_ctrl_mode_t` being absent on some SoCs. The C wrapper conditionally defines the type and `GPIO_HYS_SOFT_DISABLE` so `GPIO.swift` can always use the same struct initializer.

**`@_exported import ESP_GPIO`** — re-exports the C module to callers of `SwiftGPIO`, so consumers get `gpio_num_t`, `GPIO_NUM_*`, `GPIO_MODE_*` etc. without importing `ESP_GPIO` separately.

**`setIsrHandler` / `removeIsrHandler` are `internal`**, not `public`. Callers must install the GPIO ISR service (`gpio_install_isr_service`) themselves before adding pin handlers.
