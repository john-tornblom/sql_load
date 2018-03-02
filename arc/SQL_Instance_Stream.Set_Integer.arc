.include "tools.arc"
.select any s_dt_param from instances of S_DT where (selected.Name == "integer")
.select many o_objs from instances of O_OBJ
.for each o_obj in o_objs
if param.key_letter == "${o_obj.Key_Lett}"
  .invoke key = find_lookup_key(o_obj)
  .if (key.name != "")
    .select many o_attrs related by o_obj->O_ATTR[R102]->O_BATTR[R106]->O_ATTR[R106]
    .for each o_attr in o_attrs
      .select one s_dt related by o_attr->S_DT[R114]
      .select one s_udt related by s_dt->S_UDT[R17]
      .while (not_empty s_udt)
        .select one s_dt related by s_udt->S_DT[R18]
        .select one s_udt related by s_dt->S_UDT[R17]
      .end while
      .select one s_edt related by s_dt->S_EDT[R17]
      .if (not_empty s_edt)
         .select any first_enum from instances of S_ENUM where (false)
         .select any s_enum related by s_edt->S_ENUM[R27]
         .while (not_empty s_enum)
           .assign first_enum = s_enum
           .select one s_enum related by s_enum->S_ENUM[R56.'succeeds']
         .end while
         .assign idx = 0
         .assign s_enum = first_enum
  if param.name == "${o_attr.Name}"
         .while (not_empty s_enum)
    if param.value == ${idx}
      select any inst from instances of ${o_obj.Key_Lett} where (selected.${key.name} == param.instance_id);
      inst.${o_attr.Name} = ${s_dt.Name}::${s_enum.Name};
      return;
    end if;
             .select one s_enum related by s_enum->S_ENUM[R56.'precedes']
           .assign idx = idx + 1
         .end while
  end if;
      .elif (s_dt.DT_ID == s_dt_param.DT_ID)
  if param.name == "${o_attr.Name}"
    select any inst from instances of ${o_obj.Key_Lett} where (selected.${key.name} == param.instance_id);
    inst.${o_attr.Name} = param.value;
    return;
  end if;
      .end if
    .end for
  .end if
end if;
.end for