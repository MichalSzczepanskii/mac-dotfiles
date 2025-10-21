local function is_angular_project()
  local cwd = vim.fn.getcwd()
  if vim.fn.filereadable(cwd .. "/angular.json") == 1 or vim.fn.filereadable(cwd .. "/project.json") == 1 then
    return true
  end
  return false
end

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.html" },
  callback = function()
    if is_angular_project() then
      vim.bo.filetype = "htmlangular"
    end
  end,
})
