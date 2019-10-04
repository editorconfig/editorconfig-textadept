# EditorConfig Plugin for Textadept

This is an [EditorConfig] plugin for [Textadept].

## Installation

1. You'll need the [EditorConfig Lua Core]. It can be installed using
[LuaRocks] with the following command:

        luarocks install editorconfig-core

You may need to set `TA_LUA_CPATH` if using LuaRocks. This can be done for
example by adding to your environment:

        export TA_LUA_CPATH=";;$(luarocks path --lr-cpath)"


2. Install the `editorconfig.lua` module to your Textadept `_USERHOME`.

        cd ~/.textadept
        mkdir -p modules/textadept/editing
        cp /path/to/editorconfig.lua modules/textadept/editing
        echo "require(\"textadept.editing.editorconfig\")" >> init.lua

Check the [manual] for further information about module installation and how
to configure Textadept.

## Supported Properties

The Textadept EditorConfig plugin supports the following EditorConfig
[properties]:

* indent_style
* indent_size
* tab_width
* end_of_line
* charset
* trim_trailing_whitespace
* insert_final_newline

[EditorConfig]: http://editorconfig.org
[EditorConfig Lua Core]: https://github.com/editorconfig/editorconfig-core-lua
[properties]: http://editorconfig.org/#supported-properties
[LuaRocks]: https://luarocks.org/
[Textadept]: https://foicica.com/textadept
[manual]: https://foicica.com/textadept/manual.html#Modules
