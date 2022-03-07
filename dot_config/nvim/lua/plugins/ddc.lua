-- skkeleton.vim
vim.cmd([[
  call ddc#custom#patch_global('sources', ['skkeleton'])
  call ddc#custom#patch_global('sourceOptions', {
    \   '_': {
    \     'matchers': ['matcher_head'],
    \     'sorters': ['sorter_rank']
    \   },
    \   'skkeleton': {
    \     'mark': 'skkeleton',
    \     'matchers': ['skkeleton'],
    \     'sorters': []
    \   },
    \ })
]])
