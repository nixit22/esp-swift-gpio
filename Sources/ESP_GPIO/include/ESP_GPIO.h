
/*
 * Copyright (c) 2026 Nicolas Christe
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <driver/gpio.h>
#include <swift_support.h>


#ifdef __cplusplus
extern "C" {
#endif

// Define gpio_hys_ctrl_mode_t if not available on this SoC
#if !SOC_GPIO_SUPPORT_PIN_HYS_FILTER
typedef int gpio_hys_ctrl_mode_t;
#define GPIO_HYS_SOFT_DISABLE 0
#endif


/// Swift function to wrap C with SOC optional compilation flags.
///
/// @param pin_bit_mask Bit mask of pins to configure (use `1ULL << pin`).
/// @param mode GPIO mode (e.g. `GPIO_MODE_INPUT`, `GPIO_MODE_OUTPUT`).
/// @param pull_up_en Enable internal pull-up (gpio_pullup_t).
/// @param pull_down_en Enable internal pull-down (gpio_pulldown_t).
/// @param intr_type Interrupt type (e.g. `GPIO_INTR_DISABLE`).
/// @param hys_ctrl_mode Hysteresis control mode (SOC-specific). Pass 0 if unavailable.
/// @return A populated `gpio_config_t` structure.
SWIFT_NAME("gpio_config_t(pin_bit_mask:mode:pull_up_en:pull_down_en:intr_type:hys_ctrl_mode:)")
gpio_config_t gpio_config_create(
    uint64_t pin_bit_mask,
    gpio_mode_t mode,
    gpio_pullup_t pull_up_en,
    gpio_pulldown_t pull_down_en,
    gpio_int_type_t intr_type,
    gpio_hys_ctrl_mode_t hys_ctrl_mode);

#ifdef __cplusplus
}
#endif