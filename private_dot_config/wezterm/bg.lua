local wezterm = require("wezterm")
local bg = {
	current_idx = 1,
	-- dir = "",
	files = {},
}

local dimmer = { brightness = 0.04 }

local next = next
math.randomseed(os.time())
math.random()
math.random()
math.random()

function bg.set_files(directory)
	bg.files = wezterm.read_dir(directory)
	wezterm.GLOBAL.background = bg.files[1]
	wezterm.GLOBAL.bg_dir = directory
	-- wezterm.reload_configuration()
end

function bg.reset(window)
	local overrides = window:get_config_overrides() or {}
	overrides.background = nil
	wezterm.GLOBAL.background = nil
	-- wezterm.GLOBAL.bg_dir = nil

	window:set_config_overrides(overrides)
end

local function set_opt(window)
	local overrides = window:get_config_overrides() or {}
	overrides.background = {
		{
			source = {
				File = wezterm.GLOBAL.background,
			},
			hsb = dimmer,
			repeat_x = "Mirror",
			repeat_y = "NoRepeat",
			width = "1050",
			height = "1480",
			vertical_align = "Middle",
		},
	}

	window:set_config_overrides(overrides)
end

function bg.choices(window, pane)
	local choices = {}
	local type = ""

	window:perform_action(
		wezterm.action.InputSelector({
			action = wezterm.action_callback(function(win, _, id, label)
				if not id and not label then
					wezterm.log_info("Cancelled")
				else
					wezterm.log_info("Selected " .. label)
					type = id
					if type == "files" then
						for idx, file in ipairs(bg.files) do
							local name = file:match("([^/]+)$")
							table.insert(choices, {
								id = tostring(idx),
								label = name,
							})
						end

						win:perform_action(
							wezterm.action.InputSelector({
								action = wezterm.action_callback(function(_, _, file_id, file_label)
									if not file_id and not file_label then
										wezterm.log_info("Cancelled")
									else
										wezterm.log_info("Selected " .. file_label)
										local file = wezterm.GLOBAL.bg_dir .. "/" .. file_label
										local overrides = win:get_config_overrides() or {}
										overrides.background = {
											{
												source = {
													File = file,
												},
												hsb = dimmer,
												repeat_x = "Mirror",
												repeat_y = "NoRepeat",
												width = "1050",
												height = "1480",
												vertical_align = "Middle",
												--attachment = { Parallax = 0.3 },
											},
										}

										win:set_config_overrides(overrides)
									end
								end),
								fuzzy = true,
								title = "Select image",
								choices = choices,
							}),
							pane
						)
					else
						for idx, dir in ipairs(wezterm.read_dir("/home/sebastian/Pictures/")) do
							table.insert(choices, {
								id = tostring(idx),
								label = dir,
							})
						end

						win:perform_action(
							wezterm.action.InputSelector({
								action = wezterm.action_callback(function(_, _, dir_id, dir_label)
									if not dir_id and not dir_label then
										wezterm.log_info("Cancelled")
									else
										wezterm.log_info("Selected " .. dir_label)
										bg.current_idx = 1
										bg.set_files(dir_label)
									end
								end),
								fuzzy = true,
								title = "Select directory",
								choices = choices,
							}),
							pane
						)
					end
				end
			end),
			title = "Select type",
			choices = {
				{
					id = "files",
					label = "Files",
				},
				{
					id = "dirs",
					label = "Directories",
				},
			},
		}),
		pane
	)
end

function bg.random(window)
	bg.current_idx = math.random(#bg.files)
	wezterm.GLOBAL.background = bg.files[bg.current_idx]

	if window ~= nil then
		set_opt(window)
	end
end

function bg.cycle_forward(window)
	if wezterm.GLOBAL.bg_dir == nil or next(bg.files) == nil then
		return
	end

	if bg.current_idx == #bg.files then
		bg.current_idx = 1
	else
		bg.current_idx = bg.current_idx + 1
	end

	wezterm.GLOBAL.background = bg.files[bg.current_idx]
	set_opt(window)
end

function bg.cycle_back(window)
	if wezterm.GLOBAL.bg_dir == nil or next(bg.files) == nil then
		return
	end

	if bg.current_idx == 1 then
		bg.current_idx = #bg.files
	else
		bg.current_idx = bg.current_idx - 1
	end

	wezterm.GLOBAL.background = bg.files[bg.current_idx]
	set_opt(window)
end

return bg
