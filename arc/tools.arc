.function find_lookup_key
  .param inst_ref o_obj
  .assign attr_name = ""
  .select any s_dt from instances of S_DT where (selected.Name == "unique_id")
  .select many o_ids related by o_obj->O_ID[R104]
  .for each o_id in o_ids
    .assign skip = false
    .if (o_id.Oid_ID < 0)
      .assign skip = true
    .end if
    .select many o_oidas related by o_id->O_OIDA[R105]
    .if ((cardinality o_oidas) != 1)
      .assign skip = true
    .end if
    .select any o_attr related by o_oidas->O_ATTR[R105]
    .if (not_empty o_attr)
      .if (o_attr.DT_ID != s_dt.DT_ID)
        .assign skip = true
      .end if
      .select one o_battr related by o_attr->O_BATTR[R106]
      .if (empty o_battr)
        .assign skip = true
      .end if
    .end if
    .if (not skip)
      .assign attr_name = o_attr.Name
      .break for
    .end if
  .end for
.end function