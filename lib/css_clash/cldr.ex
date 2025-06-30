defmodule CssClash.Cldr do
  use Cldr,
    locales: ["fr", "en"],
    providers: [Cldr.Number, Cldr.Calendar, Cldr.DateTime],
    gettext: CssClashWeb.Gettext
end
