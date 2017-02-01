/**
 * Copyright (c) 2012, Aaron Dixon
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright notice, this list
 *       of conditions and the following disclaimer.
 *
 *     * Redistributions in binary form must reproduce the above copyright notice,
 *       this list of conditions and the following disclaimer in the documentation
 *       and/or other materials provided with the distribution.
 *
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */
parser grammar STParser;

options {
    output = AST;
    tokenVocab = STLexer;
    memoize=true;
}

tokens {
ESTACK;
EXC;
MSG;
MSGSTR;
ATS;
CAUSE;
MORE;
CLS;
CNAME;
METH;
MNAME;
LOC;
THR;
TNAME;
PRELIM;
LOCATION;
}

@header {
package com.jmolly.stacktraceparser.internal;
}

estack: prelim atlines (NEWLINE cause)? EOF
-> ^(ESTACK prelim atlines cause?);

prelim: (EIT WS threadname WS)? (classname WS?)? message?
-> ^(PRELIM ^(THR threadname?) ^(EXC ^(CLS classname?) ^(MSG message?)));

threadname: ((QS)=> QS | .*) -> {new CommonTree(new CommonToken(TNAME,$threadname.text))};
atlines
@init { consumeUntil(input, AT); }
: (atline WS? NEWLINE?)+ -> ^(ATS atline*);
atline: AT WS methodadress location? -> ^(AT ^(METH methodadress) ^(LOC location?));

location: LP sourcefileandlinenumber RP
 -> {new CommonTree(new CommonToken(LOCATION,$sourcefileandlinenumber.text))};
sourcefile: (NMETH|UNSRC|identifier (DOT fileext)?);
linenumber: COLON NUMBER;
sourcefileandlinenumber: sourcefile linenumber?;

cause: CB WS classname WS? message? atlines (moreline)? (NEWLINE cause)?
-> ^(CAUSE ^(EXC ^(CLS classname) ^(MSG message?)) atlines ^(MORE moreline?) cause?);

moreline: ELLIPSIES WS NUMBER WS MORE;

message: COLON (options {greedy=false;}:.)*
 -> {new CommonTree(new CommonToken(MSGSTR,$message.text))};

classname: (identifier DOT)* identifier (DOLL identifier)?
 -> {new CommonTree(new CommonToken(CNAME,$classname.text))};
methodadress: (identifier DOT)* identifier (DOLL identifier)? DOT (identifier|INIT|CLINIT)
 -> {new CommonTree(new CommonToken(MNAME,$methodadress.text))};

identifier: (IDENTIFIER|AT|IN|MORE|JAVA);
fileext: identifier;