---
weight: 103
title: hyprlang
---

[hyprlang](https://github.com/hyprwm/hyprlang) is a library that implements parsing for the hypr configuration language.

## Syntax

### Line Style

Every config line is a command followed by a value.

```ini
COMMAND = VALUE
```

The command can be a variable, or a special keyword (those are defined by the app
you are using).

Variables are like "options", while keywords are like "commands".  
Options can be specified only once (if you do it more times, the previous one will be overwritten),
while commands invoke some behavior every time they are defined.

The trailing spaces at the beginning and end of words are not necessary, and are
there only for legibility.

### Categories

Categories can be regular, and "special".

Both are specified in the same way:

```ini
category {
    variable = value
}
```

Special categories can have other properties, like for example containing a key:

```ini
special {
    key = A
    variable = value
}
special {
    key = B
    variable = value
}
```

This is like defining two "groups", one with the key of A, another with B.  
Hyprland for example uses those for per-device configs.

### Defining variables

Variables can be defined like so:

```ini
$VAR = myData
```

Later on, you can use them like so:

```ini
$SUFFIX = -san
$NAME = Jeremy
greeting = Hello, $NAME$SUFFIX.
```

> [!NOTE]
> Spaces around or separating values are not mandatory

### Comments

Comments are started with the `#` character.

If you want to escape it (put an actual `#` and not start a comment) you can use `##`.  
It will be turned into a single `#` that _will_ be a part of your line.

### Escaping Errors

If you use plugins, you may want to ignore errors from missing options/keywords
so that you don't get an error bar before they are loaded. To do so, do this:

```ini
# hyprlang noerror true

bind = MOD, KEY, something, amogus
someoption = blah

# hyprlang noerror false
```

### Inline Options

If you want to specify an option inline, without opening and closing a category, use the `:` separator:

```ini
category:variable = value
```

If the category is special and requires a key, you can write:

```ini
category[keyvalue]:variable = value
```

This is the syntax used by `hyprctl keyword`, for example.

### Arithmetic Operations

Since 0.6.3, hyprlang supports _very_ basic arithmetic operations on variables using `{{}}`

You can use `+`, `-`, `*`, or `/`, on only _two_ variables (or constants) at a time.  
You _cannot_ nest them, but you can use intermittent variables.

Example:
```ini
$VAR1 = 2
$VAR2 = {{VAR1 + 3}}
$VAR3 = {{VAR2 * 2}}

someVariable = {{VAR3 / 2}}
someVariable2 = VAR3
```

This may throw some errors if done incorrectly. Make sure that:
- you only have two sides to the operation (**NOT** `{{a + b + c}}`, that has three)
- both sides either exist as numeric variables or are numeric themselves
- you have spaces around the operator (**NOT** `{{a+b}}`)

### Arithmetic Escaping

Since 0.6.4, hyprlang allows for escaping arithmetic expressions, e.g.`{{a + b}}`, by prefixing a `\`.  
They can be used on any of the starting positions of the expression braces.

Example:
```ini
$VAR = \{{10 + 10}}
bind = MOD, KEY, exec, COMMAND "{\{10 + 10}}"
someVariable = \{\{10 + 10}}
```

This will not evaluate the expression, and instead just assign the raw value you wrote verbatim.  
All of the `\` that were used to escape will be removed from the value as well.
So `\{{hello world}}` will turn into `{{hello world}}`, without trying to parse it as an expression.

### Escaping Escapes

Since 0.6.4, you can escape any `\` that would have been used to escape other characters.

For example, if you want to have a `\` before a real expression:

```ini
someVariable = \\{{VAR1 + 10}}
```

If you want to have an `\` before any of the escapable characters:

```ini
someOtherVariable = \\{ hello \\} 
```

### Conditionals

Since 0.6.4, you can add conditionals to your configs.  
You can make blocks conditional by using the `# hyprlang if` directive.

Some examples:

```ini
# hyprlang if MY_VAR

test = 24

# hyprlang endif

# hyprlang if !MY_VAR

test = 12

# hyprlang endif
```

> [!NOTE] Some important information
> - A variable is `true` if and only if it exists and is not an empty string.
> - Environment variables are supported.
> - Dynamic keywords (with `hyprctl keyword`) will **NOT** re-trigger or un-trigger these blocks.  
Changes need to be made to the files directly (or environment) and in the case of the latter, or a hypr* app that doesn't automatically reload its config, a relaunch of the app / `hyprctl reload` (for hl) will be required.

## Developer Documentation

See the documentation at [standards.hyprland.org/hyprlang](https://standards.hyprland.org/hyprlang/).
