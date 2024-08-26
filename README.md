![Build](https://img.shields.io/github/actions/workflow/status/kerryb/wx_ex/elixir.yml)

# WxEx

Elixir wrappers for the erlang macros in the `wx` package.

this library doesn’t wrap any of `wx`’s functions, but exposes the macros for
constants like `?wxAll` as normal elixir functions (it’s not possible to call
Erlang macros from Elixir code).

## Installation

Add `wx_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wx_ex, "~> 0.1.0", github: "kerryb/wx_wx"}
  ]
end
```

## Usage

```elixir
import Bitwise
import WxEx.Constants

panel = :wxPanel.new(frame)
label = :wxStaticText.new(panel, wxID_ANY(), "A label", style: wxALIGN_RIGHT())
sizer = :wxBoxSizer.new(wxHORIZONTAL())
:wxSizer.add(sizer, label, flag: wxALL() ||| wxALIGN_CENTRE(), border: 5)

 # etc
 ```
