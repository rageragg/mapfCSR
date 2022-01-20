create or replace package json_ext as

  /*
  || SOFTWARE FACTORY 11/01/2012
  || PAQUETES UTILITARIOS PARA USO DE LA WEB
  */

  /*
  Copyright (c) 2009 Jonas Krogsboell

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */

  /* This package contains extra methods to lookup types and
     an easy way of adding date values in json - without changing the structure */
  function parsePath(json_path varchar2, base number default 1) return json_list;

  --JSON Path getters
  function get_json_value(obj json, v_path varchar2, base number default 1) return tron2000.json_value_web;
  function get_string(obj json, path varchar2,       base number default 1) return varchar2;
  function get_number(obj json, path varchar2,       base number default 1) return number;
  function get_json(obj json, path varchar2,         base number default 1) return json;
  function get_json_list(obj json, path varchar2,    base number default 1) return json_list;
  function get_bool(obj json, path varchar2,         base number default 1) return boolean;

  --JSON Path putters
  procedure put(obj in out nocopy json, path varchar2, elem varchar2,   base number default 1);
  procedure put(obj in out nocopy json, path varchar2, elem number,     base number default 1);
  procedure put(obj in out nocopy json, path varchar2, elem json,       base number default 1);
  procedure put(obj in out nocopy json, path varchar2, elem json_list,  base number default 1);
  procedure put(obj in out nocopy json, path varchar2, elem boolean,    base number default 1);
  procedure put(obj in out nocopy json, path varchar2, elem tron2000.json_value_web, base number default 1);

  procedure remove(obj in out nocopy json, path varchar2, base number default 1);

  --Pretty print with JSON Path - obsolete in 0.9.4 - obj.path(v_path).(to_char,print,htp)
  function pp(obj json, v_path varchar2) return varchar2;
  procedure pp(obj json, v_path varchar2); --using dbms_output.put_line
  procedure pp_htp(obj json, v_path varchar2); --using htp.print

  --extra function checks if number has no fraction
  function is_integer(v tron2000.json_value_web) return boolean;

  format_string varchar2(30 char) := 'yyyy-mm-dd hh24:mi:ss';
  --extension enables json to store dates without comprimising the implementation
  function to_json_value(d date) return tron2000.json_value_web;
  --notice that a date type in json is also a varchar2
  function is_date(v tron2000.json_value_web) return boolean;
  --convertion is needed to extract dates
  --(json_ext.to_date will not work along with the normal to_date function - any fix will be appreciated)
  function to_date2(v tron2000.json_value_web) return date;
  --JSON Path with date
  function get_date(obj json, path varchar2, base number default 1) return date;
  procedure put(obj in out nocopy json, path varchar2, elem date, base number default 1);

  --experimental support of binary data with base64
  function base64(binarydata blob) return json_list;
  function base64(l json_list) return blob;

  function encode(binarydata blob) return tron2000.json_value_web;
  function decode(v tron2000.json_value_web) return blob;

end json_ext;
