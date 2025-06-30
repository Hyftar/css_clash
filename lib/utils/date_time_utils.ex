defmodule CssClash.Utils.DateTimeUtils do
  def format_date(date, format \\ "{YYYY}-{0M}-{0D}") do
    date
    |> Timex.to_date()
    |> Timex.format!(format)
  end

  def format_timestamp_to_local_datetime(nil), do: nil

  def format_timestamp_to_local_datetime(date, format \\ "{YYYY}-{0M}-{0D} {h24}h{m}") do
    date
    |> Timex.to_datetime()
    |> Timex.to_datetime(Application.get_env(:css_clash, :timezone))
    |> Timex.format!(format)
  end

  def format_timestamp_to_local_date(nil), do: nil

  def format_timestamp_to_local_date(date) do
    date
    |> Timex.to_datetime()
    |> Timex.to_datetime(Application.get_env(:css_clash, :timezone))
    |> Timex.to_date()
    |> Cldr.Date.to_string!(format: :long)
  end
end
