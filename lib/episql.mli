(* Copyright (C) 2014--2018  Petter A. Urkedal <paurkedal@gmail.com>
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
 *)

open Episql_types

type dialect_tag = private [> `Mysql | `Pgsql | `Sqlite]
(** A type indicating how to interpret certain SQL code when implementations
    conflict.  This is the same as {!Caqti_driver_info.dialect_tag}. *)

val parse_file : ?dialect: dialect_tag -> string -> statement list

val string_of_datatype : datatype -> string

val string_of_qname : qname -> string

val qname_of_string : string -> qname

val string_of_expression : expression -> string

val string_of_column_constraint : column_constraint -> string

val string_of_interval_fields : interval_fields -> string

val autorec : (expression -> expression) -> expression -> expression

type generator = statement list -> out_channel -> unit

val find_generator : string -> generator * (Arg.key * Arg.spec * Arg.doc) list

val register_generator : ?arg_specs: (Arg.key * Arg.spec * Arg.doc) list ->
                         string -> generator -> unit

val generator_names : unit -> string list
