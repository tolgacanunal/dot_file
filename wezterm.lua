local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"
config.window_decorations = "RESIZE"
config.font = wezterm.font("Jetbrains Mono")
config.audible_bell = "Disabled"

return config
