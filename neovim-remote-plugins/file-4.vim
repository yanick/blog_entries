" node plugins
call remote#host#RegisterPlugin('node', '/home/yanick/.config/nvim/rplugin/node/packageName.js', [
    \ {'sync': v:null, 'name': 'SetPackageName', 'type': 'command', 'opts': {}},
    \ ])
call remote#host#RegisterPlugin('node', '/home/yanick/.config/nvim/rplugin/node/taskwarrior', [
    \ {'sync': v:null, 'name': 'TaskShow', 'type': 'function', 'opts': {}},
    \ ])


" python3 plugins
call remote#host#RegisterPlugin('python3', '/home/yanick/.config/nvim/plugged/deoplete.nvim/rplugin/python3/deoplete', [
    \ {'sync': v:false, 'name': '_deoplete_init', 'opts': {}, 'type': 'function'},
    \ ])
