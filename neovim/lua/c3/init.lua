return {
    -- Recommended configuration for C3
    setup = function()
        vim.filetype.add({
            extension = {
                c3 = "c3",
                c3i = "c3",
                c3t = "c3",
            },
        });
    end,
    recommended = {
        ft = "c3",
        root = { "project.json" },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = { "c3" },
            -- Add parser configurations
            parser_install_info = {
                c3 = {
                    install_info = {
                        url = "https://github.com/c3lang/tree-sitter-c3",
                        files = { "src/parser.c", "src/scanner.c" },
                        branch = "main",
                    },
                    sync_install = false, -- Set to true if you want to install synchronously
                    auto_install = true,  -- Automatically install when opening a file
                    filetype = "c3",      -- if filetype does not match the parser name
                },
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                c3_lsp = {
                    cmd = { "c3-lsp" },
                },
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context", -- Optional: For better context display
    },
    {
        "nvim-treesitter/nvim-treesitter-refactor", -- Optional: For code refactoring features
    },
}
