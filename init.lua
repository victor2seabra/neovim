-- ===========================================================================
-- 🌟 init.lua - Configuração COMPLETA e Modular do Neovim (v9)
-- Refatorado com sintaxe moderna (vim.o, vim.wo) e modularidade aprimorada.
-- CORRIGIDO: Erros de sintaxe e avisos do linter (lua_ls).
-- ===========================================================================

-- 0. DECLARAÇÕES LOCAIS (APIs nativas necessárias)
local api = vim.api
local keymap = vim.keymap
local diagnostic = vim.diagnostic
local lsp_util = vim.lsp.util

-- ===========================================================================
-- 1. CONFIGURAÇÕES BÁSICAS DO VIM/NEOVIM (Options)
-- ===========================================================================
-- Indentação: 4 espaços
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.copyindent = true
vim.o.autoindent = true
vim.o.tabstop = 4
-- UI e Aparência
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.mouse = "a"
vim.o.termguicolors = true
vim.o.fillchars = "eob: "
vim.o.pumheight = 10
vim.o.completeopt = 'menu,menuone,noselect'
vim.o.linespace = 1
vim.o.cursorline = true
-- Outros
vim.o.swapfile = false
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"
vim.o.fileformat = "unix"
vim.o.fileformats = "unix,dos,mac"

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
vim.o.rtp = lazypath .. "," .. vim.o.rtp

-- ===========================================================================
-- 3. DEFINIÇÃO E CONFIGURAÇÃO DOS PLUGINS (Usando Lazy.nvim opts)
-- ===========================================================================
local plugins = {
    -- TEMA: Everforest
    {
        "neanias/everforest-nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("everforest").setup({
                background = 'dark',
                contrast = 'medium',
            })
            vim.cmd.colorscheme("everforest")
        end,
    },

    -- nvim-web-devicons
    {
        'nvim-tree/nvim-web-devicons',
        event = "VimEnter",
        priority = 900,
        opts = {
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
        },
    },

    -- Fechamento Automático de Pares (nvim-autopairs)
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup {}
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

    -- LSP / COMPLEÇÃO / FORMATTER / TREESITTER (Configurados em blocos dedicados)
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim",          cmd = "Mason" },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/nvim-cmp",                 dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer" } },
    { "stevearc/conform.nvim",            event = "BufWritePre" },
    -- Treesitter configurado com opts. A função build é importante.
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "go", "python", "terraform", "lua", "hcl", "sql", "bash", "json", "yaml", "markdown",
            },
            highlight = { enable = true },
            indent = { enable = true },
            parser_configs = {
                hcl = { filetype = { "hcl", "terraform" } },
            },
        }
    },
    { "nvim-lua/plenary.nvim" },

    -- TELESCOPE.NVIM - Fuzzy Finder
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
                -- Garante que ele comece no diretório de trabalho atual, usando um fallback seguro (o Home do usuário)
                local path = vim.fn.getcwd()
                if path == "" then -- Caso especial onde cwd é vazio, usa o diretório principal do usuário.
                    path = vim.fn.expand("~")
                end

                require("telescope").extensions.file_browser.file_browser({
                    path = path
                })
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

    -- Dashboard
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        dependencies = { { "nvim-tree/nvim-web-devicons" } },
        opts = {
            theme = "hyper",
            config = {
                header = {
                    "                                   ",
                    "   ┌─────────────────────────────┐ ",
                    "   │  > nvim start               │ ",
                    "   │ --------------------------- │ ",
                    "   │   󰟓         󱁢   󰡨         │ ",
                    "   │                             │ ",
                    "   └─────────────────────────────┘ ",
                },
                shortcut = {},
                footer = {},
            },
        },
    },

    -- Neogit e Git
    {
        'NeogitOrg/neogit',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'sindrets/diffview.nvim',
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            require('neogit').setup()

            -- ATUALIZAR ESTE BLOCO:
            local function check_git_root()
                -- Tenta encontrar o diretório '.git' ou 'root'. Se não encontrar, retorna vazio.
                local git_root = vim.fn.finddir('.git', '.;')

                if git_root ~= "" then
                    require('neogit').open()
                else
                    vim.notify("Não está em um repositório Git. Neogit não pode ser aberto.", vim.log.levels.WARN)
                end
            end

            -- O NOVO ATALHO SEGURO:
            keymap.set("n", "<leader>g", check_git_root, { desc = "Git: Neogit Dashboard (Seguro)" })
        end
    },
    {
        'f-person/git-blame.nvim',
        config = function()
            vim.g.gitblame_enabled = 0
            vim.g.gitblame_message_template = '<author> • <date> • <summary>'
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPre",
        opts = {
            signs = {
                add = { text = "" },
                change = { text = "┃" },
                delete = { text = "―" },
                topdelete = { text = "▀" },
                changedelete = { text = "┇" },
                untracked = { text = "󰎔" },
            },
            signcolumn = true,
            numhl = false,
            linehl = false,

            -- keymaps = {
            --     ["<leader>gj"] = { expr = true, "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'" },
            --     ["<leader>gk"] = { expr = true, "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'" },
            --     ["<leader>gp"] = '<cmd>Gitsigns preview_hunk<CR>',
            --     ["<leader>gb"] = function()
            --         require('gitsigns').blame_line({ full = false })
            --     end,
            --     ["<leader>gs"] = '<cmd>Gitsigns stage_hunk<CR>',
            -- },
        },
    },

    -- Terraform
    {
        "hashivim/vim-terraform",
        ft = { "terraform", "hcl" },
        config = function()
            vim.g.terraform_fmt_on_save = 0
            vim.g.terraform_align = 1
        end,
    },
}
require("lazy").setup(plugins)

vim.cmd('colorscheme everforest')

-- ANTES do setup do Mason-LSPconfig. O Ruff-LSP será o principal para Python.
local lspconfig = require("lspconfig")

-- ===========================================================================
-- 4. SETUP DO FORMATTER (CONFORM.NVIM) - OTIMIZAÇÃO
-- ===========================================================================
require("conform").setup({
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
        tf = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },
    },
    formatters = {
        terraform_fmt = {
            command = "terraform",
            args = { "fmt", "-" },
            stdin = true,
        },
    },
})

-- ===========================================================================
-- 5. CONFIGURAÇÃO DE LINGUAGENS (LSP E AUTOCOMPLETAR)
-- ===========================================================================

-- 5.1. Configuração Comum do LSP (on_attach e capabilities)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

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

-- 5.2. Setup do CMP (Autocompletar)
local cmp = require("cmp")

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
    },
    capabilities = capabilities,
})

-- Conecta nvim-autopairs com nvim-cmp
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())


-- 5.3. Instalação e Configuração dos Language Servers (Mason + LSPs)

local ensure_installed = { "ruff", "gopls", "sqlls", "terraformls", "lua_ls", "tflint" }
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = ensure_installed,
    excluded = { "pylsp" },

    handlers = {
        ["pyright"] = function()
            lspconfig.pyright.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "off", -- Desativa o type-checking
                            diagnosticMode = "off",   -- Desativa os diagnósticos (para o Ruff fazer isso)
                        },
                    },
                },
            })
        end,
        -- Configuração ESPECÍFICA para Lua_LS (CORREÇÃO DO LINTER)
        ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = { version = 'LuaJIT' },
                        diagnostics = {
                            -- Incluindo todas as variáveis locais como globais para o linter
                            globals = { 'vim', 'keymap', 'api', 'diagnostic', 'lsp_util', 'lspconfig' },
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("lua/vim/lsps/lua/library", true),
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })
        end,

        -- Configuração ESPECÍFICA para Ruff LSP
        ["ruff"] = function()
            lspconfig.ruff_lsp.setup({
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

        -- ["pylsp"] = function()
        --     lspconfig.pylsp.setup({
        --         on_attach = on_attach,
        --         capabilities = capabilities,
        --         settings = {
        --             pylsp = {
        --                 plugins = {
        --                     pyflakes = { enabled = false },
        --                     pycodestyle = { enabled = false },
        --                     mccabe = { enabled = false },
        --                 },
        --             },
        --         },
        --     })
        -- end,

        -- Configuração ESPECÍFICA para Gopls
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

        -- Configuração ESPECÍFICA para Terraformls
        ["terraformls"] = function()
            lspconfig.terraformls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                cmd = { "terraform-ls", "serve" },
                filetypes = { "terraform", "tf", "terraform-vars" },
                root_dir = require("lspconfig").util.root_pattern(".terraform", ".git", "main.tf"),
                init_options = {
                    ignoreSingleFileWarning = true,
                },
                settings = {
                    terraformls = {
                        experimentalFeatures = {
                            validateOnSave = true,
                            prefillRequiredFields = true,
                        },
                    },
                },
            })
        end,

        -- handler genérico único (para outros LSPs que não têm handler dedicado)
        function(server_name)
            lspconfig[server_name].setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })
        end,

    }
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

-- Terraform-specific settings and keymaps
api.nvim_create_autocmd("FileType", {
    pattern = { "terraform", "tf", "hcl" },
    callback = function(ev)
        local opts = { noremap = true, silent = true, buffer = ev.buf }
        -- Terraform-specific keymaps
        keymap.set("n", "<leader>ti", "<cmd>!terraform init<CR>", opts)
        keymap.set("n", "<leader>tp", "<cmd>!terraform plan<CR>", opts)
        keymap.set("n", "<leader>ta", "<cmd>!terraform apply<CR>", opts)
        keymap.set("n", "<leader>tv", "<cmd>!terraform validate<CR>", opts)
        keymap.set("n", "<leader>tf", function()
            require("conform").format({ async = true, lsp_fallback = true })
        end, opts)
    end,
    desc = "Terraform-specific settings and keymaps",
})

-- Debug adapter protocol (DAP) para Go
require("dap-go").setup()

-- Configuração do UI de Diagnósticos e Popups
diagnostic.config({
    -- Configuração para exibir o texto virtual apenas com o primeiro diagnóstico
    virtual_text = {
        prefix = "• ", -- Prefixo do texto
        severity = { min = vim.diagnostic.severity.ERROR }, -- Mostra de Warning para cima
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

    -- Comando que usa jupyter lab diretamente e o executa em background.
    local cmd = string.format("jupyter lab --browser=firefox '%s' > /dev/null 2>&1 &", file_path)

    -- Tenta usar jobstart (método nativo e preferido do Neovim para assincronia)
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
