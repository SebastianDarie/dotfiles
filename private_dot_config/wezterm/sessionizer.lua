local wezterm = require("wezterm")
local act = wezterm.action

local sessionizer = {
	current_workspaces = {},
	available_workspaces = {},
}
local M = {}

local fd = "/usr/bin/fd"
local rootPath = "/home/sebastian"

M.toggle = function(window, pane)
	local projects = {}

	local success, stdout, stderr = wezterm.run_child_process({
		fd,
		"-HI",
		"-td",
		"^.git$",
		"--max-depth=4",
		"--prune",
		rootPath,
		-- add more paths here
	})

	if not success then
		wezterm.log_error("Failed to run fd: " .. stderr)
		return
	end

	local all_windows = wezterm.mux.all_windows()
	for idx, win in ipairs(all_windows) do
		local name = win:get_workspace():gsub(".*/", "")
		-- wezterm.log_info(name)
		table.insert(sessionizer.current_workspaces, { id = name })
	end

	for line in stdout:gmatch("([^\n]*)\n?") do
		local project = line:gsub("/.git/$", "")
		local label = project
		local id = project:gsub(".*/", "")
		table.insert(projects, { label = tostring(label), id = tostring(id) })
	end

	-- wezterm.log_info(#all_windows)
	-- wezterm.log_info(projects)
	-- wezterm.log_info(sessionizer.current_workspaces)

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, _, id, label)
				if not id and not label then
					wezterm.log_info("Cancelled")
				else
					wezterm.log_info("Selected " .. label)
					win:perform_action(act.SwitchToWorkspace({ name = id, spawn = { cwd = label } }), pane)
				end
			end),
			fuzzy = true,
			title = "Select project",
			choices = projects,
		}),
		pane
	)
end

return M
