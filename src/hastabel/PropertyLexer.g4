lexer grammar PropertyLexer;

fragment SEP: [ \t\r\n]+;

L_PAREN: '(';
R_PAREN: ')';
L_BRAKT: '[';
R_BRAKT: ']';

TAG_EXISTING_KW: '(tag_existing' SEP;

IFF_OPERATOR_KW: '(iff' SEP;
AND_OPERATOR_KW: '(and' SEP;
OR_OPERATOR_KW: '(or' SEP;
NOT_OPERATOR_KW: '(not' SEP ;
IMPLIES_OPERATOR_KW: '(implies' SEP;

EQ_SPECIAL_PREDICATE_KW: '(eq' SEP;
REGEX_SPECIAL_PREDICATE_KW: '(string_matches' SEP;

EXISTS_OPERATOR_KW: '(exists' SEP;
FORALL_OPERATOR_KW: '(forall' SEP;

CTL_VERIFIES_OPERATOR_KW: '(CTL_verifies' SEP;

AX_OPERATOR_KW: '(AX' SEP;
EX_OPERATOR_KW: '(EX' SEP;
AG_OPERATOR_KW: '(AG' SEP;
EG_OPERATOR_KW: '(EG' SEP;
AF_OPERATOR_KW: '(AF' SEP;
EF_OPERATOR_KW: '(EF' SEP;
AU_OPERATOR_KW: '(AU' SEP;
EU_OPERATOR_KW: '(EU' SEP;

DEPTH_NO_PARENT_OPERATOR_KW: ('(NPB' | '(does_not_reach_parent_before') SEP;
DEPTH_NO_CHANGE_OPERATOR_KW: ('(NDCB' | '(does_not_change_depth_before') SEP;

WS: SEP;

ID: [a-zA-Z0-9_~]+;
STRING: '"' ~('\r' | '\n' | '"')* '"';

COMMENT: (';;'|'#require') .*? '\n' -> channel(HIDDEN);
