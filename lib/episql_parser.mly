/* Copyright (C) 2014  Petter Urkedal <paurkedal@gmail.com>
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or (at your
 * option) any later version, with the OCaml static compilation exception.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

%{
  open Episql_types
%}

/* Operators and special */
%token COMMA DOT EOF SEMICOLON LPAREN RPAREN

/* Keywords */
%token AS CREATE DEFAULT ENUM KEY NOT NULL
%token PRIMARY REFERENCES UNIQUE SCHEMA TABLE TYPE

/* Types */
%token CHAR VARCHAR TEXT
%token SMALLINT INTEGER BIGINT SMALLSERIAL SERIAL BIGSERIAL
%token NUMERIC DECIMAL

/* Literals */
%token<string> IDENTIFIER
%token<int> INT
%token<string> STRING

%type<Episql_types.statement list> schema
%start schema
%%

schema: statements EOF { List.rev $1 }

statements:
    /* empty */ { [] }
  | statements statement SEMICOLON { $2 :: $1 }
  ;

statement:
    CREATE SCHEMA IDENTIFIER { Create_schema $3 }
  | CREATE TABLE qname LPAREN table_items RPAREN
    { Create_table ($3, List.rev $5) }
  | CREATE TYPE qname AS ENUM LPAREN enum_cases RPAREN
    { Create_enum ($3, $7) }
  ;

table_items: /* empty */ { [] } | nonempty_table_items { $1 };
nonempty_table_items:
    table_item { [$1] }
  | table_items COMMA table_item { $3 :: $1 }
  ;
table_item:
    IDENTIFIER datatype column_constraints { Column ($1, $2, List.rev $3) }
  | table_constraint { Constraint $1 }
  ;
column_constraints:
    /* empty */ { [] }
  | column_constraints column_constraint { $2 :: $1 }
  ;
column_constraint:
    NOT NULL { `Not_null }
  | NULL { `Null }
  | UNIQUE { `Unique }
  | PRIMARY KEY { `Primary_key }
  | DEFAULT literal { `Default $2 }
  | REFERENCES qname { `References ($2, None) }
  | REFERENCES qname LPAREN qname RPAREN { `References ($2, Some $4) }
  ;
table_constraint:
    UNIQUE LPAREN nonempty_column_names RPAREN { `Unique (List.rev $3) }
  ;

nonempty_column_names:
    IDENTIFIER { [$1] }
  | nonempty_column_names COMMA IDENTIFIER { $3 :: $1 }
  ;

enum_cases:
    STRING { [$1] }
  | enum_cases COMMA STRING { $3 :: $1 }
  ;

qname:
    IDENTIFIER { (None, $1) }
  | IDENTIFIER DOT IDENTIFIER { (Some $1, $3) }
  ;
datatype:
    VARCHAR LPAREN INT RPAREN { `Varchar $3 }
  | CHAR LPAREN INT RPAREN { `Char $3 }
  | TEXT { `Text }
  | SMALLINT { `Smallint }
  | INTEGER { `Integer }
  | BIGINT { `Bigint }
  | SMALLSERIAL { `Smallserial }
  | SERIAL { `Serial }
  | BIGSERIAL { `Bigserial }
  | NUMERIC LPAREN INT COMMA INT RPAREN { `Numeric ($3, $5) }
  | DECIMAL LPAREN INT COMMA INT RPAREN { `Decimal ($3, $5) }
  | qname { `Custom $1 }
  ;
literal:
    INT { Lit_integer $1 }
  | STRING { Lit_text $1 }
  ;
