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
    /// - Throws: `Error` if the GPIO configuration fails.
    public func setOutput() throws(Error) {
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
    /// - Throws: `Error` if the GPIO configuration fails.
    public func setInput(
        pullUp: gpio_pullup_t = GPIO_PULLUP_DISABLE,
        pulldown: gpio_pulldown_t = GPIO_PULLDOWN_DISABLE,
        intr: gpio_int_type_t = GPIO_INTR_DISABLE
    ) throws(Error) {
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
    /// - Throws: `Error` if the reset operation fails.
    public func reset() throws(Error) {
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
    /// - Throws: `Error` if setting the level fails.
    public func set(level: Bool) throws(Error) {
        try gpio_set_level(gpioNum, level ? 1 : 0)
            .throwEspError()
    }

    /// Adds an ISR handler for this GPIO pin.
    ///
    /// - Parameter handler: The ISR handler to add.
    ///
    /// - Throws: `Error` if adding the ISR handler fails.
    func setIsrHandler(_ handler: borrowing IsrHandler) throws(Error) {
        try gpio_isr_handler_add(gpioNum, handler.handler, handler.args)
            .throwEspError()
    }

    /// Removes the ISR handler for this GPIO pin.
    ///
    /// - Throws: `Error` if removing the ISR handler fails.
    func removeIsrHandler() throws(Error) {
        try gpio_isr_handler_remove(gpioNum)
            .throwEspError()
    }
}
