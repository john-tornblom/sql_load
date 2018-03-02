.include "tools.arc"
.select many r_rels from instances of R_REL
.for each r_rel in r_rels
    .select one r_super related by r_rel->R_SUBSUP[R206]->R_SUPER[R212]
    .select one r_sub related by r_rel->R_SUBSUP[R206]->R_SUB[R213]
    .select one r_part related by r_rel->R_SIMP[R206]->R_PART[R207]
    .select one r_form related by r_rel->R_SIMP[R206]->R_FORM[R208]
    .//
    .select any o_obj_from from instances of O_OBJ where (false)
    .select any o_obj_to from instances of O_OBJ where (false)
    .assign phrase = ""
    .//
    .if ((not_empty r_part) and (not_empty r_form))
      .select any o_obj_from from instances of O_OBJ where (selected.Obj_ID == r_form.Obj_ID)
      .select any o_obj_to from instances of O_OBJ where (selected.Obj_ID == r_part.Obj_ID)
      .assign phrase = r_form.Txt_Phrs
    .//
    .elif ((not_empty r_super) and (not_empty r_sub))
      .select any o_obj_from from instances of O_OBJ where (selected.Obj_ID == r_super.Obj_ID)
      .select any o_obj_to from instances of O_OBJ where (selected.Obj_ID == r_sub.Obj_ID)
    .//
    .end if
    .if ((not_empty o_obj_from) and (not_empty o_obj_to))
      .invoke from_key = find_lookup_key(o_obj_from)
      .invoke to_key = find_lookup_key(o_obj_to)
      .if ((from_key.name != "") and (to_key.name != ""))
if param.rel_id == "R${r_rel.Numb}" and param.from_key_letter == "${o_obj_from.Key_Lett}" and param.to_key_letter == "${o_obj_to.Key_Lett}"
    select any from_inst from instances of ${o_obj_from.Key_Lett} where (selected.${from_key.name} == param.from_id);
    select any to_inst from instances of ${o_obj_to.Key_Lett} where (selected.${to_key.name} == param.to_id);
        .if (phrase != "")
    relate from_inst to to_inst across R${r_rel.Numb}.'${phrase}';
        .else
    relate from_inst to to_inst across R${r_rel.Numb};
        .end if
end if;
      .end if
    .end if
.end for