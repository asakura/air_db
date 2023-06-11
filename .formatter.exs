[
  import_deps: [:ecto, :stream_data],
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "priv/repo/*.{exs}",
    "priv/examples/*.exs"
  ],
  subdirectories: ["priv/*/migrations", "priv/repo"]
]
