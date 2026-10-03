-- ~/.config/nvim/init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.mouse = "a"
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"

vim.g.python3_host_prog = vim.fn.expand("/usr/bin/python3")

vim.keymap.set("n", "<leader>b", ":b#<CR>", { desc = "Alternate buffer" })
vim.keymap.set("n", "<Tab>", ":b ", { desc = "Buffer prompt" })

vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_quickfix_open_on_warning = 0

vim.g.accent_colour = "green"
vim.g.accent_no_bg = 1

vim.g.UltiSnipsExpandTrigger = "<Tab>"
vim.g.UltiSnipsJumpForwardTrigger = "<C-n>"
vim.g.UltiSnipsJumpBackwardTrigger = "<C-p>"
vim.g.UltiSnipsSnippetDirectories = { "UltiSnips" }

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "voldikss/vim-floaterm",
         init = function()
            vim.g.floaterm_width = 0.8
            vim.g.floaterm_height = 0.8
            vim.g.floaterm_position = "center"
            --vim.g.floaterm_borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
            vim.g.floaterm_keymap_new    = "<leader>fn"
            vim.g.floaterm_keymap_toggle = "<leader>ft"
            vim.g.floaterm_keymap_next   = "<leader>fj"
            vim.g.floaterm_keymap_prev   = "<leader>fk"
            vim.g.floaterm_keymap_kill   = "<leader>fq"
         end,
         config = function()
            vim.api.nvim_set_hl(0, "Floaterm", { link = "Normal" })
            vim.api.nvim_set_hl(0, "FloatermBorder", { link = "Normal" })
            vim.api.nvim_set_hl(0, "FloatermNC", { link = "Normal" })
          end,
    },    
    
    { 
      "alligator/accent.vim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd("syntax enable")
        pcall(vim.cmd, "colorscheme accent")
      end
    },

    { "lervag/vimtex", lazy = false },
    
    { "SirVer/ultisnips" },

    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        local ok, configs = pcall(require, "nvim-treesitter.configs")
        if not ok then
          return
        end
        configs.setup({
          ensure_installed = { "python", "latex", "lua", "vim", "vimdoc", "bash", "markdown", "c", "cpp"},
          highlight = { enable = true },
          indent = { enable = true },
        })
      end,
    },
    {
      "neovim/nvim-lspconfig",
      config = function()
        if vim.lsp.config then
          vim.lsp.config.basedpyright = {
            cmd = { "basedpyright-langserver", "--stdio" },
            filetypes = { "python" },
            root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
            settings = {
              basedpyright = {
                analysis = {
                  typeCheckingMode = "standard",
                  autoSearchPaths = true,
                  useLibraryCodeForTypes = true,
                  diagnosticMode = "openFilesOnly",
                },
              },
            },
          }
          vim.lsp.enable("basedpyright")
        else
          require("lspconfig").basedpyright.setup({
            settings = {
              basedpyright = {
                analysis = {
                  typeCheckingMode = "standard",
                  autoSearchPaths = true,
                  useLibraryCodeForTypes = true,
                  diagnosticMode = "openFilesOnly",
                },
              },
            },
          })
        end

        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
          callback = function(ev)
            local opts = { buffer = ev.buf }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          end,
        })
      end,
    },
}, {
    rocks = {
        enabled = false,
    },
})

local ascii_art = {
  ⣿⣿⠇⠁⢨⢰⣶⠨⣀⢹⣿⣿⡷⣿⠹⢿⣿⣿⣿⣿⣷⣽⢿⣿⡇⣿⣿⣿⣾⣿,
  ⣿⡟⢠⣿⢸⠽⣟⣃⠙⡌⣿⣿⡇⡏⣻⣿⣿⣿⣿⣿⣿⣿⣦⠛⣿⡹⣿⣿⣿⣿,
  ⣿⠇⣿⣭⢸⣿⣿⣿⡆⡐⡸⣿⣧⢃⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣌⢷⡹⣿⣿⣿,
  ⡿⣹⣿⣿⡟⣿⣿⣿⣿⣌⠔⣽⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡱⢹⣿⣿,
  ⢣⢸⣿⣿⣿⣿⣿⣿⣿⣿⣦⣘⣿⡏⣿⣿⣿⡯⠽⠿⠛⠛⠛⠛⠛⠛⠛⢲⣻⣿,
  ⡬⡋⣿⣿⣿⢿⠿⠿⣻⣿⣿⣷⡮⠻⢹⣿⣿⣇⣀⣀⣀⠤⢄⡀⠀⣠⢠⣿⡟⢿,
  ⢀⣇⠻⠑⠈⠀⠀⠀⢹⣿⣿⣿⣿⣦⡀⢿⣿⣿⣿⢿⣿⣀⣈⣁⣉⣡⣥⠿⣗⠜,
  ⠈⢱⡰⡀⣞⠓⠢⣐⣸⣯⣿⣿⣿⣿⣿⣮⣿⣿⣿⣿⣿⣿⣯⣧⣷⣿⣿⣶⣿⣧,
  ⠠⢸⡅⣿⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽,
  ⠀⢸⠇⣿⣿⣿⣿⣿⣿⣿⠿⢿⣻⣛⣛⣻⣭⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟,
  ⠀⣼⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⡟,
  ⠸⣿⢀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢃,
  ⣎⢿⢸⢰⡈⡛⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⡟⠋⠘⣰,
  ⣿⣯⠸⢸⠉⡿⣿⣷⠨⣩⢛⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣟⣻⣽⣿⡌⣿⠃⣿,
  ⣿⣿⣧⡎⢰⣿⠏⣿⢸⣟⠸⣿⢿⣶⠨⠭⢉⣽⣿⢹⣾⣿⣿⣿⡿⣻⣥⣾⢩⠟  ,
}

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only print ASCII art if opening Neovim without file arguments
    if vim.fn.argc() == 0 then
      local chunks = {}
      for _, line in ipairs(ascii_art) do
        table.insert(chunks, { line .. "\n", "Title" })
      end
      vim.api.nvim_echo(chunks, false, {})
    end
  end,
})
