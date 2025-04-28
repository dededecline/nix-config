{ pkgs
, user
, ...
}: {
  home-manager.users.${user.username} = _: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true; # Required for some language servers
      withPython3 = true; # Required for some plugins

      extraPackages = with pkgs; [
        # Core dependencies
        git
        gcc
        ripgrep
        unzip

        # LSP and tools
        nodejs
        nodePackages.npm

        # Optional but recommended
        fd # Faster find alternative
        lazygit # Git UI
      ];

      extraLuaConfig = ''
        -- Set leader key to space
        vim.g.mapleader = ' '
        vim.g.maplocalleader = ' '

        -- Install lazy.nvim for plugin management
        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not vim.loop.fs_stat(lazypath) then
          vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath,
          })
        end
        vim.opt.rtp:prepend(lazypath)

        -- Basic options
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.mouse = 'a'
        vim.opt.showmode = false
        vim.opt.clipboard = 'unnamedplus'
        vim.opt.breakindent = true
        vim.opt.undofile = true
        vim.opt.ignorecase = true
        vim.opt.smartcase = true
        vim.opt.signcolumn = 'yes'
        vim.opt.updatetime = 250
        vim.opt.timeoutlen = 300
        vim.opt.splitright = true
        vim.opt.splitbelow = true
        vim.opt.inccommand = 'split'
        vim.opt.cursorline = true
        vim.opt.scrolloff = 10
        vim.opt.hlsearch = true

        -- Configure key mappings
        vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
        vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
        vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
        vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

        -- Set up lazy.nvim with essential plugins from kickstart.nvim
        require("lazy").setup({
          -- Theme
          {
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000,
            config = function()
              require("catppuccin").setup({
                flavour = "frappe",
                background = {
                  light = "latte",
                  dark = "frappe",
                },
                transparent_background = false,
                term_colors = false,
                integrations = {
                  cmp = true,
                  gitsigns = true,
                  nvimtree = true,
                  treesitter = true,
                  notify = false,
                },
              })
              vim.cmd.colorscheme "catppuccin"
            end,
          },
          
          -- Git integration
          'tpope/vim-fugitive',
          'tpope/vim-rhubarb',
          
          -- Detect tabstop and shiftwidth automatically
          'tpope/vim-sleuth',
          
          -- LSP
          {
            'neovim/nvim-lspconfig',
            dependencies = {
              'williamboman/mason.nvim',
              'williamboman/mason-lspconfig.nvim',
              'folke/neodev.nvim',
            },
          },
          
          -- Autocompletion
          {
            'hrsh7th/nvim-cmp',
            dependencies = {
              'L3MON4D3/LuaSnip',
              'saadparwaiz1/cmp_luasnip',
              'hrsh7th/cmp-nvim-lsp',
              'rafamadriz/friendly-snippets',
            },
          },
          
          -- Treesitter
          {
            'nvim-treesitter/nvim-treesitter',
            dependencies = {
              'nvim-treesitter/nvim-treesitter-textobjects',
            },
            build = ':TSUpdate',
          },
          
          -- Telescope
          {
            'nvim-telescope/telescope.nvim',
            branch = '0.1.x',
            dependencies = {
              'nvim-lua/plenary.nvim',
              {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
              }
            }
          },
          
          -- Nice to have plugins
          { 'numToStr/Comment.nvim', opts = {} },
          { 'lewis6991/gitsigns.nvim', opts = {} },
          { 'nvim-lualine/lualine.nvim', opts = {} },
          { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },
        })

        -- LSP Configuration
        local servers = {
          lua_ls = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        }

        -- Setup neovim lua configuration
        require('neodev').setup()
        
        -- nvim-cmp setup
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'
        require('luasnip.loaders.from_vscode').lazy_load()
        luasnip.config.setup {}

        cmp.setup {
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert {
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete {},
            ['<CR>'] = cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            },
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' }),
          },
          sources = {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
          },
        }

        -- Mason setup
        require('mason').setup()
        require('mason-lspconfig').setup {
          ensure_installed = vim.tbl_keys(servers),
        }

        -- Setup LSP with the servers
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

        local mason_lspconfig = require 'mason-lspconfig'
        mason_lspconfig.setup_handlers {
          function(server_name)
            require('lspconfig')[server_name].setup {
              capabilities = capabilities,
              settings = servers[server_name],
            }
          end,
        }

        -- Treesitter setup
        require('nvim-treesitter.configs').setup {
          highlight = { enable = true },
          indent = { enable = true },
          ensure_installed = {
            'lua',
            'vim',
            'vimdoc',
            'javascript',
            'typescript',
            'python',
            'bash',
            'markdown',
            'markdown_inline',
          },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = '<C-space>',
              node_incremental = '<C-space>',
              scope_incremental = '<C-s>',
              node_decremental = '<M-space>',
            },
          },
        }

        -- Telescope setup
        require('telescope').setup {
          defaults = {
            mappings = {
              i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
              },
            },
          },
        }
        
        -- Add telescope fzf plugin
        pcall(require('telescope').load_extension, 'fzf')
        
        -- Telescope keymaps
        vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
        vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
        vim.keymap.set('n', '<leader>/', function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end, { desc = '[/] Fuzzily search in current buffer' })
        vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
        vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
        vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
      '';
    };

    # Install a nerd font for icons
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };
}
