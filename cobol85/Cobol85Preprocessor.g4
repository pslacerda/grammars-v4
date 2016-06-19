/*
* Copyright (C) 2016, Ulrich Wolffgang <u.wol@wwu.de>
* All rights reserved.
*
* This software may be modified and distributed under the terms
* of the BSD 3-clause license. See the LICENSE file for details.
*/

/*
* Cobol 85 Preprocessor Grammar for ANTLR4
*
* This is a preprocessor grammar for Cobol 85.
*
* Change log:
*
* v1.4
*   - control spacing statements
*
* v1.2
*	- fixes
*
* v1.1
*	- fixes
*
* v1.0
*	- EXEC SQL
*	- EXEC CICS
*
* v0.9 Initial revision
*/

grammar Cobol85Preprocessor;

options
{
	language = Java;
}

startRule : (
	copyStatement
	| execCicsStatement
	| execSqlStatement
	| replaceOffStatement
	| replaceArea 
	| charData
	| controlSpacingStatement
)* EOF;


// exec cics statement

execCicsStatement :
	EXEC CICS cicsStatements END_EXEC DOT?
;

cicsStatements :
    (NEWLINE? cicsStatement NEWLINE?)+
    | charData*
;

cicsStatement :
     cicsLinkStatement

;

cicsName :
    cobolWord | STRINGLITERAL
;

cicsDataArea :
    cobolWord
;

cicsDataValue :
    cobolWord
    | NONNUMERICLITERAL
    | INTEGERLITERAL
    | LENGTH OF cobolWord
;

cicsSystemName :
    SYSTEMLITERAL
;

cicsLinkStatement :
    LINK
    PROGRAM LPARENCHAR cicsName RPARENCHAR
    (
        COMAREA LPARENCHAR cicsDataArea RPARENCHAR
        (LENGTH LPARENCHAR cicsDataValue RPARENCHAR)?
        (DATALENGTH LPARENCHAR cicsDataValue RPARENCHAR)?
        | CHANNEL LPARENCHAR cicsName RPARENCHAR
    )?
    (
        INPUTMSG LPARENCHAR cicsDataArea RPARENCHAR
        (INPUTMSGLEN LPARENCHAR cicsDataValue RPARENCHAR)?
        |(
            SYSID LPARENCHAR cicsSystemName RPARENCHAR
            | SYNCONRETURN
            | TRANSID LPARENCHAR cicsName RPARENCHAR
        )*
    )?
;

// exec sql statement

execSqlStatement :
	EXEC SQL charData END_EXEC DOT?
;


// copy statement

copyStatement :
	COPY copySource
	(NEWLINE* directoryPhrase)?
	(NEWLINE* familyPhrase)?
	(NEWLINE* replacingPhrase)?
	SUPPRESS?
	DOT
;

copySource : literal | cobolWord;

replacingPhrase :
	REPLACING NEWLINE* replaceClause (NEWLINE+ replaceClause)*
;


// replace statement

replaceArea : 
	replaceByStatement
	(copyStatement | charData)*
	replaceOffStatement?
;

replaceByStatement :
	REPLACE (NEWLINE* replaceClause)+ DOT
;

replaceOffStatement :
	REPLACE OFF DOT
;


replaceClause : 
	replaceable NEWLINE* BY NEWLINE* replacement
	(NEWLINE* directoryPhrase)? 
	(NEWLINE* familyPhrase)? 
;

directoryPhrase :
	(OF | IN) NEWLINE* (literal | cobolWord)
;

familyPhrase : 
	ON NEWLINE* (literal | cobolWord)
;

replaceable : literal | cobolWord | pseudoText | charDataLine;

replacement : literal | cobolWord | pseudoText | charDataLine;


controlSpacingStatement :
	SKIP1 | SKIP2 | SKIP3 | EJECT
;

// literal ----------------------------------

cobolWord : IDENTIFIER;

literal : NONNUMERICLITERAL;

stringLiteral : STRINGLITERAL ;

pseudoText : DOUBLEEQUALCHAR charData? DOUBLEEQUALCHAR;

charData : 
	(
		charDataLine
		| NEWLINE
	)+
;

charDataLine : 
	(
		charDataKeyword
		| cobolWord
		| literal
		| TEXT
		| DOT
	)+
;


// keywords ----------------------------------

charDataKeyword : 
	BY
	| IN
	| OF | OFF | ON
	| REPLACING
;


// lexer rules --------------------------------------------------------------------------------

// keywords
BY : B Y;
CHANNEL: C H A N N E L;
CICS : C I C S;
COMAREA: C O M A R E A;
COPY : C O P Y;
DATALENGTH: D A T A L E N G T H;
EJECT : E J E C T;
END_EXEC : E N D '-' E X E C;
EXEC : E X E C;
IN : I N;
INPUTMSG: I N P U T M S G;
INPUTMSGLEN: I N P U T M S G L E N;
LENGTH: L E N G T H;
LINK: L I N K;
OFF : O F F;
OF : O F;
ON : O N;
PROGRAM: P R O G R A M;
REPLACE : R E P L A C E;
REPLACING : R E P L A C I N G;
SKIP1 : S K I P '1';
SKIP2 : S K I P '2';
SKIP3 : S K I P '3';
SQL : S Q L;
SUPPRESS : S U P P R E S S;
SYNCONRETURN: S Y N C O N R E T U R N;
SYSID: S Y S I D;
TRANSID: T R A N S I D;


// symbols
COMMACHAR: '.';
COMMENTTAG : '>*';
DOT : '.';
DOUBLEEQUALCHAR : '==';
LPARENCHAR : '(';
MINUSCHAR : '-';
PLUSCHAR : '+';
RPARENCHAR : ')';


// literals
NONNUMERICLITERAL : STRINGLITERAL | HEXNUMBER;
NUMERICLITERAL : (PLUSCHAR | MINUSCHAR)? [0-9]* (DOT | COMMACHAR) [0-9]+ (('e' | 'E') (PLUSCHAR | MINUSCHAR)? [0-9]+)?;
INTEGERLITERAL : (PLUSCHAR | MINUSCHAR)? [0-9]+;

SYSTEMLITERAL:
    SYSTEMCHAR
    | SYSTEMCHAR SYSTEMCHAR
    | SYSTEMCHAR SYSTEMCHAR SYSTEMCHAR
    | SYSTEMCHAR SYSTEMCHAR SYSTEMCHAR SYSTEMCHAR
;

fragment HEXNUMBER :
	X '"' [0-9A-F]+ '"' 
	| X '\'' [0-9A-F]+ '\''
;

STRINGLITERAL :
	'"' (~["\n\r] | '""' | '\'')* '"' 
	| '\'' (~['\n\r] | '\'\'' | '"')* '\''
;

IDENTIFIER : [a-zA-Z0-9]+ ([-_]+ [a-zA-Z0-9]+)*;

SYSTEMCHAR: [A-Z0-9#$@];

// whitespace, line breaks, comments, ...
NEWLINE : '\r'? '\n' -> skip;
COMMENTLINE : COMMENTTAG ~('\n' | '\r')* -> channel(HIDDEN);
WS : [ \t\f;]+ -> channel(HIDDEN);
TEXT : ~('\n' | '\r');



// case insensitive chars
fragment A:('a'|'A');
fragment B:('b'|'B');
fragment C:('c'|'C');
fragment D:('d'|'D');
fragment E:('e'|'E');
fragment F:('f'|'F');
fragment G:('g'|'G');
fragment H:('h'|'H');
fragment I:('i'|'I');
fragment J:('j'|'J');
fragment K:('k'|'K');
fragment L:('l'|'L');
fragment M:('m'|'M');
fragment N:('n'|'N');
fragment O:('o'|'O');
fragment P:('p'|'P');
fragment Q:('q'|'Q');
fragment R:('r'|'R');
fragment S:('s'|'S');
fragment T:('t'|'T');
fragment U:('u'|'U');
fragment V:('v'|'V');
fragment W:('w'|'W');
fragment X:('x'|'X');
fragment Y:('y'|'Y');
fragment Z:('z'|'Z');