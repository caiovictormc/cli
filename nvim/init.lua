-- Gerenciador de plugins usando vim-plug
-- --------------------------------------

vim.cmd [[
  call plug#begin('~/.vim/plugged')
  Plug 'github/copilot.vim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' }
  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'ayu-theme/ayu-vim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'airblade/vim-gitgutter'
  Plug 'mbbill/undotree'
  Plug 'preservim/nerdtree'
  Plug 'folke/tokyonight.nvim', { 'tag': 'main' }
  Plug 'nvim-lualine/lualine.nvim'
  Plug 'kdheepak/lazygit.nvim'
  Plug 'folke/snacks.nvim'
  Plug 'coder/claudecode.nvim'
  call plug#end()
]]


-- Tema
-- ----

vim.g.ayucolor = "dark"
vim.cmd.colorscheme("ayu")
-- vim.cmd.colorscheme("tokyonight")


-- Configurações básicas
-- ---------------------

vim.opt.colorcolumn = "80,120"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.incsearch = true


-- Configurações de plugins do Git
-- -------------------------------

vim.cmd [[
  highlight GitGutterAdd guibg=#a8cc8c guifg=#282c34 ctermbg=green ctermfg=black
  highlight GitGutterChange guibg=#e5c07b guifg=#282c34 ctermbg=yellow ctermfg=black
  highlight GitGutterDelete guibg=#e06c75 guifg=#282c34 ctermbg=red ctermfg=black
  highlight GitGutterChangeLine guibg=#61afef guifg=#282c34 ctermbg=blue ctermfg=black
  highlight GitGutterDeleteLine guibg=#abb2bf guifg=#282c34 ctermbg=gray ctermfg=black

  let g:gitgutter_sign_added = '➜'
  let g:gitgutter_sign_modified = '➜'
  let g:gitgutter_sign_removed = '➜'
  let g:gitgutter_sign_modified_removed = '➜'
  let g:gitgutter_sign_removed_firstline = '➜'
  let g:gitgutter_sign_modified_firstline = '➜'
]]


-- Minhas funções customizáveis
-- ----------------------------

local function find_django_app_root()
  local current_dir = vim.fn.expand("%:p:h")
  local root = vim.loop.os_homedir()

  -- Caminha para cima até encontrar um 'apps.py'
  while current_dir and current_dir ~= root do
    if vim.loop.fs_stat(current_dir .. "/apps.py") then
      require("telescope.builtin").find_files({ cwd = current_dir })
      return
    end

    current_dir = vim.fn.fnamemodify(current_dir, ":h") -- Sobe um diretório
  end
end

local function show_git_blame()
  local file = vim.fn.expand("%")
  local line = vim.fn.line(".")
  local repo_url = vim.fn.system("git config --get remote.origin.url"):gsub("\n", "")
  local rel_path = vim.fn.system("git rev-parse --show-prefix"):gsub("\n", "")
  local filename = vim.fn.expand("%:t")
  local blame_output = vim.fn.system(string.format("git blame -L %d,%d --date=iso %s", line, line, file))

  local commit_hash = blame_output:match("^(%w+)")
  local author = blame_output:match("%((.-)%s+%d%d%d%d%-%d%d%-%d%d")
  local date = blame_output:match("(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d)")

  if not commit_hash or not author or not date then
    vim.notify("Não foi possível obter informações do git blame", vim.log.levels.WARN)
    return
  end

  local commit_msg = vim.fn.system("git log -1 --pretty=format:%s " .. commit_hash):gsub("\n", "")
  local github_url = repo_url
    :gsub("git@github.com:", "https://github.com/")
    :gsub("%.git$", "")
    .. "/commit/" .. commit_hash

  local lines = {
    "🔨 Commit: " .. commit_hash,
    "👤 Autor: " .. author,
    "📅 Data: " .. date,
    "💬 Mensagem: " .. commit_msg,
    "🔗 GitHub: " .. github_url,
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local opts = {
    style = "minimal",
    relative = "cursor",
    width = 100,
    height = #lines + 1,
    row = 1,
    col = 0,
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>lua vim.api.nvim_win_close(" .. win .. ", true)<CR>", { noremap = true, silent = true })
end


-- Mapeamentos de teclas
-- ---------------------

local keymap = vim.keymap.set

keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
keymap('n', '<leader>fc', '<cmd>Telescope find_files cwd=%:p:h<cr>')
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
keymap('n', '<leader>fdg', '<cmd>Telescope live_grep cwd=%:p:h<cr>')
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')
keymap('n', '<leader>fo', '<cmd>Telescope oldfiles<cr>')
keymap('n', '<leader>fr', '<cmd>Telescope lsp_references<cr>')

keymap('n', '<leader>fa', find_django_app_root)

keymap('n', '<F5>', ':UndotreeToggle<CR>')

keymap('v', '<C-c>', '"+y')
keymap('n', '<C-S-]>', ':vsp<CR><C-w>l<C-]>')
keymap('n', '<C-S-/>', ':vsp<CR><C-w>l')

keymap('n', '<leader>gs', '<cmd>Telescope git_status<cr>')
keymap('n', '<leader>gc', '<cmd>Telescope git_bcommits<cr>')
keymap("n", "<leader>gb", show_git_blame)

keymap('n', '<leader>nt', ':NERDTreeToggle %<CR>')
keymap('n', '<leader>lg', ':LazyGit<CR>')

keymap("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)


-- Claude Code
keymap("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Claude: Toggle" })
keymap("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Claude: Focus" })
keymap("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Claude: Resume" })
keymap("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Claude: Continue" })
keymap("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Claude: Select Model" })
keymap("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Claude: Add Current Buffer" })
keymap("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Claude: Send to Claude" })
keymap("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Claude: Accept Diff" })
keymap("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Claude: Deny Diff" })


-- Configurações gerais dos plugins
-- --------------------------------

require('lualine').setup { sections = { lualine_c = { { 'filename', path = 1 } } } }

require("claudecode").setup({})


local lspconfig = require('lspconfig')

lspconfig.pyright.setup {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        typeCheckingMode = "off",
      }
    }
  },
  on_attach = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end
}

lspconfig.html.setup {
  on_attach = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  filetypes = { "html", "htmldjango" } -- Suporte para HTML e templates do Django
}


require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "pyright", "html" },
}


local cmp = require('cmp')

cmp.setup {
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  }),
}
