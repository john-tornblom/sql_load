#!/usr/bin/env python
# encoding: utf-8
# Copyright (C) 2018 John Törnblom
'''
'''
import os
import string
import logging
import xtuml
import bridgepoint
import rsl
import optparse
import sys

from bridgepoint import ooaofooa

from xtuml import navigate_one as one
from xtuml import navigate_many as many
from xtuml import where_eq as where
from xtuml import relate
from xtuml import unrelate


scriptdir = os.path.dirname(__file__) or '.'
arcdir = scriptdir + '/arc'
logger = logging.getLogger('gen_sql_instance_stream_provider')


def run_rsl(m, filename):
    rt = rsl.Runtime(m)
    tree = rsl.parse_file(filename)
    res = rsl.evaluate(rt, tree, [arcdir])
    return rt.buffer.getvalue()


gen_new = lambda m: run_rsl(m, arcdir + '/SQL_Instance_Stream.New.arc')
gen_connect = lambda m: run_rsl(m, arcdir + '/SQL_Instance_Stream.Connect.arc')
gen_connect_using = lambda m: run_rsl(m, arcdir + '/SQL_Instance_Stream.Connect_Using.arc')
gen_set_boolean = lambda m: run_rsl(m, arcdir + '/SQL_Instance_Stream.Set_Boolean.arc')
gen_set_integer = lambda m: run_rsl(m, arcdir + '/SQL_Instance_Stream.Set_Integer.arc')
gen_set_real = lambda m: run_rsl(m, arcdir + '/SQL_Instance_Stream.Set_Real.arc')
gen_set_string = lambda m: run_rsl(m, arcdir + '/SQL_Instance_Stream.Set_String.arc')
gen_set_unique_id = lambda m: run_rsl(m, arcdir + '/SQL_Instance_Stream.Set_Unique_Id.arc')


def mk_function(ep_pkg, **kwargs):
    m = xtuml.get_metamodel(ep_pkg)
    s_dt = m.select_any('S_DT', where(Name='void'))
    pe_pe = m.new('PE_PE', Visibility=True, type=1)
    s_sync = m.new('S_SYNC', **kwargs)
    s_sync.Suc_Pars = 1
    relate(pe_pe, s_sync, 8001)
    relate(pe_pe, ep_pkg, 8000)
    relate(s_dt, s_sync, 25)

    return s_sync


def mk_parameters(s_sync, **kwargs):
    m = xtuml.get_metamodel(s_sync)
    prev = None
    for name, s_dt in kwargs.items():
        s_sparm = m.new('S_SPARM', Name=name)
        relate(s_sparm, s_sync, 24)
        relate(s_sparm, s_dt, 26)
        relate(s_sparm, prev, 54, 'succeeds')
        prev = s_sparm
        
    
def main():
    parser = optparse.OptionParser(usage="%prog [options] <model_path> [another_model_path...]",
                                   formatter=optparse.TitledHelpFormatter())
                                   
    parser.set_description(__doc__.strip())
    
    parser.add_option("-o", "--output", dest='output', metavar="PATH",
                      help="save sql model instances to PATH",
                      action="store", default='/dev/stdout')
    
    parser.add_option("-v", "--verbosity", dest='verbosity', action="count",
                      help="increase debug logging level", default=2)
    
    (opts, args) = parser.parse_args()
    if len(args) == 0 or None in [opts.output]:
        parser.print_help()
        sys.exit(1)

    levels = {
              0: logging.ERROR,
              1: logging.WARNING,
              2: logging.INFO,
              3: logging.DEBUG,
    }
    logging.basicConfig(level=levels.get(opts.verbosity, logging.DEBUG))
    
    m1 = bridgepoint.load_metamodel(args, load_globals=True)
    m2 = ooaofooa.empty_model()
    
    dt_boolean = m2.select_any('S_DT', where(Name='boolean'))
    dt_integer = m2.select_any('S_DT', where(Name='integer'))
    dt_real = m2.select_any('S_DT', where(Name='real'))
    dt_string = m2.select_any('S_DT', where(Name='string'))
    dt_unique_id = m2.select_any('S_DT', where(Name='unique_id'))
    dt_void = m2.select_any('S_DT', where(Name='void'))
    
    pe_pe = m2.new('PE_PE', Visibility=True, type=7)
    ep_pkg = m2.new('EP_PKG', Name='SQL_Instance_Stream_Provider')
    relate(pe_pe, ep_pkg, 8001)
    
    s_sync = mk_function(ep_pkg, Name='SQL_Instance_Stream_Connect',
                         Action_Semantics_internal=gen_connect(m1))
    mk_parameters(s_sync, from_id=dt_unique_id, from_key_letter=dt_string,
                  to_id=dt_unique_id, to_key_letter=dt_string, rel_id=dt_string)
    
    s_sync = mk_function(ep_pkg, Name='SQL_Instance_Stream_Connect_Using',
                         Action_Semantics_internal=gen_connect_using(m1))
    mk_parameters(s_sync, from_id=dt_unique_id, from_key_letter=dt_string,
                  to_id=dt_unique_id, to_key_letter=dt_string, 
                  using_id=dt_unique_id, rel_id=dt_string)
    
    s_sync = mk_function(ep_pkg, Name='SQL_Instance_Stream_New',
                         Action_Semantics_internal=gen_new(m1))
    mk_parameters(s_sync, key_letter=dt_string)
    unrelate(s_sync, dt_void, 25)
    relate(s_sync, dt_unique_id, 25)
    
    s_sync = mk_function(ep_pkg, Name='SQL_Instance_Stream_Set_Boolean',
                         Action_Semantics_internal=gen_set_boolean(m1))
    mk_parameters(s_sync, key_letter=dt_string, instance_id=dt_unique_id,
                  name=dt_string, value=dt_boolean)
    
    s_sync = mk_function(ep_pkg, Name='SQL_Instance_Stream_Set_Integer',
                         Action_Semantics_internal=gen_set_integer(m1))
    mk_parameters(s_sync, key_letter=dt_string, instance_id=dt_unique_id,
                  name=dt_string, value=dt_integer)
    
    s_sync = mk_function(ep_pkg, Name='SQL_Instance_Stream_Set_Real',
                         Action_Semantics_internal=gen_set_real(m1))
    mk_parameters(s_sync, key_letter=dt_string, instance_id=dt_unique_id,
                  name=dt_string, value=dt_real)
    
    s_sync = mk_function(ep_pkg, Name='SQL_Instance_Stream_Set_String',
                         Action_Semantics_internal=gen_set_string(m1))
    mk_parameters(s_sync, key_letter=dt_string, instance_id=dt_unique_id,
                  name=dt_string, value=dt_string)
    
    s_sync = mk_function(ep_pkg, Name='SQL_Instance_Stream_Set_Unique_Id',
                         Action_Semantics_internal=gen_set_unique_id(m1))
    mk_parameters(s_sync, key_letter=dt_string, instance_id=dt_unique_id,
                  name=dt_string, value=dt_unique_id)
    
    ooaofooa.delete_globals(m2)
    
    with open(opts.output, 'w') as f:
        f.write('-- root-types-contained: Package_c\n')
        f.write('-- generics\n')
        f.write('-- BP 7.1 content: StreamData syschar: 3 persistence-version: 7.1.6\n')
        f.write(xtuml.serialize_instances(m2))


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    main()

