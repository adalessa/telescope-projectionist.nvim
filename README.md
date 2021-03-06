# telescope-projectionist.nvim
`telescope-projectionist.nvim` is an extension for telescope that works with `tpope/vim-projectionist` [plugin](https://github.com/tpope/vim-projectionist).
It will list all the types, once selected will return the files of that type. If the file does not exists
using the Keymap `<C-y>` will create the file with the provided name
This plugin is in an `alpha` state, a lot of improvements can be done.

# Why this plugin?
Projectionist plugin is great but just adding a keybinding for each type is not the best, so extending telescope makes a lot
of sense for me.

# Install
using plugin manager as packer
```
use adalessa/telescope-projectionist.nvim
```

# Config
After the setup of telescope add this into the lua file
```
require("telescope").load_extension "projectionist"
```

Invoke using `:Telescope projectionist`

Adding a keybinding use

```
nnoremap <leader>fp :Telescope projectionist<CR>
```

# Contributing
All contributions are appreciated, just be nice.
