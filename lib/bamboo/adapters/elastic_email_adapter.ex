defmodule Bamboo.ElasticEmailAdapter do
  @moduledoc """
  Send emails using ElasticEmail's REST API

  ## Example

      # config/config.exs
      config :my_app, MyApp.Mailer,
        adapter: Bamboo.ElasticEmailAdapter,
        api_key: "my_api_key"

      # lib/my_app/mailer.ex
      defmdoule MyApp.Mailer do
        use Bamboo.Mailer, otp_app: :my_app
      end
  """

  @host "https://api.elasticemail.com"
  @path "v2/email/send"

  @behaviour Bamboo.Adapter

  def deliver(email, config) do
    url = build_req_url(email, config)
    query_params = build_query_params(email, config)
    headers = build_req_headers(email, config)
    case :hackney.get(url, headers, query_params) do
      {:ok, status, _, response} when status > 299 ->
        raise "Received non-200 status code: #{inspect status}, #{inspect response}"

      {:ok, status, headers, response} ->
        %{status_code: status, headers: headers, body: response}

      {:error, reason} ->
        raise "Hackney error: #{inspect reason}"
    end
  end

  def handle_config(config) do
    if Map.has_key?(config, :api_key) do
      config
    else
      raise "api_key is required in config, got #{inspect config}"
    end
  end

  defp build_req_url(_email, _config) do
    Path.join(@host, @path)
  end

  defp build_req_headers(_email, _config) do
    [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]
  end

  defp build_query_params(email, config) do
    params =
      %{}
      |> add_api_key(config)
      |> add_body_html(email)
      |> add_body_text(email)
      |> add_to(email)
      |> add_from(email)
      |> add_from_name(email)
      |> add_msg_bcc(email)
      |> add_msg_cc(email)
      |> add_subject(email)

    URI.encode_query(params)
  end

  defp add_api_key(params, %{api_key: api_key}) do
    put_in(params[:apiKey], api_key)
  end

  defp add_body_html(params, %{html_body: html_body}) do
    put_in(params[:bodyHtml], html_body)
  end

  defp add_body_text(params, %{text_body: text_body}) do
    put_in(params[:bodyText], text_body)
  end

  defp add_to(params, %{to: to}) do
    address_list = parse_address_list(to)
    recipients =
      address_list
      |> Enum.map(fn %{address: address} -> address end)
      |> Enum.join(",")
    Map.merge(params, %{to: recipients})
  end

  defp add_from(params, %{from: from}) do
    case parse_address_list(from) do
      [%{address: address}|_] -> Map.merge(params, %{from: address})
      [] -> params
    end
  end

  defp add_from_name(params, %{from: from}) do
    case parse_address_list(from) do
      [%{name: name}|_] when not is_nil(name) -> Map.merge(params, %{fromName: name})
      _ -> params
    end
  end

  defp add_msg_bcc(params, %{bcc: bcc}) do
    case parse_address_list(bcc) do
      [head|_] -> Map.merge(params, %{msgBcc: head.address})
      [] -> params
    end
  end

  defp add_msg_cc(params, %{cc: cc}) do
    case parse_address_list(cc) do
      [head|_] -> Map.merge(params, %{msgCc: head.address})
      [] -> params
    end
  end

  defp add_subject(params, %{subject: subject}) do
    Map.merge(params, %{subject: subject})
  end

  defp parse_address_list(nil) do
    []
  end

  defp parse_address_list(addresses) when is_list(addresses) do
    Enum.map(addresses, fn addr -> parse_address(addr) end)
  end

  defp parse_address_list(address) do
    [parse_address(address)]
  end

  defp parse_address({name, address}) do
    %{name: name, address: address}
  end

  defp parse_address(address) do
    %{name: nil, address: address}
  end
end
