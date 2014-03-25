# Description:
#   Allows Hubot to roll dice usgin Invisible Castle grammar
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   =<x>d<y> - glory to the dice! Syntax ref: http://invisiblecastle.com/roller/
#
# Author:
#   vsh, illotum

PEG = require 'pegjs'

module.exports = (robot) ->
  robot.hear /\= *([0-9A-Za-z().+*\/-]+)/i, (msg) ->
    msg.reply parser.parse msg.match[1]


parser = PEG.buildParser '''
        {
          function makeBasicRoll(dice, size) {
            if(size<2) error("Dice size should be at least d2, not d" + size);
            if(dice<1) error("At least one die shold be rolled");

            roll_results = new Array(dice);
            for(i=0; i<dice; ++i) roll_results[i] = Math.floor(Math.random() * (size)) + 1;

            return { "result": roll_results, "verbose" : "[" + roll_results.join(", ") + "]" };

          }

          function isArray(value) {
            return Object.prototype.toString.call(value) === '[object Array]';
          }
          function sum(roll_result, args)
          {
            if( !isArray(roll_result.result) ) return roll_result;
            if( args.length ) error("sum takes no args");
            function sum_two(a, b) { return a+b; }
            if( roll_result.result.length == 0 ) roll_result.result = 0;
            else roll_result.result = roll_result.result.reduce(sum_two);
            return roll_result;
          }

          function takeSorted(array_to_sort, num_to_take, sort_fun)
          {
            if ( num_to_take >= array_to_sort.length) return array_to_sort;
            array_to_sort.sort(sort_fun);
            return array_to_sort.slice(0,num_to_take);
          }

          function checkTakeSorted(roll_result, args)
          {
            if(!isArray(roll_result.result)) error("takeHighest/Lowest should be applied to roll, not sum or hit count");
            if(args.length != 1) error("takeHighest/Lowest takes one argument, not " + args.length);
            num_to_take = args[0];
            if(num_to_take <= 0) error("takeHighest/Lowest takes only positive arguments");
          }

          function takeHighest(roll_result, args)
          {
            checkTakeSorted(roll_result, args);
            roll_result.result = takeSorted(roll_result.result, args[0],function(a,b){return b-a}) ;
            return roll_result;
          }
          function takeLowest(roll_result, args)
          {
            checkTakeSorted(roll_result, args);
            roll_result.result = takeSorted(roll_result.result, args[0],function(a,b){return a-b}) ;
            return roll_result;

          }
          function minroll(roll_result, args)
          {
            error("not implemented");
          }
          function extra(roll_result, args)
          {
            error("not implemented");
          }
          function open(roll_result, args)
          {
            error("not implemented");
          }
          function each(roll_result, args)
          {
            error("not implemented");
          }
          function hits(roll_result, args)
          {
            //error( !isArray(roll_result.result) );
            if( !isArray(roll_result.result) ) error( roll_result.verbose+" hits should be applied to roll, not sum or hit count");
            if(args.length != 1) error("hits takes one argument, not " + args.length);
            hit_difficulty = args[0];
            if(hit_difficulty <= 0) error("hits takes only positive arguments");
            roll_result.result = roll_result.result.filter(function(x){return x>=hit_difficulty;}).length;
            return roll_result;
          }
          function hitsopen(roll_result, args)
          {
            error("not implemented");
          }



          function applyFunction(roll_result, name, args) {
             function_table = { "sum" : sum, "takeHighest" : takeHighest, "takeLowest" : takeLowest, "hits" : hits };
             if (! (name in function_table) ) error("No function named " + name + ", possibe functions: ");
             to_return = function_table[name](roll_result, args);
             if(name != "sum" )
               to_return.verbose += "." + name + "(" + args.join(", ") + ")";
             return to_return;
          }


          function makeRollVerbose(json) {
            if ( json.roll.type == "basic_roll")
              roll_result = makeBasicRoll(json.roll.number, json.roll.size);
            else
              roll_result = makeRollVerbose(json.roll);
            return applyFunction( roll_result, json.function.name, json.function.args);
          }
        }




        start
          = ra:roll_additive { return ra.verbose + "=" + ra.result; }

        /*rolls & integer arithmetics [+-*] binary [-] unary */


        roll_additive
          = left:roll_multiplicative separator "+" separator right:roll_additive { return { "result" : left.result+right.result, "verbose" : left.verbose+"+"+right.verbose } ; }
          / left:roll_multiplicative separator "-" separator right:roll_additive { return { "result" : left.result-right.result, "verbose" : left.verbose+"-"+right.verbose } ; } / roll_multiplicative

        roll_multiplicative
          = separator left:roll_primary separator "*" separator right:roll_multiplicative { return { "result" : left.result*right.result, "verbose" : left.verbose+"*"+right.verbose }; }
          / separator rp:roll_primary separator { return rp; }

        roll_primary
         = roll_positive_primary / "-" prim:roll_positive_primary { prim.result = -1*prim.result; prim.verbose = "-"+prim.verbose; return prim; }

        roll_positive_primary
          = scalarized_roll / "(" separator roll_additive:roll_additive separator ")" { roll_additive.verbose = "(" +roll_additive.verbose +")"; return roll_additive; } / i:integer { return {"result" : i, "verbose" : i }; }


        /*rolls with functions*/

        scalarized_roll = rr:reduced_roll { return makeRollVerbose({ "type" : "roll_with_function", "roll" :  rr, "function": { "name": "sum", "args" : [] } }); }

        reduced_roll = rf: roll_with_function f:function { return { "roll": rf, "function" : f }; } / rf:roll_with_function

        roll_with_function
          = br:basic_roll f:function { return { "type" : "roll_with_function", "roll" : br, "function" : f } } / br:basic_roll

        basic_roll
          = left:number "d" right:size { return { "type" : "basic_roll", "number": left, "size": right } }

        number = integer

        size = integer


        /*basics*/
        function
          = function_start parts:function_part+ "(" args:function_arguments ")"
        {return { "name": parts.join(""), "args": args }; } / function_start parts:function_part+ "(" separator ")" {return { "name": parts.join(""), "args": [] }; }

        function_start = "."

        function_part = [a-zA-Z]

        function_arguments = arg:single_arg args:other_arg+ { return [arg].concat(args); } /  arg:single_arg { return [arg]; }

        other_arg = "," arg:single_arg { return arg; }

        single_arg = separator arg:basic_value separator { return arg; }

        basic_value = signed_integer / token

        signed_integer = integer / "-" i:integer { return -1*i; }

        integer "integer"
          = digits:[0-9]+ { return parseInt(digits.join(""), 10); }

        token "token" = token_part:[a-zA-Z]+ { return token_part.join(""); }

        separator = separator_symbols*

        separator_symbols "separator"  = [ \t]+
'''
