# ===========================
# Frida syntax helper library
# ===========================

{ map } = require "prelude-ls"

# Retrieves attribute names of an object.
object-mapper = (obj, fn) ->
  [fn v for v in Object.get-own-property-names obj]

# Takes any kind of input and attempts to return a string containing the frida
# syntax convention for that type of variable.
# For literal strings, returns the input with surrounding double quotes, but, if
# it's length of 1, it means it is a single character, then we return with
# single quotes.
# For numbers, cast it to a string, then return.
# For objects, convert values of object's attributes and return it with the
# proper syntax.
# For functions, return "(-> ...)" to prevent infinite loops. I don't thrust in
# programmers.
# For either null or undefined values, returns the proper literal.
# Otherwise, just cast the value to a string, then return it.
convert = (input) ->
  template = []
  if input instanceof Array
    template.push (input |> map convert).join ' '
    template.unshift '('
    template.push ')'
  else if typeof input is "string"
    template.push (if input.length is 1
            then "'#{input.replace /\n/g, '\\n'}'"
            else '"' + input.replace /\n/g, '\\n' + '"')
  else if typeof input is "function"
    template.push "(-> ...)"
  else if input instanceof Object
    acc = []
    object-mapper input, (x) -> acc.push "\"#{x}\":#{convert input[x]}"
    template.push acc.join ' '
    template.unshift '{'
    template.push '}'
  else if input is undefined
    template.push "undefined"
  else
    template.push input
  template.join ""

# Attempts to count the amount of open symbols to determine if they have been
# properly closed.
verify = (input) ->
  i = 0
  for x in input
    switch x
    | <[ ( { ]> => i++
    | <[ ) } ]> => i--
  i

exports
  ..verify = verify
  ..convert = convert