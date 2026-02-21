local utils = { }

local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

function utils.opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then scopes['o'][key] = value end
end

function utils.map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local md_jobs = {} -- Store job IDs indexed by file path

-- Ensure all preview processes are killed when Neovim exits
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    for _, job_id in pairs(md_jobs) do
      if job_id then
        vim.fn.jobstop(job_id)
      end
    end
  end
})

function utils.markdown_preview()
  local file_path = vim.fn.expand('%:p')
  if file_path == "" or vim.bo.filetype ~= "markdown" then
    vim.notify("Not a markdown file", vim.log.levels.WARN)
    return
  end

  -- If a preview for this file is already running, stop it
  if md_jobs[file_path] then
    vim.fn.jobstop(md_jobs[file_path])
    md_jobs[file_path] = nil
  end

  -- Find an available port using python3
  local port = vim.fn.system("python3 -c 'import socket; s=socket.socket(); s.bind((\"\", 0)); print(s.getsockname()[1]); s.close()'"):gsub("%s+", "")
  if vim.v.shell_error ~= 0 or port == "" then
    port = "3333" -- Fallback
  end

  local job_id = vim.fn.jobstart({'gh', 'markdown-preview', '-p', port, file_path}, {
    detach = false, -- Process dies when nvim dies
    on_stdout = function() end, -- Suppress output
    on_stderr = function() end, -- Suppress errors
    on_exit = function()
      if md_jobs[file_path] == job_id then
        md_jobs[file_path] = nil
      end
    end,
  })

  if job_id > 0 then
    md_jobs[file_path] = job_id
    vim.notify(string.format("Markdown preview started on port %s", port), vim.log.levels.INFO)
  else
    vim.notify("Failed to start markdown preview", vim.log.levels.ERROR)
  end
end

return utils

