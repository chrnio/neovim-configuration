local function input_program(default_dir)
  return function()
    local root = vim.fs.root(0, { "Cargo.toml", "CMakeLists.txt", "compile_commands.json", "Makefile", ".git" }) or vim.uv.cwd()
    local path = vim.fn.input("Path to executable: ", root .. "/" .. (default_dir or ""), "file")
    if path == "" then
      return require("dap").ABORT
    end
    return path
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: continue / start" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Evaluate expression" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup({
        controls = { enabled = false },
        layouts = {
          { elements = { "scopes", "breakpoints", "stacks", "watches" }, size = 40, position = "left" },
          { elements = { "repl", "console" }, size = 10, position = "bottom" },
        },
      })
      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"] = function() dapui.close() end

      vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapStopped", { text = ">", texthl = "DiagnosticInfo", linehl = "Visual" })

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = { command = "codelldb", args = { "--port", "${port}" } },
      }
      local native = {
        {
          name = "Launch executable",
          type = "codelldb",
          request = "launch",
          program = input_program("build/"),
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
      dap.configurations.c = native
      dap.configurations.cpp = native
      dap.configurations.rust = {
        vim.tbl_extend("force", native[1], { program = input_program("target/debug/") }),
        native[2],
      }

      dap.adapters.go = {
        type = "server",
        port = "${port}",
        executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
      }
      dap.configurations.go = {
        { name = "Debug package (current dir)", type = "go", request = "launch", program = "${fileDirname}" },
        { name = "Debug main (project root)", type = "go", request = "launch", program = "${workspaceFolder}" },
        { name = "Debug tests (current dir)", type = "go", request = "launch", mode = "test", program = "${fileDirname}" },
      }

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = { command = "js-debug-adapter", args = { "${port}" } },
      }
      local node = {
        {
          name = "Launch current file (node)",
          type = "pwa-node",
          request = "launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          skipFiles = { "<node_internals>/**" },
        },
        {
          name = "Attach to node (localhost:9229)",
          type = "pwa-node",
          request = "attach",
          port = 9229,
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          skipFiles = { "<node_internals>/**" },
        },
      }
      for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[ft] = node
      end
    end,
  },
}
