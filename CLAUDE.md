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

ISR support (wired up via `SwiftPlatform.IsrHandler`):
```swift
try Gpio.installIsrService()      // once per process, before any setIsrHandler call
try gpio.setIsrHandler(handler)   // installs IsrHandler on this pin
try gpio.removeIsrHandler()
Gpio.uninstallIsrService()        // once per process
```
`installIsrService`/`uninstallIsrService` are `static` — process-wide, not tied to a pin.
`setIsrHandler` (`gpio_isr_handler_add`) fails with `ESP_ERR_INVALID_STATE` if the service isn't
installed yet, so ordering matters.

Sleep wakeup support:
```swift
try gpio.enableWakeup(intrType: GPIO_INTR_LOW_LEVEL)   // level-triggered only, active pin
try gpio.disableWakeup()
```
This only arms the pin itself. The sleep subsystem as a whole still needs
`esp_sleep_enable_gpio_wakeup()` (light sleep) called once by the app — not wrapped here, it's
not a per-pin call and lives outside `esp_driver_gpio`; reachable directly the same
`@_exported`-`ESP_GPIO` way as `gpio_install_isr_service` above.

## Non-obvious patterns

**`gpio_config_t` initializer** — `gpio.h` provides `gpio_config_create()` with `SWIFT_NAME(...)` (from `esp-swift-support`) to work around `gpio_hys_ctrl_mode_t` being absent on some SoCs. The C wrapper conditionally defines the type and `GPIO_HYS_SOFT_DISABLE` so `GPIO.swift` can always use the same struct initializer.

**`@_exported import ESP_GPIO`** — re-exports the C module to callers of `SwiftGPIO`, so consumers get `gpio_num_t`, `GPIO_NUM_*`, `GPIO_MODE_*` etc. without importing `ESP_GPIO` separately.

**`setIsrHandler` / `removeIsrHandler` install/remove a handler for one already-configured pin only** — they don't touch the ISR service itself; that's `Gpio.installIsrService()` / `Gpio.uninstallIsrService()`, called once by the app, not per-pin/per-component.
