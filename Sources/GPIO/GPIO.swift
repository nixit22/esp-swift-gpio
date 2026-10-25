// Copyright (c) 2026 Nicolas Christe
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// A Swift wrapper class for ESP-IDF GPIO operations.
//
// This class provides an object-oriented interface to control GPIO pins on ESP32 devices.

@_exported import ESP_GPIO
import Platform

public struct Gpio {
    private let gpioNum: gpio_num_t

    /// Initializes a new GPIO instance with the specified pin number.
    ///
    /// - Parameter gpioNum: The GPIO pin number to control.
    public init(gpioNum: gpio_num_t) {
        self.gpioNum = gpioNum
    }

    /// Configure the GPIO as an output pin.
    ///
    /// - Throws: `PlatformError` if the GPIO configuration fails.
    public func setOutput() throws(PlatformError) {
        var cfg = gpio_config_t(
            pin_bit_mask: 1 << UInt64(gpioNum.rawValue),
            mode: GPIO_MODE_OUTPUT,
            pull_up_en: GPIO_PULLUP_DISABLE,
            pull_down_en: GPIO_PULLDOWN_DISABLE,
            intr_type: GPIO_INTR_DISABLE,
            hys_ctrl_mode: GPIO_HYS_SOFT_DISABLE)
        try gpio_config(&cfg)
            .throwEspError()
    }

    /// Configure the GPIO as an input pin.
    ///
    /// - Parameters:
    ///   - pullUp: pull-up configuration (default: `GPIO_PULLUP_DISABLE`).
    ///   - pulldown: pull-down configuration (default: `GPIO_PULLDOWN_DISABLE`).
    ///   - intr: interrupt type (default: `GPIO_INTR_DISABLE`).
    ///
    /// - Throws: `PlatformError` if the GPIO configuration fails.
    public func setInput(
        pullUp: gpio_pullup_t = GPIO_PULLUP_DISABLE,
        pulldown: gpio_pulldown_t = GPIO_PULLDOWN_DISABLE,
        intr: gpio_int_type_t = GPIO_INTR_DISABLE
    ) throws(PlatformError) {
        var cfg = gpio_config_t(
            pin_bit_mask: 1 << UInt64(gpioNum.rawValue),
            mode: GPIO_MODE_INPUT,
            pull_up_en: pullUp,
            pull_down_en: pulldown,
            intr_type: intr,
            hys_ctrl_mode: GPIO_HYS_SOFT_DISABLE)
        try gpio_config(&cfg)
            .throwEspError()
    }

    /// Resets the GPIO pin to its default state.
    ///
    /// - Throws: `PlatformError` if the reset operation fails.
    public func reset() throws(PlatformError) {
        try gpio_reset_pin(gpioNum)
            .throwEspError()
    }

    /// Read the current logical level of the GPIO.
    ///
    /// - Returns: `true` if the pin reads high (non-zero), `false` otherwise.
    public func getLevel() -> Bool {
        return gpio_get_level(gpioNum) != 0
    }

    /// Set the output level of the GPIO.
    ///
    /// - Parameter level: `true` to drive the pin high, `false` to drive it low.
    ///
    /// - Throws: `PlatformError` if setting the level fails.
    public func set(level: Bool) throws(PlatformError) {
        try gpio_set_level(gpioNum, level ? 1 : 0)
            .throwEspError()
    }

    /// Installs the GPIO ISR service for the current process.
    ///
    /// Process-wide, not per-pin — call this exactly once before the first `setIsrHandler` call
    /// on any pin. `gpio_isr_handler_add` (used by `setIsrHandler`) fails with
    /// `ESP_ERR_INVALID_STATE` if the service isn't installed yet, so this must run first.
    ///
    /// - Parameter intrAllocFlags: flags for `esp_intr_alloc` (e.g. `ESP_INTR_FLAG_LEVEL1`,
    ///   `ESP_INTR_FLAG_IRAM`). Pass `0` for default behavior.
    ///
    /// - Throws: `PlatformError` if installing the service fails.
    public static func installIsrService(intrAllocFlags: Int32 = 0) throws(PlatformError) {
        try gpio_install_isr_service(intrAllocFlags)
            .throwEspError()
    }

    /// Uninstalls the GPIO ISR service for the current process, freeing its resources.
    ///
    /// Process-wide, not per-pin. Removes any pin handlers still installed.
    public static func uninstallIsrService() {
        gpio_uninstall_isr_service()
    }

    /// Adds an ISR handler for this GPIO pin.
    ///
    /// The GPIO ISR service must be installed once per process (`Gpio.installIsrService()`)
    /// before calling this — not done here, since it's a one-time process-wide call, not a
    /// per-pin one.
    ///
    /// - Parameter handler: The ISR handler to add.
    ///
    /// - Throws: `PlatformError` if adding the ISR handler fails.
    public func setIsrHandler(_ handler: borrowing IsrHandler) throws(PlatformError) {
        try gpio_isr_handler_add(gpioNum, handler.handler, handler.args)
            .throwEspError()
    }

    /// Removes the ISR handler for this GPIO pin.
    ///
    /// - Throws: `PlatformError` if removing the ISR handler fails.
    public func removeIsrHandler() throws(PlatformError) {
        try gpio_isr_handler_remove(gpioNum)
            .throwEspError()
    }

    /// Enables this GPIO as a wakeup source for light/deep sleep.
    ///
    /// Light-sleep GPIO wakeup only supports level-triggered types (`GPIO_INTR_LOW_LEVEL` /
    /// `GPIO_INTR_HIGH_LEVEL`), not edge — unlike the `intr` passed to `setInput(intr:)` for a
    /// regular ISR. Caller must still call `esp_sleep_enable_gpio_wakeup()` separately to arm
    /// GPIO as a wakeup source for the sleep subsystem as a whole.
    ///
    /// - Parameter intrType: level trigger to wake on.
    ///
    /// - Throws: `PlatformError` if enabling the wakeup source fails.
    public func enableWakeup(intrType: gpio_int_type_t) throws(PlatformError) {
        try gpio_wakeup_enable(gpioNum, intrType)
            .throwEspError()
    }

    /// Disables this GPIO as a wakeup source.
    ///
    /// - Throws: `PlatformError` if disabling the wakeup source fails.
    public func disableWakeup() throws(PlatformError) {
        try gpio_wakeup_disable(gpioNum)
            .throwEspError()
    }
}
