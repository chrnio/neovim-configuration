vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4

local ok, jdtls = pcall(require, "jdtls")
if not ok or vim.fn.executable("jdtls") == 0 then
  return
end

local root = vim.fs.root(0, { ".git", "mvnw", "gradlew" })
  or vim.fs.root(0, { "pom.xml", "build.gradle", "build.gradle.kts" })
if not root then
  return
end

local project = vim.fn.fnamemodify(root, ":t") .. "-" .. vim.fn.sha256(root):sub(1, 8)
local workspace = vim.fn.stdpath("cache") .. "/jdtls/workspaces/" .. project

local mason = vim.fn.stdpath("data") .. "/mason/packages"

local lombok = mason .. "/jdtls/lombok.jar"
local cmd = { "jdtls", "-data", workspace }
if vim.uv.fs_stat(lombok) then
  table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok)
end

local bundles = {}
vim.list_extend(bundles, vim.fn.glob(mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true))
for _, jar in ipairs(vim.fn.glob(mason .. "/java-test/extension/server/*.jar", true, true)) do

  if not jar:match("runner%-jar%-with%-dependencies") and not jar:match("jacocoagent") then
    table.insert(bundles, jar)
  end
end

jdtls.start_or_attach({
  cmd = cmd,
  root_dir = root,
  init_options = { bundles = bundles },
  settings = {
    java = {
      configuration = { updateBuildConfiguration = "interactive" },
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      import = { gradle = { enabled = true }, maven = { enabled = true } },
      signatureHelp = { enabled = true },
      referencesCodeLens = { enabled = true },
      implementationsCodeLens = { enabled = true },
      inlayHints = { parameterNames = { enabled = "literals" } },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "org.assertj.core.api.Assertions.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
          "org.hamcrest.Matchers.*",
        },
        importOrder = { "java", "javax", "jakarta", "org", "com", "" },
      },
      sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
    },
  },
  on_attach = function(_, bufnr)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("n", "<leader>co", jdtls.organize_imports, "Organize imports")
    map("n", "<leader>cv", jdtls.extract_variable, "Extract variable")
    map("v", "<leader>cv", function() jdtls.extract_variable(true) end, "Extract variable")
    map("v", "<leader>cm", function() jdtls.extract_method(true) end, "Extract method")

    if #bundles > 0 then
      pcall(jdtls.setup_dap, { hotcodereplace = "auto" })
      pcall(function() require("jdtls.dap").setup_dap_main_class_configs() end)
      map("n", "<leader>dn", jdtls.test_nearest_method, "Debug nearest test")
      map("n", "<leader>dN", jdtls.test_class, "Debug test class")
    end
  end,
})
