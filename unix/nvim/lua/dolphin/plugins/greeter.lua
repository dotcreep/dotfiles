return {
  'goolord/alpha-nvim',
  config = function()
    local alpha = require('alpha')
    local dashboard = require("alpha.themes.dashboard")
    local function get_current_date()
      return os.date("%a, %d %b")
    end
    local date = get_current_date()
    local plugins = require('lazy').plugins()
    local footer = {
      "",
      "   Today " .. date .. " ",
      "   " .. #plugins .. " plugins in total",
    }
    local M = {}

    M.option_1 = {
      "      ▄▀▄     ▄▀▄        ",
      "     ▄█░░▀▀▀▀▀░░█▄       ",
      " ▄▄  █░░░░░░░░░░░█  ▄▄   ",
      "█▄▄█ █░░▀░░┬░░▀░░█ █▄▄█  ",
      "",
      "   Today " .. date .. " ",
      "   " .. #plugins .. " plugins in total",
    }
    M.option_2 = {
      "   ▐▀▄       ▄▀▌   ▄▄▄▄▄▄▄             ",
      "   ▌▒▒▀▄▄▄▄▄▀▒▒▐▄▀▀▒██▒██▒▀▀▄          ",
      "   ▒▒▒▒▀▒▀▒▀▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▀▄        ",
      "  ▌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▄▒▒▒▒▒▒▒▒▒▒▒▒▀▄      ",
      "▀█▒▒▒█▌▒▒█▒▒▐█▒▒▒▀▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▌     ",
      "▀▌▒▒▒▒▒▒▀▒▀▒▒▒▒▒▒▀▀▒▒▒▒▒▒▒▒▒▒▒▒▒▒▐   ▄▄",
      "▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▌▄█▒█",
      "▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█▒█▀ ",
      "▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█▀   ",
      "▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▌    ",
      " ▌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▐     ",
      " ▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▌     ",
      "  ▌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▐      ",
      "  ▐▄▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▄▌      ",
      "    ▀▄▄▀▀▀▀▀▄▄▀▀▀▀▀▀▀▄▄▀▀▀▀▀▄▄▀        ",
      "",
      "   Today " .. date .. " ",
      "   " .. #plugins .. " plugins in total",
    }
    M.option_3 = {
      "       ██████████████",
      "     ██▓▓▓▓▓▓▓▓▓ M ▓████",
      "   ██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██",
      "   ██████░░░░██░░██████",
      "██░░░░████░░██░░░░░░░░██",
      "██░░░░████░░░░██░░░░░░██",
      "   ████░░░░░░██████████",
      "   ██░░░░░░░░░░░░░██",
      "     ██░░░░░░░░░██",
      "       ██░░░░░░██",
      "     ██▓▓████▓▓▓█",
      "  ██▓▓▓▓▓▓████▓▓█",
      "██▓▓▓▓▓▓███░░███░",
      "   ██░░░░░░███████",
      "     ██░░░░███████",
      "       ██████████",
      "      ██▓▓▓▓▓▓▓▓▓██",
      "      █████████████",
      "",
      "   Today " .. date .. " ",
      "   " .. #plugins .. " plugins in total",
    }
    M.option_4 = {
      "           ▄██████████████▄         ",
      "       ▄████░░░░░░░░█▀    █▄        ",
      "      ██░░░░░░░░░░░█▀      █▄       ",
      "     ██░░░░░░░░░░░█▀        █▄      ",
      "    ██░░░░░░░░░░░░█          ██     ",
      "   ██░░░░░░░░░░░░░█      ██  ██     ",
      "  ██░░░░░░░░░░░░░░█▄     ██  ██     ",
      " ████████████░░░░░░██        ██     ",
      "██░░░░░░░░░░░██░░░░░█████████████   ",
      "██░░░░░░░░░░░██░░░░█▓▓▓▓▓▓▓▓▓▓▓▓▓█  ",
      "██░░░░░░░░░░░██░░░█▓▓▓▓▓▓▓▓▓▓▓▓▓▓█  ",
      " ▀███████████▒▒▒▒█▓▓▓███████████▀   ",
      "    ██▒▒▒▒▒▒▒▒▒▒▒▒█▓▓▓▓▓▓▓▓▓▓▓▓█    ",
      "     ██▒▒▒▒▒▒▒▒▒▒▒▒██▓▓▓▓▓▓▓▓▓▓█    ",
      "      █████▒▒▒▒▒▒▒▒▒▒██████████     ",
      "         ▀███████████▀              ",
      "",
      "         Today " .. date .. " ",
      "        " .. #plugins .. " plugins in total",
    }
    -- local headers = {}
    -- for _, v in ipairs(M.option_3) do
    --   table.insert(headers, v)
    -- end
    -- for _, v in ipairs(footer) do
    --   table.insert(headers, v)
    -- end
    -- local final_headers = table.concat(headers, "\n")
    dashboard.section.header.val = M.option_4
    dashboard.section.buttons.val = {
      dashboard.button("n", " New File", "<cmd>ene<CR>"),
      dashboard.button("e", " Explorer", "<cmd>NvimTreeToggle<CR>"),
      dashboard.button("r", "󰊄 Ripgrep", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("f", " Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("s", "󰦛 Restore Session current directory", "<cmd>SessionRestore<CR>"),
      dashboard.button("q", " Quit", "<cmd>qa<CR>"),
    }
    alpha.setup(dashboard.opts)
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end
}
