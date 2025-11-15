-- ===========================================================================
-- 🌟 init.lua - Configuração COMPLETA e Modular do Neovim
-- ===========================================================================

-- Declarações Locais (Para acesso rápido e legibilidade)
local opt = vim.opt
local wo = vim.wo
local api = vim.api
local keymap = vim.keymap
local diagnostic = vim.diagnostic
local lsp_util = vim.lsp.util

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
opt.linespace = 10
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

    -- nvim-web-devicons (Sintaxe corrigida)
    {
        'nvim-tree/nvim-web-devicons',
        lazy = false,
        priority = 900, -- Garante que ele carregue antes do Telescope
        config = function()
            -- Esta chamada é essencial para injetar os ícones em todo o Neovim
            require('nvim-web-devicons').setup {
                override = {
                    py = {
                        icon = "",
                        color = "#748CED"
                    },
                    go = {
                        icon = "󰟓",
                        color = "#6AD8DE",
                        name = "GoLangFile"
                    },
                    sh = {
                        icon = "", -- Ícone de Shell/Bash (Nerd Font: nf-dev-shell)
                        color = "#89E051", -- Cor verde (típica de scripts shell)
                        name = "ShellScript"
                    },
                    tf = {
                        icon = "󱁢", -- Ícone de Terraform
                        color = "#A56FED", -- Cor roxa/azul (típica do Terraform)
                        name = "TerraformFile"
                    },
                    yml = {
                        icon = "", -- Ícone de YAML
                        color = "#FCCB50", -- Cor amarela (típica do YAML)
                        name = "YAMLFile"
                    },
                    yaml = {
                        icon = "", -- Ícone de YAML
                        color = "#FCCB50", -- Cor amarela (típica do YAML)
                        name = "YAMLFile"
                    },
                    json = {
                        icon = "󰘦", -- Ícone de JSON
                        color = "#F0DF6E", -- Cor amarela clara (para destaque)
                        name = "JSONFile"
                    },
                    csv = {
                        icon = "", -- Ícone de CSV (tabela)
                        color = "#8A2BE2", -- Cor azul-violeta (sugestão de cor para dados)
                        name = "CSVFile"
                    },
                    xlsx = {
                        icon = "", -- Ícone de Planilha/Tabela
                        color = "#217346", -- Cor do Excel
                        name = "ExcelFile"
                    },
                    xls = {
                        icon = "", -- Usando o mesmo ícone para o formato antigo
                        color = "#217346",
                        name = "ExcelFileOld"
                    },
                    txt = {
                        icon = "󰯂", -- Ícone de Texto Simples
                        color = "#A8A8A8", -- Cor cinza clara (para texto)
                        name = "TextFile"
                    },
                },
                override_by_filename = {
                    -- Customização para o arquivo go.sum em VERMELHO
                    ["go.sum"] = {
                        icon = "󰟓",
                        color = "#F14E32", -- Vermelho
                        name = "GoSum"
                    },
                    ["go.mod"] = {
                        icon = "󰟓",
                        color = "#F14E32", -- Vermelho
                        name = "GoSum"
                    },
                    ["Containerfile"] = {
                        icon = "", -- Ícone de Contêiner/Docker
                        color = "#2496ED", -- Cor azul (Típica do Docker)
                        name = "ContainerFile"
                    },
                    ["Dockerfile"] = {
                        icon = "󰡨",
                        color = "#2496ED",
                        name = "DockerFile"
                    },
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
                    prompt_prefix = "   ",
                    selection_caret = " ",
                    entry_prefix = "   ",

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
                        prompt  = { "─", "│", "─", "│", "╭", "╮", "╰", "╯" },
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

            -- Extensions
            pcall(telescope.load_extension, "file_browser")
            pcall(telescope.load_extension, "fzf") -- Mapeamentos de atalho
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
            vim.g.gitblame_enabled = 0 -- Desabilitado por padrão
            vim.g.gitblame_message_template = '<summary> • <date> • <author>'
        end
    },
}

-- 🚨 ESTE COMANDO EXECUTA O LAZY.NVIM E CARREGA OS PLUGINS NO LUA PATH 🚨
require("lazy").setup(plugins)

-- [ATIVANDO O TEMA]
vim.cmd('colorscheme github_dark')

---
---

-- ===========================================================================
-- 4. SETUP DO FORMATTER (CONFORM.NVIM)
-- ===========================================================================
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

---
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

---
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

---
---

-- ===========================================================================
-- 8. ABRE .ipynb NO JUPYTER NOTEBOOK (COM LÓGICA DE FOCO E FECHAMENTO) 🧪
-- ===========================================================================

-- 8.1. Função Principal com Lógica de Fechamento e Redirecionamento
local function open_ipynb_and_handle_nvim(event)
    local file_path = vim.fn.expand(event.match) -- Caminho absoluto do arquivo

    -- 1. Comando para abrir o Jupyter Notebook e forçar o Firefox
    -- O comando 'nohup ... & ' roda em segundo plano e não bloqueia o Neovim.
    local jupyter_command = string.format("nohup jupyter lab --browser=firefox '%s' > /dev/null 2>&1 &", file_path)
    vim.fn.system(jupyter_command)

    -- 2. Tenta redirecionar para o Firefox
    -- ATENÇÃO: 'wmctrl' é usado no Linux para gerenciar janelas e foco.
    vim.fn.system("wmctrl -a firefox || true")

    -- 3. Lógica de Verificação e Fechamento/Redirecionamento no Neovim

    -- Conta apenas os buffers listados (arquivos abertos)
    local listed_buffers = 0
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        -- Verifica se o buffer é 'buflisted' e tem nome de arquivo (não é um buffer de plugin)
        if vim.api.nvim_buf_get_option(bufnr, 'buflisted') and vim.api.nvim_buf_get_name(bufnr) ~= '' then
            listed_buffers = listed_buffers + 1
        end
    end

    -- Se houver 1 buffer listado (o arquivo .ipynb), fecha o Neovim.
    if listed_buffers == 1 then
        vim.cmd('quit') -- Fecha o Neovim
    else
        -- Caso contrário, deleta o buffer do .ipynb e permanece na sessão.
        vim.cmd('bd!')
    end
end

-- 8.2. Autocommand que intercepta a abertura do arquivo *.ipynb
-- O evento 'BufReadCmd' é usado para evitar que o Neovim leia o arquivo antes de enviá-lo para o Jupyter.
vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.ipynb",
    callback = open_ipynb_and_handle_nvim,
    desc = "Abre .ipynb no Jupyter Notebook e trata o foco do Neovim/Firefox"
})
