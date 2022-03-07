local utils = require('utils')

utils.map('n', '<C-a>', '<Plug>(dial-increment)', { noremap = false })
utils.map('n', '<C-x>', '<Plug>(dial-decrement)', { noremap = false })

utils.map('v', '<C-a>', '<Plug>(dial-increment)', { noremap = false })
utils.map('v', '<C-x>', '<Plug>(dial-decrement)', { noremap = false })

utils.map('v', 'g<C-a>', '<Plug>(dial-increment-additional)', { noremap = false })
utils.map('v', 'g<C-x>', '<Plug>(dial-decrement-additional)', { noremap = false })
