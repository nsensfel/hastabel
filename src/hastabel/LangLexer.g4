lexer grammar LangLexer;

@header {package hastabel;}

fragment SEP: [ \t\r\n]+;

L_PAREN: '(';
R_PAREN: ')';
L_BRAKT: '{';
R_BRAKT: '}';
COMMA: ',';
SUB_TYPE_OF: '::';
STAR: '*';

ADD_TYPE_KW: 'add_type' SEP;
ADD_PREDICATE_KW: 'add_predicate' SEP;
ADD_FUNCTION_KW: 'add_function' SEP;
ADD_TEMPLATE_KW: 'add_template' SEP;

WS: SEP;

ID: [a-zA-Z0-9_.]+;

STRING: '"' ~('\r' | '\n' | '"')* '"';

COMMENT: (';;'|'#'|'//'|'%') .*? '\n' -> channel(HIDDEN);
