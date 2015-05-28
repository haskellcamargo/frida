#!/usr/bin/env node

require! <[ fs repl ../compiler/frida ../compiler/syn ]>


args = require \optimist
  .usage "Usage: $0 -vlp [filename]"
  .describe "p" "prints parsed code and exits"
  .describe "v" "prints the version and exits"
  .describe "h" "prints this help and exits"
  .describe "l" "uses util.inspect for return values instead of syntax" +
    "converter for REPL"

argv = args.argv

if argv.h
  args.show-help!
  process.exit!

if argv.v
  console.log "frida " + (require "../package.json").version
  process.exit!

if argv._.length > 0
  code = fs.read-file-sync argv._.0, encoding: \utf8
  if not argv.p
    frida.interpret frida.parse code
  else
    console.log frida.parse code
else
  context = new frida.Context
  cmdc = 0
  cmdln = ""
  repl.start {
    prompt: "frida> ",
    "eval": (cmd, context, filename, callbac) !->
      if cmd isnt "(\n)"
        cmd = cmd.slice 1 -1
        cmdc += syn.verify frida.tokenize cmd

        process.exit! if cmdc < 0

        if cmdc isnt 0
          cmdln += cmd
          return callback cmdc
        
        else if not argv.p
            cmd := cmdln + cmd
            cmdln := ""
            return if argv.l
                   then callback null, frida.interpret frida.parse cmd, context
                   else "=> " + syn.convert frida.interpret frida.parse cmd,
                    context
        else
          return callback null, frida.parse cmd

      else
        return callback null, (if cmdc > 0 then cmdc)
  }