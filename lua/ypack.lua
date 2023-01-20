local get_package_name = function(s)
  local rhs = s:gsub("^(.+)/.+$", "%1")
  local lhs = s:gsub("^.+/(.+)$", "%1")
  if lhs == "nvim" then -- package name from uri 'xxx/nvim'
    return rhs
  end
  -- package name from uri 'xxx/yyy.nvim' or 'xxx/yyy'
  return lhs:gsub("^(.+)%.nvim$", "%1")
end

return function(a)
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      'git', 'clone', '--depth', '1',
      'https://github.com/wbthomason/packer.nvim', install_path
    })
  end

  if not pcall(require, 'packer') then
    return
  end

  return require 'packer'.startup(function(use)
    use 'wbthomason/packer.nvim'
    for k, v in pairs(a) do
      local uri
      if type(k) == 'string' then
        uri = k
      elseif type(v[1]) == 'string' then
        uri = v[1]
      elseif type(k) == 'number' then
        uri = v
      else
        print(k, type(k))
        error("Invalid package spec. Package name must bey the key or the first element", 1)
      end
      local pkg = v
      if type(v) == 'string' then
        pkg = { v }
      end
      pkg[1] = pkg[1] or uri
      pkg.as = pkg.as or get_package_name(uri)
      pkg.config = pkg.config or string.format('local _, e = pcall(function() require("plugins.%s") end)', pkg.as)
      use(pkg)
    end
  end)
end
