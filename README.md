# vim-sql-suggest

Use the omnicomplete popup menu to explore and complete SQL table and column
names. The plugin currently supports `mysql` and `postgres` databases.

# The Plugin In Action

![sql-suggest](https://cloud.githubusercontent.com/assets/4416952/4486307/1e79a0d6-49df-11e4-9f42-8b9149d28297.gif)

## Usage

The plugin provides one function to call for completing tables and columns and
a convenience function for easily switching the database that suggestions are
provided for.

## Mapping The Functions

You will need to map the complete function in insert mode. Here is an example.
`<Leader>sc` will complete for columns and `<Leader>st` will complete for
tables.

``` vim
inoremap <Leader>sc <C-R>=SQLComplete("column")<CR>
inoremap <Leader>st <C-R>=SQLComplete("table")<CR>
```

## Default Database
You can set a default database by setting the variable `suggest_db` in your `.vimrc` like so:

``` vim
let g:suggest_db = "psql -U Jrock example_table"
```

You can also use the command `UpdateSuggestDB` to easily set the database that
the plugin will look in for completions.

## Installation

Use your plugin manager of choice.

- [Pathogen](https://github.com/tpope/vim-pathogen)
  - `git clone https://github.com/JarrodCTaylor/vim-sql-suggest ~/.vim/bundle/vim-sql-suggest`
- [Vundle](https://github.com/gmarik/vundle)
  - Add `Bundle 'JarrodCTaylor/vim-sql-suggest'` to .vimrc
  - Run `:BundleInstall`
- [NeoBundle](https://github.com/Shougo/neobundle.vim)
  - Add `NeoBundle 'JarrodCTaylor/vim-sql-suggest'` to .vimrc
  - Run `:NeoBundleInstall`
- [vim-plug](https://github.com/junegunn/vim-plug)
  - Add `Plug 'JarrodCTaylor/vim-sql-suggest'` to .vimrc
  - Run `:PlugInstall`
