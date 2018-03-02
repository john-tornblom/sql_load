.include "tools.arc"
.select many r_rels from instances of R_REL
.for each r_rel in r_rels
    .select one r_aone related by r_rel->R_ASSOC[R206]->R_AONE[R209]
    .select one r_aoth related by r_rel->R_ASSOC[R206]->R_AOTH[R210]
    .select one r_assr related by r_rel->R_ASSOC[R206]->R_ASSR[R211]
    .//
    .if (not_empty r_assr)
      .select any o_obj_from from instances of O_OBJ where (selected.Obj_ID == r_aone.Obj_ID)
      .select any o_obj_to from instances of O_OBJ where (selected.Obj_ID == r_aoth.Obj_ID)
      .select any o_obj_using from instances of O_OBJ where (selected.Obj_ID == r_assr.Obj_ID)
      .invoke key_from = find_lookup_key(o_obj_from)
      .invoke key_to = find_lookup_key(o_obj_to)
      .invoke key_using = find_lookup_key(o_obj_using)
      .if ((key_from.name != "") and ((key_to.name != "") and (key_using.name != "")))
if param.rel_id == "R${r_rel.Numb}" and param.from_key_letter == "${o_obj_from.Key_Lett}" and param.to_key_letter == "${o_obj_to.Key_Lett}"
    select any from_inst from instances of ${o_obj_from.Key_Lett} where (selected.${key_from.name} == param.from_id);
    select any to_inst from instances of ${o_obj_to.Key_Lett} where (selected.${key_to.name} == param.to_id);
    select any using_inst from instances of ${o_obj_using.Key_Lett} where (selected.${key_using.name} == param.to_id);
        .if (r_aoth.Txt_Phrs != "")
    relate from_inst to to_inst across R${r_rel.Numb}.'${r_aoth.Txt_Phrs}' using using_inst;
        .else
    relate from_inst to to_inst across R${r_rel.Numb} using using_inst;
        .end if
end if;
      .end if
    .end if
.end for