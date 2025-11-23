-- ===========================================================================
-- 🌟 init.lua - Configuração COMPLETA e Modular do Neovim (v9)
-- CORREÇÃO DEFINITIVA: Pylsp bloqueado via `excluded = { "pylsp" }` no mason-lspconfig.
-- ===========================================================================

-- 0. DECLARAÇÕES LOCAIS (Apenas variáveis nativas/built-in)
local opt = vim.opt
local wo = vim.wo
local api = vim.api
local keymap = vim.keymap
local diagnostic = vim.diagnostic
local lsp_util = vim.lsp.util

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
opt.linespace = 1
opt.cursorline = true
-- Outros
opt.swapfile = false
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.fileformat = "unix"
opt.fileformats = "unix,dos,mac"

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
    -- TEMA: Everforest
    {
        "neanias/everforest-nvim",
        lazy = false,    -- Carrega no startup
        priority = 1000, -- Garante que seja carregado primeiro
        config = function()
            require("everforest").setup({
                background = 'dark', -- Tema Everforest: 'dark' ou 'light'
                contrast = 'medium', -- Variante do Everforest: 'hard', 'medium', ou 'soft'
            })
            vim.cmd.colorscheme("everforest")
        end,
    },

    -- nvim-web-devicons (Otimizado) - Configurações de ícones mantidas.
    {
        'nvim-tree/nvim-web-devicons',
        event = "VimEnter", -- Otimizado para não ser 'lazy = false'
        priority = 900,
        config = function()
            require('nvim-web-devicons').setup {
                override = {
                    py = { icon = "", color = "#748CED" },
                    go = { icon = "󰟓", color = "#6AD8DE", name = "GoLangFile" },
                    sh = { icon = "", color = "#89E051", name = "ShellScript" },
                    tf = { icon = "󱁢", color = "#A56FED", name = "TerraformFile" },
                    yml = { icon = "", color = "#FCCB50", name = "YAMLFile" },
                    yaml = { icon = "", color = "#FCCB50", name = "YAMLFile" },
                    json = { icon = "󰘦", color = "#F0DF6E", name = "JSONFile" },
                    csv = { icon = "", color = "#8A2BE2", name = "CSVFile" },
                    xlsx = { icon = "", color = "#217346", name = "ExcelFile" },
                    xls = { icon = "", color = "#217346", name = "ExcelFileOld" },
                    txt = { icon = "󰯂", color = "#A8A8A8", name = "TextFile" },
                },
                override_by_filename = {
                    ["go.sum"] = { icon = "󰟓", color = "#F14E32", name = "GoSum" },
                    ["go.mod"] = { icon = "󰟓", color = "#F14E32", name = "GoSum" },
                    ["Containerfile"] = { icon = "", color = "#DC2626", name = "ContainerFile" },
                    ["Dockerfile"] = { icon = "󰡨", color = "#2496ED", name = "DockerFile" },
                },
                color_icons = true,
            }
        end
    },
    -- Fechamento Automático de Pares (nvim-autopairs)
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = function()
            -- OBS: 'cmp' é declarado na Seção 4 para evitar redundância.
            require("nvim-autopairs").setup {}
            -- cmp é declarado aqui para evitar erro de require no escopo global
            local cmp = require("cmp")
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end
    },

    -- Novo Plugin de Indentação (Mini.indentscope)
    {
        'echasnovski/mini.indentscope',
        version = "*",
        config = function()
            require('mini.indentscope').setup({
                symbol = '┊',
                options = { try_as_border = true },
                draw = {
                    delay = 0,
                    animation = require('mini.indentscope').gen_animation.none(),
                },
            })
        end,
    },

    -- LSP / COMPLEÇÃO / FORMATTER / TREESITTER
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim",          cmd = "Mason" },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/nvim-cmp",                 dependencies = { "hrsh7th/cmp-nvim-lsp", "windwp/nvim-autopairs" } },
    { "stevearc/conform.nvim",            event = "BufWritePre" },
    { "nvim-treesitter/nvim-treesitter",  build = ":TSUpdate" },
    { "nvim-lua/plenary.nvim" },

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
                    prompt_prefix = "  ",
                    selection_caret = " ",
                    entry_prefix = "    ",
                    sorting_strategy = "ascending",
                    layout_strategy = "flex",
                    layout_config = {
                        prompt_position = "bottom",
                        width = 0.92,
                        height = 0.85,
                        preview_cutoff = 120,
                    },
                    dynamic_preview_title = true,
                    path_display = { "truncate" },
                    winblend = 4,
                    border = true,
                    borderchars = {
                        prompt = { "─", "│", "─", "│", "╭", "╮", "╰", "╯" },
                        results = { "─", "│", "─", "│", "├", "┤", "╰", "╯" },
                        preview = { "─", "│", "─", "│", "╭", "╮", "╰", "╯" },
                    },
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

            vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#30363d" })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#30363d" })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#30363d" })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#30363d" })

            -- Extensions e Keymaps
            pcall(telescope.load_extension, "file_browser")
            pcall(telescope.load_extension, "fzf")
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
                F = { icon = "FX", color = "error", alt = { "FIX", "FIXME", "BUG", "FIXIT", "ISSUE" } },
                T = { icon = "TD", color = "info" },
                H = { icon = "HK", color = "warning", alt = { "HACK" } },
                WARN = { icon = "WN", color = "warning", alt = { "WARNING", "XXX" } },
                OPT = { icon = "OP", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = "NT", color = "hint", alt = { "INFO" } },
                TST = { icon = "TS", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
            },
        },
    },
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        config = function()
            require("dashboard").setup({
                theme = "hyper",
                config = {
                    header = {
                        "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
                        "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
                        "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
                        "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                        "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
                        "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
                    },
                    footer = { "Welcome back, Victor" },
                    shortcut = {},
                },
            })
        end,
        dependencies = { { "nvim-tree/nvim-web-devicons" } },
    },
    {
        'NeogitOrg/neogit',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'sindrets/diffview.nvim',
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            require('neogit').setup()
        end
    },
    {
        'f-person/git-blame.nvim',
        config = function()
            vim.g.gitblame_enabled = 0
            vim.g.gitblame_message_template = '<author> • <date> • <summary>'
        end
    },

}

-- 🚨 EXECUÇÃO CRUCIAL: O Lazy.nvim carrega todos os plugins a partir daqui 🚨
require("lazy").setup(plugins)

-- [ATIVANDO O TEMA]
vim.cmd('colorscheme everforest')

-- 🟢 VARIÁVEIS DE PLUGINS: São seguras para serem chamadas AGORA, após o lazy.setup()
-- local lspconfig = require("lspconfig")
require("lspconfig").pylsp.setup({
    settings = {
        pylsp = {
            plugins = {
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                mccabe = { enabled = false },
            },
        },
    },
})

local cmp = require("cmp")

---

-- ===========================================================================
-- 4. SETUP DO FORMATTER (CONFORM.NVIM) - OTIMIZAÇÃO
-- ===========================================================================
require("conform").setup({
    -- CORREÇÃO: Garante que a formatação ocorra antes de salvar
    format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
        async = false,
    },
    formatters_by_ft = {
        python = { "black" },
        lua = { "stylua" },
        go = { "gopls" },
        terraform = { "terraform_fmt" },
    },
})

-- ===========================================================================
-- 5. CONFIGURAÇÃO DE LINGUAGENS (LSP E AUTOCOMPLETAR)
-- ===========================================================================

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
end

-- 5.3. Instalação e Configuração dos Language Servers (Mason + LSPs)

local ensure_installed = { "ruff", "gopls", "sqlls", "terraformls", "lua_ls" }
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "ruff", "gopls", "sqlls", "terraformls", "lua_ls" },
    excluded = { "pylsp", "pyright" },

    handlers = {

        -- handler genérico único
        function(server_name)
            lspconfig[server_name].setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })
        end,

        -- desativar
        ["pylsp"] = function() end,
        ["pyright"] = function() end,

        -- ruff
        ["ruff"] = function()
            lspconfig.ruff.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    ruff = {
                        format = false,
                        diagnosticSources = { "ruff" },
                    },
                },
            })
        end,

        -- gopls
        ["gopls"] = function()
            lspconfig.gopls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    gopls = {
                        staticcheck = true,
                        gofumpt = false,
                    },
                },
            })
        end,
    }
})
---

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

-- Treesitter setup (expandido para mais linguagens)
require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "go", "python", "lua", "hcl", "sql", "bash", "json", "yaml", "markdown",
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
    -- Configuração para exibir o texto virtual apenas com o primeiro diagnóstico
    virtual_text = {
        prefix = "• ", -- Prefixo do texto
        severity = { min = vim.diagnostic.severity.WARN }, -- Mostra de Warning para cima
        -- Configuração-chave: Múltiplos diagnósticos na:LspInfo mesma linha NÃO serão concatenados
        -- Apenas o primeiro (o mais severo) será mostrado.
        source = "always",
    },
    float = { border = "rounded" },
})
-- Adiciona bordas arredondadas aos popups do LSP (hover, etc.)
local orig_util_open_floating_preview = lsp_util.open_floating_preview
function lsp_util.open_floating_preview(contents, syntax, opts)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig_util_open_floating_preview(contents, syntax, opts)
end

---

-- ===========================================================================
-- 7. NORMALIZAÇÃO AUTOMÁTICA DE FIM DE LINHA (REMOVE ^M EM ARQUIVOS)
-- ===========================================================================

-- Converte automaticamente CRLF → LF ao abrir
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = { "*.tf", "*.tfvars", "*.hcl", "*.sh", "*.yaml", "*.yml", "*.py", ".sql", ".go" },
    callback = function()
        -- Força formato Unix
        vim.opt_local.fileformat = "unix"

        -- Remove quaisquer ^M que estejam no texto
        vim.cmd([[%s/\r//ge]])
    end,
    desc = "Remove ^M e converte arquivos para formato Unix (LF)",
})

-- ===========================================================================
-- 8. ABRE .ipynb NO JUPYTER LAB (Versão Final Otimizada) 🧪
-- ===========================================================================
local function open_jupyter_lab(event)
    local file_path = vim.fn.expand(event.match)

    -- Comando que usa xdg-open (mais portátil) ou força firefox.
    -- O 'jupyter lab' é chamado diretamente, e o '&' o coloca em background.
    -- O '/dev/null 2>&1' silencia qualquer saída do shell.
    local cmd = string.format("jupyter lab --browser=firefox '%s' > /dev/null 2>&1 &", file_path)

    -- Tenta usar jobstart (método nativo e preferido do Neovim para assincronia)
    -- Se jobstart for uma função nativa, use-a. Caso contrário, use vim.fn.system.
    if vim.fn.jobstart then
        vim.fn.jobstart(cmd, { detach = true })
    else
        vim.fn.system(cmd)
    end

    -- Fecha o buffer.
    vim.cmd('bd!')
end

vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.ipynb",
    callback = open_jupyter_lab,
    desc = "Abre .ipynb no Jupyter Lab via comando shell"
})
