local utils = require('utils')

utils.map('n', 'p', '<Plug>(yankround-p)', { noremap = false })
utils.map('x', 'p', '<Plug>(yankround-p)', { noremap = false })
utils.map('n', 'P', '<Plug>(yankround-P)', { noremap = false })

utils.map('n', 'gp', '<Plug>(yankround-gp)', { noremap = false })
utils.map('x', 'gp', '<Plug>(yankround-gp)', { noremap = false })
utils.map('n', 'gP', '<Plug>(yankround-gP)', { noremap = false })

utils.map('n', '<C-p>', '<Plug>(yankround-prev)', { noremap = false })
utils.map('n', '<C-n>', '<Plug>(yankround-next)', { noremap = false })
