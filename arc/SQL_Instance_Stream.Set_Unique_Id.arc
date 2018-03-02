.include "tools.arc"
.select any s_dt_param from instances of S_DT where (selected.Name == "unique_id")
.select many o_objs from instances of O_OBJ
.for each o_obj in o_objs
if param.key_letter == "${o_obj.Key_Lett}"
  .invoke key = find_lookup_key(o_obj)
  .if (key.name != "")
    .select many o_attrs related by o_obj->O_ATTR[R102]->O_BATTR[R106]->O_ATTR[R106]
    .for each o_attr in o_attrs
      .select any o_oida related by o_attr->O_OIDA[R105]
      .select one s_dt related by o_attr->S_DT[R114]
      .select one s_udt related by s_dt->S_UDT[R17]
      .while (not_empty s_udt)
        .select one s_dt related by s_udt->S_DT[R18]
        .select one s_udt related by s_dt->S_UDT[R17]
      .end while
      .if ((empty o_oida) and (s_dt.DT_ID == s_dt_param.DT_ID))
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