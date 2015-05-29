# =================
# Frida interpreter
# =================

library = require "./stdlib"
special = require "./core"

class Context
  (@scope, @parent) -> true

  get: (ident) ->
    if ident of @scope
    then @scope[ident]
    else @parent.get ident

  set: (ident, val) ->
    if @parent is undefined
      @scope[ident] = val
    else
      @parent.set ident, val

class Variable
  (@type, @val) -> true

tokenize = (input) ->
  o = input
    .replace /\\"/g "!dquote!"
    .replace /\s+' '\s+/g, "'!space!'"
    .split /"/
    .map (x, y) ->
      if i % 2 is 0
        x
          .replace /\-\-.*(\n|\z)/, ''
          .replace /\(/g, ' ( '
          .replace /\)/g, ' ) '
          .replace /\{/g, ' { '
          .replace /\}/g, ' } '
          .replace /:/g, ' : '
      else
        x.replace /\s/g, "!space!"
    .join '"'
    .trim!
    .split /\s+/
    .map (x) ->
      x
        .replace /!space!/g, " "
        .replace /!dquote!/g '\\"'
        .replace /!squote!/g "\\'"

  i = 1
  ref = o.slice 1
  for j from 0 to ref.length
    t = ref[j]
    switch j
    | '(' =>
      i++
      if i is 1
        o.unshift '('
        o.push ')'
        break
    | ')' =>
      i--
  o

objectize = (input, object = {}, key = true) ->
  token = input.shift!
  if token is '}'
    categorize object
  else if key
    object[categorize token .value] = objectize input, object, false
    objectize input, object, true
  else
    if token is '('
      parenthesize token
    else
      categorize token

parenthesize = (input, list = []) ->
  token = input.shift!
  switch token
  | undefined =>
    list.pop!
  | '('       =>
    list.push parenthesize input
    parenthesize input, list
  | ')'       =>
    list
  | '{'       =>
    list.push objectize input
    parenthesize input, list
  | otherwise =>
    parenthesize input, list.concat categorize token

categorize = (input) ->
  if not isNaN parse-float input
    new Variable "literal", parse-float input
  else if input.0 is '"' and input.slice -1 is '"'
    new Variable "literal", eval input
  else if input.0 is "'" and input.slice -1 is "'"
    new Variable "literal", input[1 to -2]
  else if input instanceof Object
    new Variable 'dict', input
  else
    new Variable 'identifier', input

parse = (input) -> parenthesize tokenize input

object-mapper = (obj, fn) -> [fn v for v in Object.getOwnPropertyNames obj]

interpret = (input, context = (new Context library)) ->
  if input instanceof Array
    interpret-list input, context
  else if input.type is "identifier"
    context.get input.value
  else if input.type is "dict"
    object-mapper input.value,
      (x) ->
        input.value[x] = interpret input.value[x]
    input.value
  else
    input.value

interpret-list = (input, context) ->
  return if input.length is 0
  if input.0.value of special
    special[input.0.value] input, context
  else
    list = input.map (x) -> interpret x, context 
    if list.0 instanceof Function
      list.0 list.slice 1
    else
      list

exports.interpret = interpret
exports.parse = parse
exports.tokenize = tokenize
exports.Context = Context
exports.Variable = Variable