# Bamboo.ElasticEmailAdapter

An [ElasticEmail](https://elasticemail.com/) adapter for the [Bamboo](https://github.com/thoughtbot/bamboo) email app.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `bamboo_elastic_email` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bamboo_elastic_email, github: "jbodah/bamboo_elastic_email"}
  ]
end
```

## Configuration

```ex
config :my_app, MyApp.Mailer,
  adapter: Bamboo.ElasticEmailAdapter,
  api_key: "my_api_key"
```

*Note:* As of writing this ElasticEmail does not support the "cc" field so it is merged into the ElasticEmail's "recipients"
