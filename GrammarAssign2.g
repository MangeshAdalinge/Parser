grammar GrammarAssign2;

@header {
package Grammer;
    import java.util.HashMap;
    import java.util.*;
    import java.util.Scanner;
}

@lexer::header {
package Grammer;
}

@members {
HashMap memory = new HashMap();
}

program
  :
  statement+
  ;

statement
  :
  COMMENTS NEWLINE
  | 'INTEGER' integer NEWLINE
  | 'INPUT' input NEWLINE
  | 'LET' let NEWLINE
  | 'PRINT' print NEWLINE
  | 'PRINTLN' 
              {
               System.out.println();
              }
  print NEWLINE
  | 'END' 
          {
           System.exit(0);
          }
  ;


integer
  :
  identifier (',' identifier)*
  ;

identifier
  :
  ID 
     {
      Integer v = (Integer) memory.get($ID.text);
      if (v == null) {
      	memory.put($ID.text, new Integer(0));
      } else {
      	System.err.println("Variable is already is defined : " + $ID.text);
      	System.exit(0);
      }
     }
  ;

let
  :
  ID '=' expression 
              {
               Integer v = (Integer) memory.get($ID.text);
               
               if (v != null) {
               	memory.put($ID.text, new Integer($expression.value));
               } else {
               	System.err.println("Variable is not defined" + $ID.text);
               	System.exit(0);
               }
              }
  ;

input
  :
  inputidentifier (',' inputidentifier)*
  ;

inputidentifier
  :
  ID 
     {
      Integer v = (Integer) memory.get($ID.text);
      if (v != null) {
      	Scanner scanner = new Scanner(System.in);
      	System.out.println("Enter the value " + $ID.text + " : ");
      	Integer val = scanner.nextInt();
      	memory.put($ID.text, val);
      } else {
      	System.err.println("Variable is not defined : " + $ID.text);
      	System.exit(0);
      }
     }
  ;

expression returns [int value]
  :
  e=multExpr 
             {
              $value = $e.value;
             }
  (
    '+' e=multExpr 
                   {
                    $value += $e.value;
                   }
    | '-' e=multExpr 
                     {
                      $value -= $e.value;
                     }
  )*
  ;

multExpr returns [int value]
  :
  e=atom 
         {
          $value = $e.value;
         }
  (
    '*' e=atom 
               {
                $value *= $e.value;
               }
    | '/' e=atom 
                 {
                  $value /= $e.value;
                 }
  )*
  ;

atom returns [int value]
  :
  INT 
      {
       $value = Integer.parseInt($INT.text);
      }
  | ID 
       {
        Integer v = (Integer) memory.get($ID.text);
        if (v != null)
        	$value = v.intValue();
        else
        {
        	System.err.println("Variable is not defined " + $ID.text);
        	System.exit(0);
        }
       }
  | '(' e=expression ')' 
                   {
                    $value = $e.value;
                   }
  ;

print
  :
  expression 
       {
        System.out.print($expression.value);
       }
  | STRING 
           {
            System.out.print($STRING.text);
           }
  ;


ID
  :
  (
    'a'..'z'
    | 'A'..'Z'
  )
  (
    'a'..'z'
    | 'A'..'Z'
    | '0'..'9'
    | '_'
  )*
  ;

INT
  :
  '0'..'9'+
  ;

NEWLINE
  :
  '\r'? '\n'
  ;

WS
  :
  (
    ' '
    | '\t'
  )+
  
   {
    skip();
   }
  ;

STRING
  :
  '"'
  (
    ESC_SEQ
    |
    ~(
      '\\'
      | '"'
     )
  )*
  '"'
  ;

fragment
HEX_DIGIT
  :
  (
    '0'..'9'
    | 'a'..'f'
    | 'A'..'F'
  )
  ;

fragment
ESC_SEQ
  :
  '\\'
  (
    'b'
    | 't'
    | 'n'
    | 'f'
    | 'r'
    | '\"'
    | '\''
    | '\\'
  )
  | UNICODE_ESC
  | OCTAL_ESC
  ;

fragment
OCTAL_ESC
  :
  '\\' ('0'..'3') ('0'..'7') ('0'..'7')
  | '\\' ('0'..'7') ('0'..'7')
  | '\\' ('0'..'7')
  ;

fragment
UNICODE_ESC
  :
  '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
  ;

COMMENTS
  :
  '//'
  ~(
    '\n'
    | '\r'
   )*
  '\r'? '\n' 
             {
              $channel = HIDDEN;
             }
  | '/*' (options {greedy=false;}: .)* '*/' 
                                            {
                                             $channel = HIDDEN;
                                            }
  ;
