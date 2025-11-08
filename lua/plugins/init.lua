return {
  "nvim-neo-tree/neo-tree.nvim", -- The plugin's name
  branch = "v3.x", -- Use the stable branch
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons", -- Highly recommended for file icons
  },

  keys = {
    {
      "<leader>e", -- The key combination to press (e.g., Space + e)
      "<cmd>Neotree toggle<cr>", -- The command to run
      desc = "Toggle Neo-tree File Explorer", -- Description for which-key
    },
  },

  -- You can also include any other setup options here (optional)
  opts = {
    -- For example, to bind Neo-tree to the current working directory
    filesystem = {
      bind_to_cwd = true,
    },
  },
}
