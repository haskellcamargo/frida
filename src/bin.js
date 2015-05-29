#!/usr/bin/env node
var args, argv, cmdc, cmdln, code, context, fs, repl, syn, frida;
fs = require('fs');
repl = require('repl');
frida = require('../lib/frida');
syn = require('../lib/syn');

args = require('optimist')
  .usage('Usage: $0 -vlp [filename]')
  .describe('p', 'print parsed code and exit')
  .describe('v', 'print version and exit')
  .describe('h', 'print this help and exit')
  .describe('l', 'use util.inspect for return values instead of syntax converter for REPL');

argv = args.argv;

if (argv.h) {
  args.showHelp();
  process.exit();
}

if (argv.v) {
  console.log("frida " + (require('../package.json').version));
  process.exit();
}

if (argv._.length > 0) {
  code = fs.readFileSync(argv._[0], {
    encoding: 'utf8'
  });
  if (!argv.p) {
    frida.interpret(frida.parse(code));
  } else {
    console.log(frida.parse(code));
  }
} else {
  context = new frida.Context;
  cmdc = 0;
  cmdln = "";
  repl.start({
    prompt: '> ',
    "eval": function(cmd, context, filename, callback) {
      if (cmd !== '(\n)') {
        cmd = cmd.slice(1, -1);
        cmdc += syn.verify(frida.tokenize(cmd));
        if (cmdc < 0) {
          process.exit();
        }
        if (cmdc !== 0) {
          cmdln += cmd;
          return callback(cmdc);
        } else if (!argv.p) {
          cmd = cmdln + cmd;
          cmdln = "";
          if (argv.l) {
            return callback(null, frida.interpret(frida.parse(cmd, context)));
          } else {
            return callback('=> ' + syn.convert(frida.interpret(frida.parse(cmd, context))));
          }
        } else {
          return callback(null, frida.parse(cmd));
        }
      } else {
        return callback(null, (cmdc > 0 ? cmdc : void 0));
      }
    }
  });
}
