-- ===========================================================================
-- 🌟 init.lua - Configuração COMPLETA e Modular do Neovim (Em um Único Arquivo)
-- ===========================================================================

-- Declarações Locais (Para acesso rápido e legibilidade)
local opt = vim.opt
local wo = vim.wo
local api = vim.api
local keymap = vim.keymap
local diagnostic = vim.diagnostic
local lsp_util = vim.lsp.util

-- REMOVIDAS AS LINHAS 'local lspconfig = require("lspconfig")' E 'local cmp = require("cmp")'
-- ELAS SERÃO RECOLOCADAS MAIS ABAIXO, APÓS A INSTALAÇÃO DOS PLUGINS PELO LAZY.NVIM.

-- ===========================================================================
-- 0. CONFIGURAÇÃO DE CODIFICAÇÃO E ENTRADA/SAÍDA
-- ===========================================================================
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.fileformat = "unix"
opt.fileformats = "unix,dos,mac"

-- ===========================================================================
-- 1. CONFIGURAÇÕES BÁSICAS DO VIM/NEOVIM (Options)
-- ===========================================================================
-- Indentação: 4 espaços
opt.shiftwidth = 4
opt.expandtab = true
opt.softtabstop = 4
opt.copyindent = true
opt.autoindent = true
opt.tabstop = 4
-- UI e Aparência
wo.number = true
wo.relativenumber = true
opt.mouse = "a"
opt.termguicolors = true
opt.fillchars = { eob = " " }
opt.pumheight = 10
opt.completeopt = { 'menu', 'menuone', 'noselect' }
-- Outros
opt.swapfile = false
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true

-- ===========================================================================
-- 2. SETUP DO LAZY.NVIM (Gerenciador de Plugins)
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
opt.rtp:prepend(lazypath)

-- ===========================================================================
-- 3. DEFINIÇÃO E CONFIGURAÇÃO DOS PLUGINS
-- ===========================================================================
local plugins = {
    -- TEMA: GitHub Dark
    {
        'projekt0n/github-nvim-theme',
        lazy = false,
        priority = 1000,
    },

    -- nvim-web-devicons
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            local devicons = require('nvim-web-devicons')
            devicons.setup({
                color_icons = true,
                folder_icon = '>',
                default_icon = { icon = "#", color = "#6D7079", name = "Default" },
            })
            -- Força cor vermelha para pastas no Telescope (Ajuste fino)
            api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    api.nvim_set_hl(0, 'DevIconFolder', { fg = '#E06C75' })
                end
            })
        end
    },

    -- Fechamento Automático de Pares (nvim-autopairs)
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup {}
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end
    },

    -- LSP / COMPLEÇÃO / FORMATTER / TREESITTER
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim",          cmd = "Mason" },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/nvim-cmp",                 dependencies = { "hrsh7th/cmp-nvim-lsp", "windwp/nvim-autopairs" } },
    { "stevearc/conform.nvim",            event = "BufWritePre" },
    { "nvim-treesitter/nvim-treesitter",  build = ":TSUpdate" },
    { "nvim-lua/plenary.nvim" }, -- Dependência do Telescope e outros

    -- TELESCOPE.NVIM - O Fuzzy Finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")
            local telescope_builtin = require("telescope.builtin")

            -- Setup do Telescope (Layouts e Estilo)
            telescope.setup({
                defaults = {
                    layout_strategy = "flex",
                    sorting_strategy = "ascending",
                    layout_config = { prompt_position = "top" },
                    winblend = 5,
                    mappings = {
                        i = {
                            ['<C-j>'] = actions.move_selection_next,
                            ['<C-k>'] = actions.move_selection_previous,
                            ['<C-u>'] = actions.preview_scrolling_up,
                            ['<C-d>'] = actions.preview_scrolling_down,
                        },
                    },
                },
            })

            -- Carregar a extensão do File Browser
            require("telescope").load_extension("file_browser")

            -- Mapeamentos de atalho
            keymap.set("n", "<leader>n", function()
                require("telescope").extensions.file_browser.file_browser()
            end, { desc = "Telescope: File Browser (Estrutura de Pastas)" })

            keymap.set("n", "<leader>t", telescope_builtin.builtin, { desc = "Telescope: Menu Principal" })
            keymap.set("n", "<leader>ff", telescope_builtin.find_files, { desc = "Telescope: Find Files" })
            keymap.set("n", "<leader>fg", telescope_builtin.live_grep, { desc = "Telescope: Live Grep" })
            keymap.set("n", "<leader>fb", telescope_builtin.buffers, { desc = "Telescope: Find Buffers" })
            keymap.set("n", "<leader>fh", telescope_builtin.help_tags, { desc = "Telescope: Help Tags" })
        end,
    },

    -- DAP (Debug)
    { "mfussenegger/nvim-dap" },
    { "leoluz/nvim-dap-go" },

    -- TODO Comments
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            keywords = {
                FIX = { icon = "F ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                TODO = { icon = "T ", color = "info" },
                HACK = { icon = "H ", color = "warning" },
                WARN = { icon = "W ", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = "P ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = "N ", color = "hint", alt = { "INFO" } },
                TEST = { icon = "E ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
            },
        },
    },
}

-- 🚨 ESTE COMANDO EXECUTA O LAZY.NVIM E CARREGA OS PLUGINS NO LUA PATH 🚨
require("lazy").setup(plugins)

-- [ATIVANDO O TEMA]
vim.cmd('colorscheme github_dark')

-- ===========================================================================
-- 5. CONFIGURAÇÃO DE LINGUAGENS (LSP E AUTOCOMPLETAR)
-- ===========================================================================

-- 🌟 REINSERINDO AS CHAMADAS REQUIRE AGORA QUE OS PLUGINS ESTÃO DISPONÍVEIS 🌟
local lspconfig = require("lspconfig")
local cmp = require("cmp")

-- 5.1. Setup do CMP (Autocompletar)
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
    local lsp_buf = vim.lsp.buf

    -- Keymaps LSP
    keymap.set("n", "gd", lsp_buf.definition, opts)
    keymap.set("n", "K", lsp_buf.hover, opts)
    keymap.set("n", "<leader>rn", lsp_buf.rename, opts)
    keymap.set("n", "<leader>ca", lsp_buf.code_action, opts)
    keymap.set("n", "gr", lsp_buf.references, opts)

    -- Mapeamento para formatação manual (usando conform/lsp)
    keymap.set("n", "<leader>fm", function() require("conform").format() end,
        { desc = "Manual Format (Conform/LSP)", buffer = bufnr, silent = true })

    -- Formatação automática APENAS para Go (usando gopls)
    if client.name == "gopls" then
        api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                lsp_buf.format({ async = false })
            end,
        })
    end
end

-- 5.3. Instalação e Configuração dos Language Servers (Mason + LSPs)
local ensure_installed = { "pyright", "gopls", "sqlls", "terraformls", "lua_ls" }
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
                    gopls = { gofumpt = false, staticcheck = true },
                },
            })
        end,
    }
})

-- ===========================================================================
-- 4. SETUP DO FORMATTER (CONFORM.NVIM)
-- ===========================================================================
-- Movi a Seção 4 para antes da Seção 5 para manter as dependências de LSP/CMP juntas.
require("conform").setup({
    format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback", -- Permite que o LSP lide com a formatação (ex: gopls)
        async = true,
    },
    formatters_by_ft = {
        python = { "black" },
        -- Go é formatado pelo gopls (no on_attach)
        lua = { "stylua" },
    },
})

-- ===========================================================================
-- 6. AJUSTES FINOS E PLUGINS AUXILIARES
-- ===========================================================================

-- TRECHO CRUCIAL: Força 4 espaços e expandtab para arquivos Go.
api.nvim_create_autocmd("FileType", {
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
-- Treesitter setup (expandido para mais linguagens)
require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "go",
        "python",
        "lua",
        "hcl",
        "sql",
        "bash",     -- Scripts e DevOps
        "json",     -- Configs e APIs
        "yaml",     -- Configs e Kubernetes
        "markdown", -- Documentação e Quarto
    },
    highlight = { enable = true },
    indent = { enable = true },
    parser_configs = {
        hcl = { filetype = { "hcl", "terraform" } },
    },
})


-- Debug adapter protocol (DAP) para Go
require("dap-go").setup()

-- Configuração do UI de Diagnósticos e Popups
diagnostic.config({
    virtual_text = true,
    float = { border = "rounded" },
})

-- Adiciona bordas arredondadas aos popups do LSP (hover, etc.)
local orig_util_open_floating_preview = lsp_util.open_floating_preview
function lsp_util.open_floating_preview(contents, syntax, opts)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig_util_open_floating_preview(contents, syntax, opts)
end

-- ===========================================================================
-- 7. NORMALIZAÇÃO AUTOMÁTICA DE FIM DE LINHA (REMOVE ^M EM ARQUIVOS)
-- ===========================================================================

-- Converte automaticamente CRLF → LF ao abrir arquivos Terraform
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = { "*.tf", "*.tfvars", "*.hcl", "*.sh", "*.yaml", "*.yml", "*.py", ".sql", ".go" },
    callback = function()
        -- Força formato Unix
        vim.opt_local.fileformat = "unix"

        -- Remove quaisquer ^M que estejam no texto
        vim.cmd([[%s/\r//ge]])
    end,
    desc = "Remove ^M e converte arquivos Terraform para formato Unix (LF)",
})
