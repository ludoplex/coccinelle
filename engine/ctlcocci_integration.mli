open Common
open Ograph_extended 


val labels_for_ctl :
  (nodei * Control_flow_c.node) list ->
  (Lib_engine.predicate ->
   (nodei * 
    (Lib_engine.mvar, Lib_engine.metavar_binding_kind2) Ast_ctl.generic_substitution)
   list)

val model_for_ctl :
  (Control_flow_c.node, Control_flow_c.edge) ograph_extended -> 
   (Control_flow_c.node, Control_flow_c.edge) ograph_extended *
   (Lib_engine.predicate ->
    (nodei * (Lib_engine.mvar, Lib_engine.metavar_binding_kind2) Ast_ctl.generic_substitution)
    list) *
   nodei list

