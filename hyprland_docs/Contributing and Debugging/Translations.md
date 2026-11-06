---
title: Translations
---

Some parts of the Hyprland ecosystem are localized. More and more are getting localization
frameworks. This is a short page showing how to contribute translations to Hyprland apps.

## Find the translation file

Here you'll find a list of translation files for hyprapps ready to translate:

- [hyprland](https://github.com/hyprwm/Hyprland/blob/main/src/i18n/Engine.cpp)
- [hyprlauncher](https://github.com/hyprwm/hyprlauncher/blob/main/src/i18n/Engine.cpp)
- [hyprpwcenter](https://github.com/hyprwm/hyprpwcenter/blob/main/src/i18n/Engine.cpp)

_more are coming, this list will be updated_

## Translate

Translations are in C++, but they are straightforward, and don't require much expertise.
You submit a translation via a traditional MR on Github.

### Basic translations (unconditional)

You register a translation for a key and your language code. For example, for key `TXT_KEY_HELLO`, and language
`pl_PL` (polish), you can:
```cpp
registerEntry("pl_PL", TXT_KEY_HELLO, "Siemka!");
```

Some translations have variables, included like so:
```cpp
registerEntry("pl_PL", TXT_KEY_HELLO, "Siemka, {name}!");
```

### Conditional translations

In some languages, you might want to change your translation based on e.g. the amount. (apple vs apples). In this
case, it's a bit more complicated, but it looks like this:

```cpp
registerEntry("pl_PL", TXT_KEY_HELLO, [](const Hyprutils::I18n::translationVarMap& vars) {
    int peopleAmount = std::stoi(vars.at("count"));
    if (peopleAmount == 1)
        return "Mam {count} dziewczynkę anime.";
    int last = peopleAmount % 10;
    int lastTwo = peopleAmount % 100;
    if (last >= 2 && last <= 4 && !(lastTwo >= 12 && lastTwo <= 14))
        return "Mam {count} dziewczynki anime.";
    return "Mam {count} dziewczynek anime.";
});
```

As you can see, you can change the returned string based on some variable. Please note all variables
are strings, so you need to call a standard function like `std::stoi` to obtain an integer.

### Fallbacks

In general, if you are translating into a language with regional variants, if the translations are the same,
you don't need two entries.

Order of fallbacks is as follows:

`xy_ZT` -> `xy_XY` -> `xy_ANYTHING` -> `global fallback`, usually `en_US`.

So, if you write something for `de_DE`, and the user has `de_AT`, if `de_AT` is missing,
`de_DE` will be used.
