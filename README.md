[![Hex.pm](https://img.shields.io/hexpm/v/wx_ex)](https://hex.pm/packages/wx_ex)
[![Hexdocs.pm](https://img.shields.io/badge/docs-hexdocs.pm-purple)](https://hexdocs.pm/wx_ex/readme.html)
[![Build](https://img.shields.io/github/actions/workflow/status/kerryb/wx_ex/elixir.yml)](https://github.com/kerryb/wx_ex/actions/workflows/elixir.yml)

Elixir wrappers for the Erlang macros and records in the `wx` package.

This library doesn’t wrap any of `wx`’s functions, but exposes the macros for
constants like `?wxAll` and `?GL_POINT` as normal Elixir functions (it’s not
possible to call Erlang macros from Elixir code). It also provides Elixir
`Record` types for the Erlang records in the `:wx` package.

## Installation

Add `wx_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wx_ex, "~> 0.5.0"}
  ]
end
```

## Usage

The simplest way to import all the definitions is to simply `use WxEx`.

If you don’t want to pull everything into your global namespace, you can import
the invidual module(s) you need, or simply call the functions directly, eg
`WxEx.Constants.WxWidgets.wxALIGN_RIGHT()`.

### Constants

```elixir
use WxEx
import Bitwise # to allow ORing of flags with |||

panel = :wxPanel.new(frame)
label = :wxStaticText.new(panel, wxID_ANY(), "A label", style: wxALIGN_RIGHT())
sizer = :wxBoxSizer.new(wxHORIZONTAL())
:wxSizer.add(sizer, label, flag: wxALL() ||| wxALIGN_CENTRE(), border: 5)

# etc
```

### Records

```elixir
use WxEx

event = wx() #=> {:wx, :undefined, :undefined, :undefined, :undefined}
wx(event) #=> [id: :undefined, obj: :undefined, userData: :undefined, event: :undefined]
```

## Development

This library depends on `wx_ex_compiler`, which generates source files and was
extracted to avoid circular compiler dependencies.
