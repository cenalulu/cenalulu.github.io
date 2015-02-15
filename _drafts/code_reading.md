---
layout: article
title:  "MySQL源码阅读之dict0load.c"
categories: mysql
toc: true
#image:
#    teaser: /mysql/mysql-tool.png
---



## dict_load_indexes

#### Tips

一些我们可以从该函数中得到的结论和知识：

- Innodb数据字典中的`SYS_INDEXES`的列顺序和我们在`information_schema.INNODB_SYS_INDEXES`中看到的顺序并不一致。


属性|描述
-|-
摘要|`dict_load_indexes`主要用于将给定表对应的索引信息加载到内存的数据字典缓存中
输入参数|{table: 变量} {heap: 指向heap内存的指针，用于函数内部一些比较操作使用}
输出结果|index信息是否加载成功，如果成功返回DB_SUCCESS，如果失败返回DB_CORRUPTION




{% highlight c  %}
{% raw %}
/********************************************************************//**
Loads definitions for table indexes. Adds them to the data dictionary
cache.
@return DB_SUCCESS if ok, DB_CORRUPTION if corruption of dictionary
table or DB_UNSUPPORTED if table has unknown index type */
static
ulint
dict_load_indexes(
/*==============*/
    dict_table_t*   table,  /*!< in: table */
    mem_heap_t* heap)   /*!< in: memory heap for temporary storage */
{
    dict_table_t*   sys_indexes;
    dict_index_t*   sys_index;
    dict_index_t*   index;
    btr_pcur_t  pcur;
    dtuple_t*   tuple;
    dfield_t*   dfield;
    const rec_t*    rec;
    const byte* field;
    ulint       len;
    ulint       name_len;
    char*       name_buf;
    ulint       type;
    ulint       space;
    ulint       page_no;
    ulint       n_fields;
    byte*       buf;
    ibool       is_sys_table;
    dulint      id;
    mtr_t       mtr;
    ulint       error = DB_SUCCESS;

    ut_ad(mutex_own(&(dict_sys->mutex)));

    //通过table_id和DICT_HDR_FIRST_ID的比较，判断给定表是否是系统表
    if ((ut_dulint_get_high(table->id) == 0)
        && (ut_dulint_get_low(table->id) < DICT_HDR_FIRST_ID)) {
        is_sys_table = TRUE;
    } else {
        is_sys_table = FALSE;
    }

    mtr_start(&mtr);

    //打开SYS_INDEXES表，并初始化一个data_tuple用于在表中找到相应table_id所对应的所有字典记录行
    sys_indexes = dict_table_get_low("SYS_INDEXES");
    sys_index = UT_LIST_GET_FIRST(sys_indexes->indexes);
    ut_a(!dict_table_is_comp(sys_indexes));

    tuple = dtuple_create(heap, 1);
    dfield = dtuple_get_nth_field(tuple, 0);

    buf = mem_heap_alloc(heap, 8);
    mach_write_to_8(buf, table->id);

    dfield_set_data(dfield, buf, 8);
    dict_index_copy_types(tuple, sys_index, 1);

    btr_pcur_open_on_user_rec(sys_index, tuple, PAGE_CUR_GE,
                  BTR_SEARCH_LEAF, &pcur, &mtr);

    //对table_id对应的表的所有索引进行循环 
    for (;;) {
        if (!btr_pcur_is_on_user_rec(&pcur)) {

            break;
        }

        rec = btr_pcur_get_rec(&pcur);

        field = rec_get_nth_field_old(rec, 0, &len);
        ut_ad(len == 8);

        //确保该条记录对应的索引没有被删除
        if (ut_memcmp(buf, field, len) != 0) {
            break;
        } else if (rec_get_deleted_flag(rec, 0)) {
            /* Skip delete marked records */
            goto next_rec;
        }

        // 读取索引ID
        field = rec_get_nth_field_old(rec, 1, &len);
        ut_ad(len == 8);
        id = mach_read_from_8(field);

        // 读取索引名字
        ut_a(name_of_col_is(sys_indexes, sys_index, 4, "NAME"));

        field = rec_get_nth_field_old(rec, 4, &name_len);
        name_buf = mem_heap_strdupl(heap, (char*) field, name_len);

        // 读取索引包含几个字段
        field = rec_get_nth_field_old(rec, 5, &len);
        n_fields = mach_read_from_4(field);

        // 读取索引类型, 类型对应的枚举在dict0mem.h中定义。目前有{1: DICT_CLUSTERED, 2: DICT_UNIQUE, 4:DICT_UNIVERSAL, 8: DICT_IBUF}四种。4中类型并不互斥，可以通过OR操作同时具备。例如：用户定义的主键索引的type为3 (即2|1); Innodb隐式的聚簇索引type为1
        field = rec_get_nth_field_old(rec, 6, &len);
        type = mach_read_from_4(field);

        // 读取索引所在的space_id
        field = rec_get_nth_field_old(rec, 7, &len);
        space = mach_read_from_4(field);

        ut_a(name_of_col_is(sys_indexes, sys_index, 8, "PAGE_NO"));

        // 读取该索引第一页的根page的page_no
        field = rec_get_nth_field_old(rec, 8, &len);
        page_no = mach_read_from_4(field);

        /* We check for unsupported types first, so that the
        subsequent checks are relevant for the supported types. */
        if (type & ~(DICT_CLUSTERED | DICT_UNIQUE)) {

            fprintf(stderr,
                "InnoDB: Error: unknown type %lu"
                " of index %s of table %s\n",
                (ulong) type, name_buf, table->name);

            error = DB_UNSUPPORTED;
            goto func_exit;
        } else if (page_no == FIL_NULL) {

            fprintf(stderr,
                "InnoDB: Error: trying to load index %s"
                " for table %s\n"
                "InnoDB: but the index tree has been freed!\n",
                name_buf, table->name);

            error = DB_CORRUPTION;
            goto func_exit;
        } else if ((type & DICT_CLUSTERED) == 0
                && NULL == dict_table_get_first_index(table)) {

            fputs("InnoDB: Error: trying to load index ",
                  stderr);
            ut_print_name(stderr, NULL, FALSE, name_buf);
            fputs(" for table ", stderr);
            ut_print_name(stderr, NULL, TRUE, table->name);
            fputs("\nInnoDB: but the first index"
                  " is not clustered!\n", stderr);

            error = DB_CORRUPTION;
            goto func_exit;
        } else if (is_sys_table
               && ((type & DICT_CLUSTERED)
                   || ((table == dict_sys->sys_tables)
                   && (name_len == (sizeof "ID_IND") - 1)
                   && (0 == ut_memcmp(name_buf,
                              "ID_IND", name_len))))) {

            /* The index was created in memory already at booting
            of the database server */
        } else {
            // 在一系列约束检查后进行真正的dict_cach加载
            index = dict_mem_index_create(table->name, name_buf,
                              space, type, n_fields);
            index->id = id;

            // 用本文中的dict_load_fields将索引的所有字段信息存放到index变量中
            error = dict_load_fields(index, heap);

            // 如果加载失败，则在error log中输出信息，并crash。如果启动时配置了force recovery那么就忽略这个错误，继续加载其他索引
            if (error != DB_SUCCESS) {
                fprintf(stderr, "InnoDB: Error: load index '%s'"
                    " for table '%s' failed\n",
                    index->name, table->name);

                /* If the force recovery flag is set, and
                if the failed index is not the primary index, we
                will continue and open other indexes */
                if (srv_force_recovery
                    && !(index->type & DICT_CLUSTERED)) {
                    error = DB_SUCCESS;
                    goto next_rec;
                } else {
                    goto func_exit;
                }
            }

            // 如果把刚获取到的index信息存放到cache中失败的话，也直接crash Innodb。这里不对force recovery做跳过的原因是防止innodb内部数据字典和frm物理文件的表结构描述产生更大的差异。
            error = dict_index_add_to_cache(table, index, page_no,
                            FALSE);
            /* The data dictionary tables should never contain
            invalid index definitions.  If we ignored this error
            and simply did not load this index definition, the
            .frm file would disagree with the index definitions
            inside InnoDB. */
            if (UNIV_UNLIKELY(error != DB_SUCCESS)) {

                goto func_exit;
            }
        }

next_rec:
        btr_pcur_move_to_next_user_rec(&pcur, &mtr);
    }

func_exit:
    btr_pcur_close(&pcur);
    mtr_commit(&mtr);

    return(error);
}
{% endraw %}
{% endhighlight %}



## dict_load_table

#### Tips

一些我们可以从该函数中得到的结论和知识：

- Innodb数据字典中的SYS_TABLES的列顺序和我们在`information_schema.INNODB_SYS_TALBES`中看到的顺序并不一致。

属性|描述
-|-
用途|text1
输入参数|text2
返回值|text3

{% highlight c %}
{% raw %}
/********************************************************************//**
Loads a table definition and also all its index definitions, and also
the cluster definition if the table is a member in a cluster. Also loads
all foreign key constraints where the foreign key is in the table or where a foreign key references columns in this table. Adds all these to the data dictionary cache.  
@return table, NULL if does not exist; if the table is stored in an
.ibd file, but the file does not exist, then we set the
ibd_file_missing flag TRUE in the table object we return */
UNIV_INTERN
dict_table_t*
dict_load_table(
/*============*/
    const char* name)   /*!< in: table name in the
                databasename/tablename format */
{
    ibool       ibd_file_missing    = FALSE;
    dict_table_t*   table;
    dict_table_t*   sys_tables;
    btr_pcur_t  pcur;
    dict_index_t*   sys_index;
    dtuple_t*   tuple;
    mem_heap_t* heap;
    dfield_t*   dfield;
    const rec_t*    rec;
    const byte* field;
    ulint       len;
    ulint       space;
    ulint       n_cols;
    ulint       flags;
    ulint       err;
    mtr_t       mtr;

    ut_ad(mutex_own(&(dict_sys->mutex)));

    heap = mem_heap_create(32000);

    mtr_start(&mtr);

    // 打开SYS_TABLES，并准备读取数据
    sys_tables = dict_table_get_low("SYS_TABLES");
    sys_index = UT_LIST_GET_FIRST(sys_tables->indexes);
    ut_a(!dict_table_is_comp(sys_tables));

    // 用于记录比较的常用方式：将传入的name参数填入到一个data_tuple中，准备和SYS_TABLES中的记录作等值比较
    tuple = dtuple_create(heap, 1);
    dfield = dtuple_get_nth_field(tuple, 0);

    dfield_set_data(dfield, name, ut_strlen(name));
    dict_index_copy_types(tuple, sys_index, 1);

    // 将btr指针放置到第一个TABLE_NAME为$name的记录上
    btr_pcur_open_on_user_rec(sys_index, tuple, PAGE_CUR_GE,
                  BTR_SEARCH_LEAF, &pcur, &mtr);
    rec = btr_pcur_get_rec(&pcur);

    if (!btr_pcur_is_on_user_rec(&pcur)
        || rec_get_deleted_flag(rec, 0)) {
        /* Not found */
err_exit:
        btr_pcur_close(&pcur);
        mtr_commit(&mtr);
        mem_heap_free(heap);

        return(NULL);
    }

    field = rec_get_nth_field_old(rec, 0, &len);

    /* Check if the table name in record is the searched one */
    if (len != ut_strlen(name) || ut_memcmp(name, field, len) != 0) {

        goto err_exit;
    }

    ut_a(name_of_col_is(sys_tables, sys_index, 9, "SPACE"));

    field = rec_get_nth_field_old(rec, 9, &len);
    space = mach_read_from_4(field);

    /* Check if the tablespace exists and has the right name */
    if (!trx_sys_sys_space(space)) {
        flags = dict_sys_tables_get_flags(rec);

        if (UNIV_UNLIKELY(flags == ULINT_UNDEFINED)) {
            field = rec_get_nth_field_old(rec, 5, &len);
            flags = mach_read_from_4(field);

            ut_print_timestamp(stderr);
            fputs("  InnoDB: Error: table ", stderr);
            ut_print_filename(stderr, name);
            fprintf(stderr, "\n"
                "InnoDB: in InnoDB data dictionary"
                " has unknown type %lx.\n",
                (ulong) flags);
            goto err_exit;
        }
    } else {
        flags = 0;
    }

    ut_a(name_of_col_is(sys_tables, sys_index, 4, "N_COLS"));

    field = rec_get_nth_field_old(rec, 4, &len);
    n_cols = mach_read_from_4(field);

    //数据字典中的N_COLS列为一个Unsigned Long(4 Byte)类型的值。该值得高位(0x80000000)存储了compact format的flag。如果是compact format的表结构，那么SYS_TABLES中的MIX_LEN字段中的在高位上也存储有一部分的flag信息
    /* The high-order bit of N_COLS is the "compact format" flag.
    For tables in that format, MIX_LEN may hold additional flags. */
    if (n_cols & 0x80000000UL) {
        ulint   flags2;

        flags |= DICT_TF_COMPACT;

        ut_a(name_of_col_is(sys_tables, sys_index, 7, "MIX_LEN"));
        field = rec_get_nth_field_old(rec, 7, &len);

        flags2 = mach_read_from_4(field);

        if (flags2 & (~0 << (DICT_TF2_BITS - DICT_TF2_SHIFT))) {
            ut_print_timestamp(stderr);
            fputs("  InnoDB: Warning: table ", stderr);
            ut_print_filename(stderr, name);
            fprintf(stderr, "\n"
                "InnoDB: in InnoDB data dictionary"
                " has unknown flags %lx.\n",
                (ulong) flags2);

            flags2 &= ~(~0 << (DICT_TF2_BITS - DICT_TF2_SHIFT));
        }

        flags |= flags2 << DICT_TF2_SHIFT;
    }

    /* See if the tablespace is available. */
    if (trx_sys_sys_space(space)) {
        /* The system tablespace is always available. */
    } else if (!fil_space_for_table_exists_in_mem(
               space, name,
               (flags >> DICT_TF2_SHIFT) & DICT_TF2_TEMPORARY,
               FALSE, FALSE)) {

        if ((flags >> DICT_TF2_SHIFT) & DICT_TF2_TEMPORARY) {
            /* Do not bother to retry opening temporary tables. */
            ibd_file_missing = TRUE;
        } else {
            ut_print_timestamp(stderr);
            fprintf(stderr,
                "  InnoDB: error: space object of table");
            ut_print_filename(stderr, name);
            fprintf(stderr, ",\n"
                "InnoDB: space id %lu did not exist in memory."
                " Retrying an open.\n",
                (ulong) space);
            /* Try to open the tablespace */
            if (!fil_open_single_table_tablespace(
                    TRUE, space,
                    flags == DICT_TF_COMPACT ? 0 :
                    flags & ~(~0 << DICT_TF_BITS), name)) {
                /* We failed to find a sensible
                tablespace file */

                ibd_file_missing = TRUE;
            }
        }
    }

    table = dict_mem_table_create(name, space, n_cols & ~0x80000000UL,
                      flags);

    table->ibd_file_missing = (unsigned int) ibd_file_missing;

    ut_a(name_of_col_is(sys_tables, sys_index, 3, "ID"));

    field = rec_get_nth_field_old(rec, 3, &len);
    table->id = mach_read_from_8(field);

    btr_pcur_close(&pcur);
    mtr_commit(&mtr);

    dict_load_columns(table, heap);

    dict_table_add_to_cache(table, heap);

    mem_heap_empty(heap);

    err = dict_load_indexes(table, heap);

    /* Initialize table foreign_child value. Its value could be
    changed when dict_load_foreigns() is called below */
    table->fk_max_recusive_level = 0;

    /* If the force recovery flag is set, we open the table irrespective
    of the error condition, since the user may want to dump data from the
    clustered index. However we load the foreign key information only if
    all indexes were loaded. */
    if (err == DB_SUCCESS) {
        err = dict_load_foreigns(table->name, TRUE, TRUE);

        if (err != DB_SUCCESS) {
            dict_table_remove_from_cache(table);
            table = NULL;
        } else {
            table->fk_max_recusive_level = 0;
        }
    } else {
        dict_index_t*   index;

        /* Make sure that at least the clustered index was loaded.
        Otherwise refuse to load the table */
        index = dict_table_get_first_index(table);

        if (!srv_force_recovery || !index
             || !(index->type & DICT_CLUSTERED)) {
            dict_table_remove_from_cache(table);
            table = NULL;
        }
    }
#if 0
    if (err != DB_SUCCESS && table != NULL) {

        mutex_enter(&dict_foreign_err_mutex);

        ut_print_timestamp(stderr);

        fprintf(stderr,
            "  InnoDB: Error: could not make a foreign key"
            " definition to match\n"
            "InnoDB: the foreign key table"
            " or the referenced table!\n"
            "InnoDB: The data dictionary of InnoDB is corrupt."
            " You may need to drop\n"
            "InnoDB: and recreate the foreign key table"
            " or the referenced table.\n"
            "InnoDB: Submit a detailed bug report"
            " to http://bugs.mysql.com\n"
            "InnoDB: Latest foreign key error printout:\n%s\n",
            dict_foreign_err_buf);

        mutex_exit(&dict_foreign_err_mutex);
    }
#endif /* 0 */
    mem_heap_free(heap);

    return(table);
}

{% endraw %}
{% endhighlight %}

