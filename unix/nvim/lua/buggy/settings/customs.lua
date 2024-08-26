vim.o.tabline = '%!v:lua.MyTabLine()'
function _G.MyTabLine()
    local s = ''
    for i = 1, vim.fn.tabpagenr('$') do
        local buflist = vim.fn.tabpagebuflist(i)
        local winnr = vim.fn.tabpagewinnr(i)
        local bufname = vim.fn.bufname(buflist[winnr])
        local filename = vim.fn.fnamemodify(bufname, ':t')
        s = s .. '%' .. i .. 'T' .. filename .. ' '
    end
    return s
end

