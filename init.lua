-- ===========================================================================
--  1. CONFIGURAÇÕES BÁSICAS DO VIM/NEOVIM
-- ===========================================================================

-- Indentação: 4 espaços (Padrão para todas as linguagens)
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.copyindent = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
-- Define a ordem de preferência para formatos de arquivo
-- O Neovim tentará detectar primeiro 'unix' (LF), depois 'dos' (CRLF) e 'mac' (CR)
vim.opt.fileformats = "unix,dos,mac"
vim.opt.fileformats = "unix,dos,mac"

-- UI e Aparência
vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.fillchars = { eob = " " }
vim.opt.pumheight = 10
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- ===========================================================================
--  2. SETUP DO LAZY.NVIM (Gerenciador de Plugins)
-- ===========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ===========================================================================
--  3. DEFINIÇÃO DOS PLUGINS
-- ===========================================================================
local plugins = {
    -- TEMA: GitHub Dark
    {
        'projekt0n/github-nvim-theme',
        lazy = false,    -- Carrega no startup
        priority = 1000, -- Certifica-se de que ele carrega primeiro
    },

    -- Nvim-web-devicons (dependência)
    {
        "nvim-tree/nvim-web-devicons",
    },

    {
        -- Plugin que fornece os ícones Material Design (V3)
        'Allianaab2m/nvim-material-icon-v3',
        lazy = false, -- Garante que o plugin esteja disponível (ou tentando estar)
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            -- CHAVE PARA CORRIGIR O AVISO: Usar pcall (protected call)
            -- para evitar que o Neovim crashe se o módulo ainda não estiver
            -- totalmente carregado no momento do startup.
            local ok, material_icon = pcall(require, 'nvim-material-icon-v3')

            if ok then
                local devicons = require('nvim-web-devicons')
                -- Sobrescreve a configuração padrão do nvim-web-devicons
                devicons.setup({
                    -- Usa o conjunto de ícones do nvim-material-icon-v3
                    override = material_icon.get_icons(),
                })
            end
        end,
    },
    -- ==================================================================

    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim",          cmd = "Mason" },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/nvim-cmp",                 dependencies = { "hrsh7th/cmp-nvim-lsp" } },
    { "stevearc/conform.nvim",            event = "BufWritePre" },
    { "nvim-treesitter/nvim-treesitter",  build = ":TSUpdate" },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            { "<C-n>", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
        },
        opts = {
            close_if_last_window = true,
            popup_border_style = "rounded",
        },
    },
    { "nvim-telescope/telescope.nvim", tag = "0.1.6", dependencies = { "nvim-lua/plenary.nvim" } },
    { "mfussenegger/nvim-dap" },
    { "leoluz/nvim-dap-go" },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            keywords = {
                FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                TODO = { icon = " ", color = "info" },
                HACK = { icon = " ", color = "warning" },
                WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
                TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
            },
        },
    },
}

require("lazy").setup(plugins)

-- [NOVO] ATIVANDO O TEMA: Deve ser chamado após o setup do Lazy.
vim.cmd('colorscheme github_dark')

-- ===========================================================================
--  4. SETUP DO FORMATTER (CONFORM.NVIM)
-- ===========================================================================
require("conform").setup({
    format_on_save = {
        timeout_ms = 500,
        -- Permite que o LSP do Go (gopls) lide com a formatação dele.
        lsp_format = "fallback",
        async = true,
    },
    formatters_by_ft = {
        python = { "black" },
        -- Go removido daqui para deixar o LSP (gopls) fazer o trabalho
        lua = { "stylua" },
    },
})

-- ===========================================================================
--  5. CONFIGURAÇÃO DE LINGUAGENS (LSP E AUTOCOMPLETAR)
-- ===========================================================================

local cmp = require("cmp")
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
    },
    capabilities = capabilities,
})

-- 5.2. Configuração Comum do LSP (on_attach)
local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, silent = true }

    -- Keymaps
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

    -- Mapeamento para formatação manual (usando conform/lsp)
    vim.keymap.set("n", "<leader>fm", function() require("conform").format() end,
        { desc = "Manual Format (Conform/LSP)" })

    -- Formatação automática APENAS para Go
    if client.name == "gopls" then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                -- Usa o LSP para formatar (gopls)
                vim.lsp.buf.format({ async = false })
            end,
        })
    end
end

-- 5.3. Instalação e Configuração dos Language Servers (Mason + LSPs)

local ensure_installed = {
    "pyright",     -- Python (LSP)
    "gopls",       -- Go
    "sqlls",       -- SQL
    "terraformls", -- Terraform
    "lua_ls",      -- Lua
}

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = ensure_installed,
    handlers = {
        function(server_name)
            lspconfig[server_name].setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })
        end,

        -- CONFIGURAÇÃO ESPECÍFICA PARA GOPLS
        ["gopls"] = function()
            lspconfig.gopls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    gopls = {
                        gofumpt = false,
                        staticcheck = true,
                    },
                },
            })
        end,
    }
})

-- ===========================================================================
--  6. AJUSTES FINOS E PLUGINS AUXILIARES
-- ===========================================================================

-- TRECHO CRUCIAL: Força 4 espaços e expandtab para arquivos Go. (Correção anterior)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
    end,
    desc = "Force 4-space indentation for Go files",
})

-- Treesitter setup
require("nvim-treesitter.configs").setup({
    ensure_installed = { "go", "python", "lua", "hcl", "sql" },
    highlight = { enable = true },
    indent = { enable = true },
})

-- Debug adapter protocol (DAP) para Go
require("dap-go").setup()

-- Configuração do UI de Diagnósticos e Popups
vim.diagnostic.config({
    virtual_text = true,
    float = { border = "rounded" },
})

-- Adiciona bordas arredondadas aos popups do LSP (hover, etc.)
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig_util_open_floating_preview(contents, syntax, opts)
end

-- Telescope setup
require("telescope").setup({
    defaults = {
        layout_strategy = "flex",
        borderchars = {
            prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
            preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        sorting_strategy = "ascending",
        layout_config = {
            prompt_position = "top",
        },
        winblend = 5,
    },
})

-- Mapeamentos do Telescope
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Help Tags" })
