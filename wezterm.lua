local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"
config.window_decorations = "RESIZE"
config.font = wezterm.font("JetBrainsMonoNL Nerd Font")
config.audible_bell = "Disabled"

return config
