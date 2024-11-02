local wezterm = require("wezterm")
local sessionizer = require("sessionizer")
local session_manager = require("session-manager")
-- local bg = require("bg")

local config = wezterm.config_builder()

local act = wezterm.action

-- local opacity = 0.75
-- local transparent_bg = "rgba(22, 24, 26, " .. opacity .. ")"

-- config.colors = require("cyberdream")

-- config.window_background_opacity = opacity
-- config.window_decorations = "RESIZE"
-- config.force_reverse_video_cursor = true
-- config.colors.tab_bar = {
-- 	background = transparent_bg,
-- 	new_tab = { fg_color = config.colors.background, bg_color = config.colors.brights[6] },
-- 	new_tab_hover = { fg_color = config.colors.background, bg_color = config.colors.foreground },
-- }

-- wezterm.on("format-tab-title", function(tab, _, _, _, hover)
-- 	local background = config.colors.brights[1]
-- 	local foreground = config.colors.foreground
--
-- 	if tab.is_active then
-- 		background = config.colors.brights[7]
-- 		foreground = config.colors.background
-- 	elseif hover then
-- 		background = config.colors.brights[8]
-- 		foreground = config.colors.background
-- 	end
--
-- 	local title = tostring(tab.tab_index + 1)
-- 	return {
-- 		{ Foreground = { Color = background } },
-- 		{ Text = "█" },
-- 		{ Background = { Color = background } },
-- 		{ Foreground = { Color = foreground } },
-- 		{ Text = title },
-- 		{ Foreground = { Color = background } },
-- 		{ Text = "█" },
-- 	}
-- end)

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local edge_background = "#0b0022"
	local background = "#1b1032"
	local foreground = "#808080"

	if tab.is_active then
		background = "#2b2042"
		foreground = "#c0c0c0"
	elseif hover then
		background = "#3b3052"
		foreground = "#909090"
	end

	local edge_foreground = background

	local title = tab_title(tab)

	-- ensure that the titles fit in the available space,
	-- and that we have room for the edges.
	title = wezterm.truncate_right(title, max_width - 2)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

config.ssh_domains = {
	{
		name = "mac",
		remote_address = "192.168.100.115",
		username = "sebastian",
	},
}
-- config.font_size = 10
config.front_end = "WebGpu"
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
-- config.tab_and_split_indices_are_zero_based = true

config.leader = { key = "VoidSymbol", mods = "" }
config.keys = {
	{
		key = "0",
		mods = "ALT",
		action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},
	{ key = "f", mods = "LEADER", action = wezterm.action_callback(sessionizer.toggle) },
	{ key = "n", mods = "ALT", action = act.SwitchWorkspaceRelative(1) },
	{ key = "p", mods = "ALT", action = act.SwitchWorkspaceRelative(-1) },
	{
		key = "t",
		mods = "ALT",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "w",
		mods = "ALT",
		action = act.CloseCurrentTab({ confirm = true }),
	},
	{
		key = "{",
		mods = "SHIFT|ALT",
		action = act.MoveTabRelative(-1),
	},
	{
		key = "}",
		mods = "SHIFT|ALT",
		action = act.MoveTabRelative(1),
	},
	{
		key = "h",
		mods = "ALT",
		action = act.SplitPane({
			direction = "Right",
			-- command = { args = "" },
		}),
	},
	{
		key = "v",
		mods = "ALT",
		action = act.SplitPane({
			direction = "Down",
		}),
	},
	{
		key = "w",
		mods = "CTRL",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "z",
		mods = "ALT",
		action = act.TogglePaneZoomState,
	},
	{ key = "8", mods = "CTRL", action = act.PaneSelect },
	{
		key = "0",
		mods = "CTRL",
		action = act.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	{
		key = "b",
		mods = "CTRL",
		action = act.RotatePanes("CounterClockwise"),
	},
	{ key = "n", mods = "CTRL", action = act.RotatePanes("Clockwise") },
	{ key = "s", mods = "LEADER", action = wezterm.action({ EmitEvent = "save_session" }) },
	-- { key = "l", mods = "LEADER", action = wezterm.action({ EmitEvent = "load_session" }) },
	{ key = "r", mods = "LEADER", action = wezterm.action({ EmitEvent = "restore_session" }) },

	-- { key = "n", mods = "LEADER", action = wezterm.action_callback(bg.cycle_forward) },
	-- { key = "p", mods = "LEADER", action = wezterm.action_callback(bg.cycle_back) },
	-- { key = "c", mods = "LEADER", action = wezterm.action_callback(bg.choices) },
	-- { key = "d", mods = "LEADER", action = wezterm.action_callback(bg.reset) },
	{ key = "r", mods = "ALT", action = act.ReloadConfiguration },
	{ key = "l", mods = "CTRL|SHIFT", action = act.ShowDebugOverlay },
}

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "ALT",
		action = act.ActivateTab(i - 1),
	})
end

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL|ALT",
		action = act.MoveTab(i - 1),
	})
end

wezterm.on("save_session", function(window)
	session_manager.save_state(window)
end)
-- wezterm.on("load_session", function(window)
-- 	session_manager.load_state(window)
-- end)
wezterm.on("restore_session", function(window)
	session_manager.restore_state(window)
end)

-- wezterm.on("user-var-changed", function(window, pane, name, value)
-- 	local overrides = window:get_config_overrides() or {}
-- 	if name == "ZEN_MODE" then
-- 		local incremental = value:find("+")
-- 		local number_value = tonumber(value)
-- 		if incremental ~= nil then
-- 			while number_value > 0 do
-- 				window:perform_action(wezterm.action.IncreaseFontSize, pane)
-- 				number_value = number_value - 1
-- 			end
-- 			overrides.enable_tab_bar = false
-- 		elseif number_value < 0 then
-- 			window:perform_action(wezterm.action.ResetFontSize, pane)
-- 			overrides.font_size = nil
-- 			overrides.enable_tab_bar = true
-- 		else
-- 			overrides.font_size = number_value
-- 			overrides.enable_tab_bar = false
-- 		end
-- 	end
-- 	window:set_config_overrides(overrides)
-- end)

return config
