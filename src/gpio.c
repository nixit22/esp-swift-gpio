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

#include "gpio.h"

gpio_config_t gpio_config_create(
    uint64_t pin_bit_mask,
    gpio_mode_t mode,
    gpio_pullup_t pull_up_en,
    gpio_pulldown_t pull_down_en,
    gpio_int_type_t intr_type,
    gpio_hys_ctrl_mode_t hys_ctrl_mode
) {
    gpio_config_t config = {
        .pin_bit_mask = pin_bit_mask,
        .mode = mode,
        .pull_up_en = pull_up_en,
        .pull_down_en = pull_down_en,
        .intr_type = intr_type,
#if SOC_GPIO_SUPPORT_PIN_HYS_FILTER
        .hys_ctrl_mode = hys_ctrl_mode  // Only set if field exists
#endif
    };
    return config;
}