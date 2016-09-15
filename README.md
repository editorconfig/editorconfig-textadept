# EditorConfig Plugin for Textadept

This is an [EditorConfig][] plugin for [Textadept][].

## Installation

### Install From source

1.  Install the [EditorConfig Lua Core][]. Simply run the follow command to install:

        luarocks install editorconfig-core

2.  Install the `editorconfig.lua` module to your Textadept `_USERHOME`.

        cd ~/.textadept
        mkdir -p modules/textadept/editing
        cp /path/to/editorconfig.lua modules/textadept/editing
        echo "require(\"textadept.editing.editorconfig\").enable()" >> init.lua

    Check the [Manual][] for further information about module installation and how to configure Textadept.

## Supported Properties

The Textadept EditorConfig plugin supports the following EditorConfig
[properties][]:

* indent_style
* indent_size
* tab_width
* end_of_line
* charset

[EditorConfig]: http://editorconfig.org
[EditorConfig Lua Core]: https://github.com/randstr/editorconfig-core-lua
[properties]: http://editorconfig.org/#supported-properties
[Textadept]: https://foicica.com/textadept
[Manual]: https://foicica.com/textadept/manual.html#Modules
