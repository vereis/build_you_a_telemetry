# Build you a `:telemetry` for such learn!

This repo presents a minimal implementation of a `:telemetry` clone in Elixir.

You can view the [original implementation of the library here](https://github.com/beam-telemetry/telemetry).

The intention behind this repo is the serve as an artefact one can follow along
to alongside [this blog post](https://cbailey.co.uk/posts/build_you_a_telemetry_for_such_learn).

## Installation

If for some reason you want to use this library in your code, this package can be
installed by adding `build_you_a_telemetry` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:build_you_a_telemetry, "~> 0.1.0"}
  ]
end
```

## Usage

You can emit telemetry events in your business logic via:

```elixir
Telemetry.execute(
  [:web, :request, :done],
  %{latency: latency},
  %{request_path: request_path, status_code: status_code})
```

And you can implement handlers for these events via:

```elixir
defmodule Handler do
  def handle_event([:web, :request, :done], measurements, metadata, _config) do
    Logger.info("[#{metadata.request_path}] #{metadata.status_code} sent in #{measurements.latency}")
  end
end
```

Which need to be attached via:

```elixir
:ok = Telemetry.attach(
  "log-response-handler",
  [:web, :request, :done],
  &Handler.handle_event/4, nil
)
```

## Quickstart

The only dependency and requirement for this library is Elixir itself. This library
was developed with Elixir 1.10.4 so if anything doesn't work, it might be best to
try it out on that version.

I'll be looking at maintaining this library as time goes on and Elixir itself updates
and changes, but if you spot anything wrong feel free to send over a PR!

If you're a `nix` or `nixos` user, this repository contains a `shell.nix` file
which defines a development environment for you to use. Simply run `nix-shell` in
this directory to activate it. Moreover, if you are a `lorri` user, simple run
`direnv allow` and entering this project directory will activate this shell for you.
