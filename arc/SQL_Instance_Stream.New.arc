.include "tools.arc"
.select many o_objs from instances of O_OBJ
.for each o_obj in o_objs
  .invoke key = find_lookup_key(o_obj)
  .if (key.name != "")
if param.key_letter == "${o_obj.Key_Lett}"
    create object instance inst of ${o_obj.Key_Lett};
    return inst.${key.name};
end if;
  .else
//${o_obj.Key_Lett} has no unique_id lookup key
  .end if
.end for