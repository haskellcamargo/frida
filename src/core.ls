require! frida

fns =
  lambda: (input, context) ->
    (lambda-args) ->
      lambda-scope =
        | input.length is 2 => {}
        | otherwise         =>
          input.1.reduce (acc, x, i) ->
            acc[x.value] = lambda-args[i]
            acc
          , x

      frida.interpret input[*-1], new frida.Context lambda-scope, context

  let: (input, context) ->
    let-context = input.1.reduce (acc, x) ->
      acc.scope[x.0.value] = frida.interpret x.1, context
      acc
    , new frida.Context {}, context

    frida.interpret input.2, let-context

  fn: (input, context) ->
    v = frida.interpret input.2
    context.set input.1.value, v
    v

  if: (input, context) ->
    if frida.interpret input.1
      frida.interpret input.2, context
    else
      frida.interpret input.3, context if input.2?

module.exports = fns
module.exports["~"] = fns.lambda