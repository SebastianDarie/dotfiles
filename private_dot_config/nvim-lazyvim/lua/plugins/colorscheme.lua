return {
  -- { "EdenEast/nightfox.nvim", opts = {
  --   options = {
  --     transparent = true,
  --   },
  -- } }, -- lazy

  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "cyberdream",
      -- colorscheme = "carbonfox",
    },
  },
}
