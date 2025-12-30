---@diagnostic disable: inject-field
---if lazyvim_docs then
---  -- Enable this option to avoid conflicts with Prettier.
---  vim.g.lazyvim_prettier_needs_config = true
---end

-- https://biomejs.dev/internals/language-support/
local supported = {
  "astro",
  "css",
  "graphql",
  -- "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  -- "markdown",
  "svelte",
  "typescript",
  "typescriptreact",
  "vue",
  -- "yaml",
}

-- local formatters_by_ft = {
--   lua = { "stylua" },
--   ["javascript"] = { "biome-check" },
--   ["javascriptreact"] = { "biome-check" },
--   ["typescript"] = { "biome-check" },
--   ["typescriptreact"] = { "biome-check" },
--   ["json"] = { "biome-check" },
--   ["css"] = { "biome-check" },
-- }

return {
  "stevearc/conform.nvim",
  optional = true,
  ---@param opts ConformOpts
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    for _, ft in ipairs(supported) do
      opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
      table.insert(opts.formatters_by_ft[ft], "biome-check")
    end

    opts.formatters = opts.formatters or {}
    opts.formatters.biome = {
      require_cwd = true,
    }
    opts.formatters["biome-check"] = {
      require_cwd = true,
    }
  end,
}
