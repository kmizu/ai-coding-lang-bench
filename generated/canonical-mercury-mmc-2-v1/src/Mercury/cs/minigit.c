/*
** Automatically generated from `minigit.m'
** by the Mercury compiler,
** version 22.01.8-1~jammy
** configured for x86_64-pc-linux-gnu.
** Do not edit.
**
** The autoconfigured grade settings governing
** the generation of this C file were
**
** TAG_BITS=3
** UNBOXED_FLOAT=yes
** UNBOXED_INT64S=yes
** PREGENERATED_DIST=no
** HIGHLEVEL_CODE=no
**
** END_OF_C_GRADE_INFO
*/

/*
INIT mercury__minigit__init
ENDINIT
*/

#define MR_ALLOW_RESET
#include "mercury_imp.h"
#line 28 "Mercury/cs/minigit.c"
#include "array.mh"

#line 31 "Mercury/cs/minigit.c"
#line 32 "Mercury/cs/minigit.c"
#include "bitmap.mh"

#line 35 "Mercury/cs/minigit.c"
#line 36 "Mercury/cs/minigit.c"
#include "dir.mh"

#line 39 "Mercury/cs/minigit.c"
#line 40 "Mercury/cs/minigit.c"
#include "io.mh"

#line 43 "Mercury/cs/minigit.c"
#line 44 "Mercury/cs/minigit.c"
#include "minigit.mh"

#line 47 "Mercury/cs/minigit.c"
#line 48 "Mercury/cs/minigit.c"
#include "string.mh"

#line 51 "Mercury/cs/minigit.c"
#line 52 "Mercury/cs/minigit.c"
#include "time.mh"

#line 55 "Mercury/cs/minigit.c"
#line 56 "Mercury/cs/minigit.c"
#ifndef MINIGIT_DECL_GUARD
#define MINIGIT_DECL_GUARD

#line 60 "Mercury/cs/minigit.c"
#line 26 "minigit.m"
#include <time.h>
#line 63 "Mercury/cs/minigit.c"
#line 64 "Mercury/cs/minigit.c"

#endif
#line 67 "Mercury/cs/minigit.c"

#ifdef _MSC_VER
#define MR_STATIC_LINKAGE extern
#else
#define MR_STATIC_LINKAGE static
#endif


#ifdef MR_MSVC
#pragma pack(push, MR_BYTES_PER_WORD)
#endif
struct mercury_type_0 {
	MR_Word * f1[3];
};
#ifdef MR_MSVC
#pragma pack(pop)
#endif
MR_STATIC_LINKAGE const struct mercury_type_0 mercury_common_0[];


#ifdef MR_MSVC
#pragma pack(push, MR_BYTES_PER_WORD)
#endif
struct mercury_type_1 {
	MR_Word * f1;
	MR_Word * f2;
	MR_Integer f3;
	MR_Word * f4;
};
#ifdef MR_MSVC
#pragma pack(pop)
#endif
MR_STATIC_LINKAGE const struct mercury_type_1 mercury_common_1[];


#ifdef MR_MSVC
#pragma pack(push, MR_BYTES_PER_WORD)
#endif
struct mercury_type_2 {
	MR_Word * f1;
	MR_Code * f2;
	MR_Integer f3;
};
#ifdef MR_MSVC
#pragma pack(pop)
#endif
MR_STATIC_LINKAGE const struct mercury_type_2 mercury_common_2[];


#ifdef MR_MSVC
#pragma pack(push, MR_BYTES_PER_WORD)
#endif
struct mercury_type_3 {
	MR_Word * f1;
	MR_Word * f2;
	MR_Integer f3;
	MR_Word * f4;
	MR_Word * f5;
};
#ifdef MR_MSVC
#pragma pack(pop)
#endif
MR_STATIC_LINKAGE const struct mercury_type_3 mercury_common_3[];


#ifdef MR_MSVC
#pragma pack(push, MR_BYTES_PER_WORD)
#endif
struct mercury_type_4 {
	MR_Word * f1[2];
	MR_Integer f2;
	MR_Word * f3[3];
};
#ifdef MR_MSVC
#pragma pack(pop)
#endif
MR_STATIC_LINKAGE const struct mercury_type_4 mercury_common_4[];
MR_decl_label10(minigit__cmd_commit_3_0, 2,3,5,8,6,10,11,12,15,16)
MR_decl_label10(minigit__cmd_commit_3_0, 18,19,20,21,22,23,24,25,26,27)
MR_decl_label10(minigit__cmd_commit_3_0, 28,29,30,31,32,33,34,35,36,37)
MR_decl_label2(minigit__cmd_commit_3_0, 38,39)
MR_decl_label3(minigit__cmd_log_2_0, 2,3,4)
MR_decl_label3(minigit__get_field_3_0, 3,6,4)
MR_decl_label4(minigit__get_file_hashes_4_0, 16,4,5,7)
MR_decl_label10(main_2_0, 2,6,9,7,11,12,13,14,3,22)
MR_decl_label10(main_2_0, 25,26,29,30,31,32,33,35,38,40)
MR_decl_label8(main_2_0, 41,27,23,17,50,58,63,68)
MR_decl_label10(minigit__print_log_3_0, 6,7,10,11,12,13,14,15,16,17)
MR_decl_label6(minigit__print_log_3_0, 18,19,20,21,22,39)
MR_decl_label4(minigit__read_file_string_4_0, 2,5,6,3)
MR_decl_label3(minigit__update_hash_3_0, 2,3,4)
MR_decl_label3(minigit__write_file_4_0, 2,5,7)
MR_decl_label1(fn__minigit__IntroducedFrom__func__cmd_commit__117__1_1_0, 2)
MR_decl_label4(fn__minigit__mini_hash_1_0, 2,3,5,6)
MR_decl_label9(fn__minigit__nibble_chars_2_0, 27,3,4,5,7,6,9,10,12)
MR_def_extern_entry(main_2_0)
MR_decl_static(minigit__get_unix_timestamp_3_0)
MR_decl_static(minigit__cmd_commit_3_0)
MR_decl_static(minigit__get_file_hashes_4_0)
MR_decl_static(minigit__cmd_log_2_0)
MR_decl_static(minigit__print_log_3_0)
MR_decl_static(fn__minigit__mini_hash_1_0)
MR_decl_static(minigit__update_hash_3_0)
MR_decl_static(fn__minigit__nibble_chars_2_0)
MR_decl_static(minigit__write_file_4_0)
MR_decl_static(minigit__read_file_string_4_0)
MR_decl_static(minigit__get_field_3_0)
MR_decl_static(minigit__non_empty_string_1_0)
MR_decl_static(fn__minigit__IntroducedFrom__func__cmd_commit__117__1_1_0)

extern const MR_TypeCtorInfo_Struct mercury_data_pair__type_ctor_info_pair_2;
extern const MR_TypeCtorInfo_Struct mercury_data_builtin__type_ctor_info_string_0;
extern const MR_TypeCtorInfo_Struct mercury_data_builtin__type_ctor_info_string_0;
static const struct mercury_type_0 mercury_common_0[2] =
{
{
{
MR_CTOR_ADDR(pair, pair, 2),
MR_STRING_CTOR_ADDR,
MR_STRING_CTOR_ADDR
}
},
{
{
MR_CTOR_ADDR(pair, pair, 2),
MR_STRING_CTOR_ADDR,
MR_STRING_CTOR_ADDR
}
},
};

static const MR_UserClosureId
mercury_data__closure_layout__main_2_0_1;
extern const MR_TypeCtorInfo_Struct mercury_data_builtin__type_ctor_info_string_0;
static const MR_UserClosureId
mercury_data__closure_layout__minigit__cmd_commit_3_0_1;
static const struct mercury_type_1 mercury_common_1[2] =
{
{
(MR_Word *) &mercury_data__closure_layout__main_2_0_1,
((MR_Word *) (MR_Integer) 0),
1,
MR_STRING_CTOR_ADDR
},
{
(MR_Word *) &mercury_data__closure_layout__minigit__cmd_commit_3_0_1,
((MR_Word *) (MR_Integer) 0),
1,
MR_STRING_CTOR_ADDR
},
};

static const struct mercury_type_2 mercury_common_2[4] =
{
{
MR_COMMON(1,0),
MR_ENTRY_AP(minigit__non_empty_string_1_0),
0
},
{
MR_COMMON(1,1),
MR_ENTRY_AP(minigit__non_empty_string_1_0),
0
},
{
MR_COMMON(3,0),
MR_ENTRY_AP(fn__minigit__IntroducedFrom__func__cmd_commit__117__1_1_0),
0
},
{
MR_COMMON(4,0),
MR_ENTRY_AP(minigit__update_hash_3_0),
0
},
};

static const MR_UserClosureId
mercury_data__closure_layout__minigit__cmd_commit_3_0_2;
static const struct mercury_type_3 mercury_common_3[1] =
{
{
(MR_Word *) &mercury_data__closure_layout__minigit__cmd_commit_3_0_2,
((MR_Word *) (MR_Integer) 0),
2,
MR_COMMON(0,1),
MR_STRING_CTOR_ADDR
},
};

static const MR_UserClosureId
mercury_data__closure_layout__fn__minigit__mini_hash_1_0_1;
extern const MR_TypeCtorInfo_Struct mercury_data_builtin__type_ctor_info_character_0;
extern const MR_TypeCtorInfo_Struct mercury_data_builtin__type_ctor_info_uint64_0;
static const struct mercury_type_4 mercury_common_4[1] =
{
{
{
(MR_Word *) &mercury_data__closure_layout__fn__minigit__mini_hash_1_0_1,
((MR_Word *) (MR_Integer) 0)
},
3,
{
MR_CHAR_CTOR_ADDR,
MR_UINT64_CTOR_ADDR,
MR_UINT64_CTOR_ADDR
}
},
};


static const MR_UserClosureId
mercury_data__closure_layout__fn__minigit__mini_hash_1_0_1 = {
{
MR_PREDICATE,
"minigit",
"minigit",
"update_hash",
3,
0
},
"minigit",
"minigit.m",
183,
"7"
};

static const MR_UserClosureId
mercury_data__closure_layout__minigit__cmd_commit_3_0_2 = {
{
MR_FUNCTION,
"minigit",
"minigit",
"lambda_minigit_m_117",
2,
0
},
"minigit",
"minigit.m",
117,
"30"
};

static const MR_UserClosureId
mercury_data__closure_layout__minigit__cmd_commit_3_0_1 = {
{
MR_PREDICATE,
"minigit",
"minigit",
"non_empty_string",
1,
0
},
"minigit",
"minigit.m",
102,
"10"
};

static const MR_UserClosureId
mercury_data__closure_layout__main_2_0_1 = {
{
MR_PREDICATE,
"minigit",
"minigit",
"non_empty_string",
1,
0
},
"minigit",
"minigit.m",
78,
"23"
};


MR_decl_entry(io__command_line_arguments_3_0);
MR_decl_entry(io__open_input_4_0);
MR_decl_entry(io__close_input_3_0);
MR_decl_entry(io__write_string_3_0);
MR_decl_entry(dir__make_directory_4_0);
MR_decl_entry(io__read_file_as_string_4_0);
MR_decl_entry(fn__f_115_116_114_105_110_103_95_95_43_43_2_0);
MR_decl_entry(fn__string__split_at_char_2_0);
MR_decl_entry(fn__list__filter_2_0);
MR_decl_entry(list__member_2_0);
MR_decl_entry(io__set_exit_status_3_0);

MR_BEGIN_MODULE(minigit_module0)
	MR_init_entry1(main_2_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__main_2_0);
	MR_init_label10(main_2_0,2,6,9,7,11,12,13,14,3,22)
	MR_init_label10(main_2_0,25,26,29,30,31,32,33,35,38,40)
	MR_init_label8(main_2_0,41,27,23,17,50,58,63,68)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'main'/2 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_define_entry(mercury__main_2_0);
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(4);
	MR_sv(4) = ((MR_Word) MR_succip);
	MR_np_call_localret_ent(io__command_line_arguments_3_0,
		main_2_0_i2);
MR_def_label(main_2_0, 2)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_EQ(MR_r1,0)) {
		MR_GOTO_LAB(main_2_0_i3);
	}
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_tfield(1, MR_r1, 0);
	if ((strcmp((char *) ((MR_Word *) MR_tempr1), MR_string_const("init", 4)) != 0)) {
		MR_GOTO_LAB(main_2_0_i3);
	}
	MR_r1 = ((MR_Word) MR_string_const(".minigit/HEAD", 13));
	}
	MR_np_call_localret_ent(io__open_input_4_0,
		main_2_0_i6);
MR_def_label(main_2_0, 6)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_NE(MR_tag(MR_r1),0)) {
		MR_GOTO_LAB(main_2_0_i7);
	}
	MR_r1 = MR_tfield(0, MR_r1, 0);
	MR_np_call_localret_ent(io__close_input_3_0,
		main_2_0_i9);
MR_def_label(main_2_0, 9)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const("Repository already initialized\n", 31));
	MR_succip_word = MR_sv(4);
	MR_decr_sp(4);
	MR_np_tailcall_ent(io__write_string_3_0);
MR_def_label(main_2_0, 7)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const(".minigit", 8));
	MR_np_call_localret_ent(dir__make_directory_4_0,
		main_2_0_i11);
MR_def_label(main_2_0, 11)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const(".minigit/objects", 16));
	MR_np_call_localret_ent(dir__make_directory_4_0,
		main_2_0_i12);
MR_def_label(main_2_0, 12)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const(".minigit/commits", 16));
	MR_np_call_localret_ent(dir__make_directory_4_0,
		main_2_0_i13);
MR_def_label(main_2_0, 13)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const(".minigit/HEAD", 13));
	MR_r2 = ((MR_Word) MR_string_const("", 0));
	MR_np_call_localret_ent(minigit__write_file_4_0,
		main_2_0_i14);
MR_def_label(main_2_0, 14)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const(".minigit/index", 14));
	MR_r2 = ((MR_Word) MR_string_const("", 0));
	MR_succip_word = MR_sv(4);
	MR_decr_sp(4);
	MR_np_tailcall_ent(minigit__write_file_4_0);
MR_def_label(main_2_0, 3)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_EQ(MR_r1,0)) {
		MR_GOTO_LAB(main_2_0_i17);
	}
	{
	MR_Word MR_tempr1, MR_tempr2;
	MR_tempr1 = MR_tfield(1, MR_r1, 0);
	if ((strcmp((char *) ((MR_Word *) MR_tempr1), MR_string_const("add", 3)) != 0)) {
		MR_GOTO_LAB(main_2_0_i17);
	}
	MR_tempr1 = MR_tfield(1, MR_r1, 1);
	if (MR_INT_EQ(MR_tempr1,0)) {
		MR_GOTO_LAB(main_2_0_i17);
	}
	MR_tempr2 = MR_tfield(1, MR_tempr1, 1);
	if (MR_INT_NE(MR_tempr2,0)) {
		MR_GOTO_LAB(main_2_0_i17);
	}
	MR_sv(1) = MR_tfield(1, MR_tempr1, 0);
	MR_r1 = MR_sv(1);
	}
	MR_np_call_localret_ent(io__open_input_4_0,
		main_2_0_i22);
MR_def_label(main_2_0, 22)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_NE(MR_tag(MR_r1),0)) {
		MR_GOTO_LAB(main_2_0_i23);
	}
	MR_sv(2) = MR_tfield(0, MR_r1, 0);
	MR_r1 = MR_sv(2);
	MR_np_call_localret_ent(io__read_file_as_string_4_0,
		main_2_0_i25);
MR_def_label(main_2_0, 25)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_sv(2);
	MR_sv(2) = MR_r1;
	MR_r1 = MR_tempr1;
	}
	MR_np_call_localret_ent(io__close_input_3_0,
		main_2_0_i26);
MR_def_label(main_2_0, 26)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_NE(MR_tag(MR_sv(2)),0)) {
		MR_GOTO_LAB(main_2_0_i27);
	}
	MR_sv(2) = MR_tfield(0, MR_sv(2), 0);
	MR_r1 = MR_sv(2);
	MR_np_call_localret_ent(fn__minigit__mini_hash_1_0,
		main_2_0_i29);
MR_def_label(main_2_0, 29)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = ((MR_Word) MR_string_const(".minigit/objects/", 17));
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		main_2_0_i30);
MR_def_label(main_2_0, 30)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r2 = MR_sv(2);
	MR_np_call_localret_ent(minigit__write_file_4_0,
		main_2_0_i31);
MR_def_label(main_2_0, 31)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const(".minigit/index", 14));
	MR_np_call_localret_ent(minigit__read_file_string_4_0,
		main_2_0_i32);
MR_def_label(main_2_0, 32)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(2) = MR_r1;
	MR_r1 = (MR_Integer) 10;
	MR_r2 = MR_sv(2);
	MR_np_call_localret_ent(fn__string__split_at_char_2_0,
		main_2_0_i33);
MR_def_label(main_2_0, 33)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(3) = ((MR_Word) MR_STRING_CTOR_ADDR);
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(3);
	MR_r2 = ((MR_Word) MR_TAG_COMMON(0,2,0));
	MR_r3 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__list__filter_2_0,
		main_2_0_i35);
MR_def_label(main_2_0, 35)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(3);
	MR_r2 = MR_sv(1);
	MR_r3 = MR_tempr1;
	}
	MR_np_call_localret_ent(list__member_2_0,
		main_2_0_i38);
MR_def_label(main_2_0, 38)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_r1) {
		MR_GOTO_LAB(main_2_0_i68);
	}
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_sv(1);
	MR_sv(1) = ((MR_Word) MR_string_const(".minigit/index", 14));
	MR_r1 = MR_tempr1;
	MR_r2 = ((MR_Word) MR_string_const("\n", 1));
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		main_2_0_i40);
MR_def_label(main_2_0, 40)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(2);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		main_2_0_i41);
MR_def_label(main_2_0, 41)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(1);
	MR_r2 = MR_tempr1;
	MR_succip_word = MR_sv(4);
	MR_decr_sp(4);
	MR_np_tailcall_ent(minigit__write_file_4_0);
	}
MR_def_label(main_2_0, 27)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const("File not found\n", 15));
	MR_np_call_localret_ent(io__write_string_3_0,
		main_2_0_i63);
MR_def_label(main_2_0, 23)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const("File not found\n", 15));
	MR_np_call_localret_ent(io__write_string_3_0,
		main_2_0_i63);
MR_def_label(main_2_0, 17)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_EQ(MR_r1,0)) {
		MR_GOTO_LAB(main_2_0_i50);
	}
	{
	MR_Word MR_tempr1, MR_tempr2;
	MR_tempr1 = MR_tfield(1, MR_r1, 0);
	if ((strcmp((char *) ((MR_Word *) MR_tempr1), MR_string_const("commit", 6)) != 0)) {
		MR_GOTO_LAB(main_2_0_i50);
	}
	MR_tempr1 = MR_tfield(1, MR_r1, 1);
	if (MR_INT_EQ(MR_tempr1,0)) {
		MR_GOTO_LAB(main_2_0_i50);
	}
	MR_tempr2 = MR_tfield(1, MR_tempr1, 0);
	if ((strcmp((char *) ((MR_Word *) MR_tempr2), MR_string_const("-m", 2)) != 0)) {
		MR_GOTO_LAB(main_2_0_i50);
	}
	MR_tempr2 = MR_tfield(1, MR_tempr1, 1);
	if (MR_INT_EQ(MR_tempr2,0)) {
		MR_GOTO_LAB(main_2_0_i50);
	}
	MR_tempr1 = MR_tfield(1, MR_tempr2, 1);
	if (MR_INT_NE(MR_tempr1,0)) {
		MR_GOTO_LAB(main_2_0_i50);
	}
	MR_r1 = MR_tfield(1, MR_tempr2, 0);
	MR_succip_word = MR_sv(4);
	MR_decr_sp(4);
	MR_np_tailcall_ent(minigit__cmd_commit_3_0);
	}
MR_def_label(main_2_0, 50)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_EQ(MR_r1,0)) {
		MR_GOTO_LAB(main_2_0_i58);
	}
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_tfield(1, MR_r1, 0);
	if ((strcmp((char *) ((MR_Word *) MR_tempr1), MR_string_const("log", 3)) != 0)) {
		MR_GOTO_LAB(main_2_0_i58);
	}
	MR_tempr1 = MR_tfield(1, MR_r1, 1);
	if (MR_INT_NE(MR_tempr1,0)) {
		MR_GOTO_LAB(main_2_0_i58);
	}
	MR_succip_word = MR_sv(4);
	MR_decr_sp(4);
	MR_np_tailcall_ent(minigit__cmd_log_2_0);
	}
MR_def_label(main_2_0, 58)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const("Usage: minigit <command>\n", 25));
	MR_np_call_localret_ent(io__write_string_3_0,
		main_2_0_i63);
MR_def_label(main_2_0, 63)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = (MR_Integer) 1;
	MR_succip_word = MR_sv(4);
	MR_decr_sp(4);
	MR_np_tailcall_ent(io__set_exit_status_3_0);
MR_def_label(main_2_0, 68)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_decr_sp_and_return(4);
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE


MR_BEGIN_MODULE(minigit_module1)
	MR_init_entry1(minigit__get_unix_timestamp_3_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__minigit__get_unix_timestamp_3_0);
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'get_unix_timestamp'/3 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(minigit__get_unix_timestamp_3_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Integer	T;
#define	MR_PROC_LABEL	mercury__minigit__get_unix_timestamp_3_0
	MR_OBTAIN_GLOBAL_LOCK("get_unix_timestamp");
{
#line 24 "minigit.m"
T = (MR_Integer)time(NULL);;}
#line 671 "Mercury/cs/minigit.c"
	MR_RELEASE_GLOBAL_LOCK("get_unix_timestamp");
	MR_r1 = T;
#undef	MR_PROC_LABEL
	}
	MR_proceed();
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE

MR_decl_entry(fn__string__strip_1_0);
MR_decl_entry(list__sort_2_0);
MR_decl_entry(fn__list__map_2_0);
MR_decl_entry(fn__string__join_list_2_0);
MR_decl_entry(fn__string__int_to_string_1_0);

MR_BEGIN_MODULE(minigit_module2)
	MR_init_entry1(minigit__cmd_commit_3_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__minigit__cmd_commit_3_0);
	MR_init_label10(minigit__cmd_commit_3_0,2,3,5,8,6,10,11,12,15,16)
	MR_init_label10(minigit__cmd_commit_3_0,18,19,20,21,22,23,24,25,26,27)
	MR_init_label10(minigit__cmd_commit_3_0,28,29,30,31,32,33,34,35,36,37)
	MR_init_label2(minigit__cmd_commit_3_0,38,39)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'cmd_commit'/3 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(minigit__cmd_commit_3_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(11);
	MR_sv(11) = ((MR_Word) MR_succip);
	MR_sv(10) = MR_r1;
	MR_r1 = ((MR_Word) MR_string_const(".minigit/index", 14));
	MR_np_call_localret_ent(minigit__read_file_string_4_0,
		minigit__cmd_commit_3_0_i2);
MR_def_label(minigit__cmd_commit_3_0, 2)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = (MR_Integer) 10;
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__string__split_at_char_2_0,
		minigit__cmd_commit_3_0_i3);
MR_def_label(minigit__cmd_commit_3_0, 3)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(2) = ((MR_Word) MR_STRING_CTOR_ADDR);
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(2);
	MR_r2 = ((MR_Word) MR_TAG_COMMON(0,2,1));
	MR_r3 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__list__filter_2_0,
		minigit__cmd_commit_3_0_i5);
MR_def_label(minigit__cmd_commit_3_0, 5)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_NE(MR_r1,0)) {
		MR_GOTO_LAB(minigit__cmd_commit_3_0_i6);
	}
	MR_r1 = ((MR_Word) MR_string_const("Nothing to commit\n", 18));
	MR_np_call_localret_ent(io__write_string_3_0,
		minigit__cmd_commit_3_0_i8);
MR_def_label(minigit__cmd_commit_3_0, 8)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = (MR_Integer) 1;
	MR_succip_word = MR_sv(11);
	MR_decr_sp(11);
	MR_np_tailcall_ent(io__set_exit_status_3_0);
MR_def_label(minigit__cmd_commit_3_0, 6)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(1) = MR_r1;
	MR_r1 = ((MR_Word) MR_string_const(".minigit/HEAD", 13));
	MR_np_call_localret_ent(minigit__read_file_string_4_0,
		minigit__cmd_commit_3_0_i10);
MR_def_label(minigit__cmd_commit_3_0, 10)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_np_call_localret_ent(fn__string__strip_1_0,
		minigit__cmd_commit_3_0_i11);
MR_def_label(minigit__cmd_commit_3_0, 11)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if ((strcmp((char *) ((MR_Word *) MR_r1), MR_string_const("", 0)) != 0)) {
		MR_GOTO_LAB(minigit__cmd_commit_3_0_i12);
	}
	MR_r2 = MR_sv(1);
	MR_sv(1) = ((MR_Word) MR_string_const("NONE", 4));
	MR_r1 = MR_sv(2);
	{
	MR_Word MR_tempr1;
	{
	MR_Integer	T;
#define	MR_PROC_LABEL	mercury__minigit__cmd_commit_3_0
	MR_OBTAIN_GLOBAL_LOCK("get_unix_timestamp");
{
#line 24 "minigit.m"
T = (MR_Integer)time(NULL);;}
#line 775 "Mercury/cs/minigit.c"
	MR_RELEASE_GLOBAL_LOCK("get_unix_timestamp");
	MR_tempr1 = T;
#undef	MR_PROC_LABEL
	}
	MR_sv(5) = MR_tempr1;
	MR_sv(2) = MR_r1;
	}
	MR_np_call_localret_ent(list__sort_2_0,
		minigit__cmd_commit_3_0_i15);
MR_def_label(minigit__cmd_commit_3_0, 12)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r2 = MR_sv(1);
	MR_sv(1) = MR_r1;
	MR_r1 = MR_sv(2);
	{
	MR_Word MR_tempr1;
	{
	MR_Integer	T;
#define	MR_PROC_LABEL	mercury__minigit__cmd_commit_3_0
	MR_OBTAIN_GLOBAL_LOCK("get_unix_timestamp");
{
#line 24 "minigit.m"
T = (MR_Integer)time(NULL);;}
#line 799 "Mercury/cs/minigit.c"
	MR_RELEASE_GLOBAL_LOCK("get_unix_timestamp");
	MR_tempr1 = T;
#undef	MR_PROC_LABEL
	}
	MR_sv(5) = MR_tempr1;
	MR_sv(2) = MR_r1;
	}
	MR_np_call_localret_ent(list__sort_2_0,
		minigit__cmd_commit_3_0_i15);
MR_def_label(minigit__cmd_commit_3_0, 15)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_np_call_localret_ent(minigit__get_file_hashes_4_0,
		minigit__cmd_commit_3_0_i16);
MR_def_label(minigit__cmd_commit_3_0, 16)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = ((MR_Word) MR_TAG_COMMON(0,0,0));
	MR_r2 = MR_sv(2);
	MR_r3 = ((MR_Word) MR_TAG_COMMON(0,2,2));
	MR_r4 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__list__map_2_0,
		minigit__cmd_commit_3_0_i18);
MR_def_label(minigit__cmd_commit_3_0, 18)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = ((MR_Word) MR_string_const("\n", 1));
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__string__join_list_2_0,
		minigit__cmd_commit_3_0_i19);
MR_def_label(minigit__cmd_commit_3_0, 19)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r2 = MR_sv(5);
	MR_sv(5) = MR_r1;
	MR_sv(2) = ((MR_Word) MR_string_const("parent: ", 8));
	MR_sv(3) = ((MR_Word) MR_string_const("\n", 1));
	MR_sv(4) = ((MR_Word) MR_string_const("timestamp: ", 11));
	MR_r1 = MR_r2;
	MR_np_call_localret_ent(fn__string__int_to_string_1_0,
		minigit__cmd_commit_3_0_i20);
MR_def_label(minigit__cmd_commit_3_0, 20)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_sv(5);
	MR_sv(5) = MR_r1;
	MR_sv(6) = ((MR_Word) MR_string_const("\n", 1));
	MR_sv(7) = ((MR_Word) MR_string_const("message: ", 9));
	MR_sv(8) = ((MR_Word) MR_string_const("\n", 1));
	MR_sv(9) = ((MR_Word) MR_string_const("files:\n", 7));
	MR_r1 = MR_tempr1;
	MR_r2 = ((MR_Word) MR_string_const("\n", 1));
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i21);
MR_def_label(minigit__cmd_commit_3_0, 21)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(9);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i22);
MR_def_label(minigit__cmd_commit_3_0, 22)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(8);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i23);
MR_def_label(minigit__cmd_commit_3_0, 23)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(10);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i24);
MR_def_label(minigit__cmd_commit_3_0, 24)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(7);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i25);
MR_def_label(minigit__cmd_commit_3_0, 25)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(6);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i26);
MR_def_label(minigit__cmd_commit_3_0, 26)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(5);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i27);
MR_def_label(minigit__cmd_commit_3_0, 27)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(4);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i28);
MR_def_label(minigit__cmd_commit_3_0, 28)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(3);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i29);
MR_def_label(minigit__cmd_commit_3_0, 29)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(1);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i30);
MR_def_label(minigit__cmd_commit_3_0, 30)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(2);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i31);
MR_def_label(minigit__cmd_commit_3_0, 31)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(10) = MR_r1;
	MR_np_call_localret_ent(fn__minigit__mini_hash_1_0,
		minigit__cmd_commit_3_0_i32);
MR_def_label(minigit__cmd_commit_3_0, 32)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(1) = MR_r1;
	MR_r1 = ((MR_Word) MR_string_const(".minigit/commits/", 17));
	MR_r2 = MR_sv(1);
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i33);
MR_def_label(minigit__cmd_commit_3_0, 33)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r2 = MR_sv(10);
	MR_np_call_localret_ent(minigit__write_file_4_0,
		minigit__cmd_commit_3_0_i34);
MR_def_label(minigit__cmd_commit_3_0, 34)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(10) = ((MR_Word) MR_string_const(".minigit/HEAD", 13));
	MR_r1 = MR_sv(1);
	MR_r2 = ((MR_Word) MR_string_const("\n", 1));
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i35);
MR_def_label(minigit__cmd_commit_3_0, 35)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(10);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(minigit__write_file_4_0,
		minigit__cmd_commit_3_0_i36);
MR_def_label(minigit__cmd_commit_3_0, 36)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const(".minigit/index", 14));
	MR_r2 = ((MR_Word) MR_string_const("", 0));
	MR_np_call_localret_ent(minigit__write_file_4_0,
		minigit__cmd_commit_3_0_i37);
MR_def_label(minigit__cmd_commit_3_0, 37)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(10) = ((MR_Word) MR_string_const("Committed ", 10));
	MR_r1 = MR_sv(1);
	MR_r2 = ((MR_Word) MR_string_const("\n", 1));
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i38);
MR_def_label(minigit__cmd_commit_3_0, 38)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(10);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__cmd_commit_3_0_i39);
MR_def_label(minigit__cmd_commit_3_0, 39)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_succip_word = MR_sv(11);
	MR_decr_sp(11);
	MR_np_tailcall_ent(io__write_string_3_0);
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE


MR_BEGIN_MODULE(minigit_module3)
	MR_init_entry1(minigit__get_file_hashes_4_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__minigit__get_file_hashes_4_0);
	MR_init_label4(minigit__get_file_hashes_4_0,16,4,5,7)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'get_file_hashes'/4 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(minigit__get_file_hashes_4_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_NE(MR_r1,0)) {
		MR_GOTO_LAB(minigit__get_file_hashes_4_0_i16);
	}
	MR_r1 = (MR_Unsigned) 0U;
	MR_proceed();
MR_def_label(minigit__get_file_hashes_4_0, 16)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(3);
	MR_sv(3) = ((MR_Word) MR_succip);
	MR_sv(2) = MR_tfield(1, MR_r1, 0);
	MR_sv(1) = MR_tfield(1, MR_r1, 1);
	MR_r1 = MR_sv(2);
	MR_np_call_localret_ent(minigit__read_file_string_4_0,
		minigit__get_file_hashes_4_0_i4);
MR_def_label(minigit__get_file_hashes_4_0, 4)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_np_call_localret_ent(fn__minigit__mini_hash_1_0,
		minigit__get_file_hashes_4_0_i5);
MR_def_label(minigit__get_file_hashes_4_0, 5)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tag_alloc_heap(MR_tempr1, 0, (MR_Integer) 2);
	MR_tfield(0, MR_tempr1, 0) = MR_sv(2);
	MR_tfield(0, MR_tempr1, 1) = MR_r1;
	MR_sv(2) = MR_tempr1;
	MR_r1 = MR_sv(1);
	}
	MR_np_localcall_lab(minigit__get_file_hashes_4_0,
		minigit__get_file_hashes_4_0_i7);
MR_def_label(minigit__get_file_hashes_4_0, 7)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tag_alloc_heap(MR_tempr1, 1, (MR_Integer) 2);
	MR_tfield(1, MR_tempr1, 0) = MR_sv(2);
	MR_tfield(1, MR_tempr1, 1) = MR_r1;
	MR_r1 = MR_tempr1;
	MR_decr_sp_and_return(3);
	}
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE


MR_BEGIN_MODULE(minigit_module4)
	MR_init_entry1(minigit__cmd_log_2_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__minigit__cmd_log_2_0);
	MR_init_label3(minigit__cmd_log_2_0,2,3,4)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'cmd_log'/2 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(minigit__cmd_log_2_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(1);
	MR_sv(1) = ((MR_Word) MR_succip);
	MR_r1 = ((MR_Word) MR_string_const(".minigit/HEAD", 13));
	MR_np_call_localret_ent(minigit__read_file_string_4_0,
		minigit__cmd_log_2_0_i2);
MR_def_label(minigit__cmd_log_2_0, 2)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_np_call_localret_ent(fn__string__strip_1_0,
		minigit__cmd_log_2_0_i3);
MR_def_label(minigit__cmd_log_2_0, 3)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if ((strcmp((char *) ((MR_Word *) MR_r1), MR_string_const("", 0)) != 0)) {
		MR_GOTO_LAB(minigit__cmd_log_2_0_i4);
	}
	MR_r1 = ((MR_Word) MR_string_const("No commits\n", 11));
	MR_succip_word = MR_sv(1);
	MR_decr_sp(1);
	MR_np_tailcall_ent(io__write_string_3_0);
MR_def_label(minigit__cmd_log_2_0, 4)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_succip_word = MR_sv(1);
	MR_decr_sp(1);
	MR_np_tailcall_ent(minigit__print_log_3_0);
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE


MR_BEGIN_MODULE(minigit_module5)
	MR_init_entry1(minigit__print_log_3_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__minigit__print_log_3_0);
	MR_init_label10(minigit__print_log_3_0,6,7,10,11,12,13,14,15,16,17)
	MR_init_label6(minigit__print_log_3_0,18,19,20,21,22,39)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'print_log'/3 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(minigit__print_log_3_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(5);
	MR_sv(5) = ((MR_Word) MR_succip);
	if ((strcmp((char *) ((MR_Word *) MR_r1), MR_string_const("", 0)) == 0)) {
		MR_GOTO_LAB(minigit__print_log_3_0_i39);
	}
	if ((strcmp((char *) ((MR_Word *) MR_r1), MR_string_const("NONE", 4)) == 0)) {
		MR_GOTO_LAB(minigit__print_log_3_0_i39);
	}
	MR_sv(1) = MR_r1;
	MR_r1 = ((MR_Word) MR_string_const(".minigit/commits/", 17));
	MR_r2 = MR_sv(1);
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__print_log_3_0_i6);
MR_def_label(minigit__print_log_3_0, 6)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_np_call_localret_ent(minigit__read_file_string_4_0,
		minigit__print_log_3_0_i7);
MR_def_label(minigit__print_log_3_0, 7)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if ((strcmp((char *) ((MR_Word *) MR_r1), MR_string_const("", 0)) == 0)) {
		MR_GOTO_LAB(minigit__print_log_3_0_i39);
	}
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = (MR_Integer) 10;
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__string__split_at_char_2_0,
		minigit__print_log_3_0_i10);
MR_def_label(minigit__print_log_3_0, 10)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(4) = MR_r1;
	MR_r2 = ((MR_Word) MR_string_const("timestamp: ", 11));
	MR_np_call_localret_ent(minigit__get_field_3_0,
		minigit__print_log_3_0_i11);
MR_def_label(minigit__print_log_3_0, 11)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(3) = MR_r1;
	MR_r1 = MR_sv(4);
	MR_r2 = ((MR_Word) MR_string_const("message: ", 9));
	MR_np_call_localret_ent(minigit__get_field_3_0,
		minigit__print_log_3_0_i12);
MR_def_label(minigit__print_log_3_0, 12)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_sv(4);
	MR_sv(4) = MR_r1;
	MR_r1 = MR_tempr1;
	MR_r2 = ((MR_Word) MR_string_const("parent: ", 8));
	}
	MR_np_call_localret_ent(minigit__get_field_3_0,
		minigit__print_log_3_0_i13);
MR_def_label(minigit__print_log_3_0, 13)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_sv(1);
	MR_sv(1) = MR_r1;
	MR_sv(2) = ((MR_Word) MR_string_const("commit ", 7));
	MR_r1 = MR_tempr1;
	MR_r2 = ((MR_Word) MR_string_const("\n", 1));
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__print_log_3_0_i14);
MR_def_label(minigit__print_log_3_0, 14)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(2);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__print_log_3_0_i15);
MR_def_label(minigit__print_log_3_0, 15)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_np_call_localret_ent(io__write_string_3_0,
		minigit__print_log_3_0_i16);
MR_def_label(minigit__print_log_3_0, 16)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_sv(3);
	MR_sv(3) = ((MR_Word) MR_string_const("Date: ", 6));
	MR_r1 = MR_tempr1;
	MR_r2 = ((MR_Word) MR_string_const("\n", 1));
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__print_log_3_0_i17);
MR_def_label(minigit__print_log_3_0, 17)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(3);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__print_log_3_0_i18);
MR_def_label(minigit__print_log_3_0, 18)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_np_call_localret_ent(io__write_string_3_0,
		minigit__print_log_3_0_i19);
MR_def_label(minigit__print_log_3_0, 19)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_sv(4);
	MR_sv(4) = ((MR_Word) MR_string_const("Message: ", 9));
	MR_r1 = MR_tempr1;
	MR_r2 = ((MR_Word) MR_string_const("\n\n", 2));
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__print_log_3_0_i20);
MR_def_label(minigit__print_log_3_0, 20)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(4);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__print_log_3_0_i21);
MR_def_label(minigit__print_log_3_0, 21)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_np_call_localret_ent(io__write_string_3_0,
		minigit__print_log_3_0_i22);
MR_def_label(minigit__print_log_3_0, 22)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = MR_sv(1);
	MR_succip_word = MR_sv(5);
	if ((strcmp((char *) ((MR_Word *) MR_r1), MR_string_const("", 0)) == 0)) {
		MR_GOTO_LAB(minigit__print_log_3_0_i39);
	}
	if ((strcmp((char *) ((MR_Word *) MR_r1), MR_string_const("NONE", 4)) == 0)) {
		MR_GOTO_LAB(minigit__print_log_3_0_i39);
	}
	MR_sv(1) = MR_r1;
	MR_r1 = ((MR_Word) MR_string_const(".minigit/commits/", 17));
	MR_r2 = MR_sv(1);
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		minigit__print_log_3_0_i6);
MR_def_label(minigit__print_log_3_0, 39)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_decr_sp_and_return(5);
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE

MR_decl_entry(fn__string__to_char_list_1_0);
MR_decl_entry(fn__uint64__cast_from_int_1_0);
extern const MR_TypeCtorInfo_Struct mercury_data_builtin__type_ctor_info_character_0;
extern const MR_TypeCtorInfo_Struct mercury_data_builtin__type_ctor_info_uint64_0;
MR_decl_entry(list__foldl_4_0);
MR_decl_entry(fn__string__from_char_list_1_0);

MR_BEGIN_MODULE(minigit_module6)
	MR_init_entry1(fn__minigit__mini_hash_1_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__fn__minigit__mini_hash_1_0);
	MR_init_label4(fn__minigit__mini_hash_1_0,2,3,5,6)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'mini_hash'/2 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(fn__minigit__mini_hash_1_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(2);
	MR_sv(2) = ((MR_Word) MR_succip);
	MR_np_call_localret_ent(fn__string__to_char_list_1_0,
		fn__minigit__mini_hash_1_0_i2);
MR_def_label(fn__minigit__mini_hash_1_0, 2)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(1) = MR_r1;
	MR_r1 = (MR_Integer) 1469598103934665603;
	MR_np_call_localret_ent(fn__uint64__cast_from_int_1_0,
		fn__minigit__mini_hash_1_0_i3);
MR_def_label(fn__minigit__mini_hash_1_0, 3)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = ((MR_Word) MR_CHAR_CTOR_ADDR);
	MR_r2 = ((MR_Word) MR_UINT64_CTOR_ADDR);
	MR_r3 = ((MR_Word) MR_TAG_COMMON(0,2,3));
	MR_r4 = MR_sv(1);
	MR_r5 = MR_tempr1;
	}
	MR_np_call_localret_ent(list__foldl_4_0,
		fn__minigit__mini_hash_1_0_i5);
MR_def_label(fn__minigit__mini_hash_1_0, 5)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r2 = (MR_Integer) 15;
	MR_np_call_localret_ent(fn__minigit__nibble_chars_2_0,
		fn__minigit__mini_hash_1_0_i6);
MR_def_label(fn__minigit__mini_hash_1_0, 6)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_succip_word = MR_sv(2);
	MR_decr_sp(2);
	MR_np_tailcall_ent(fn__string__from_char_list_1_0);
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE

MR_decl_entry(fn__char__to_int_1_0);

MR_BEGIN_MODULE(minigit_module7)
	MR_init_entry1(minigit__update_hash_3_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__minigit__update_hash_3_0);
	MR_init_label3(minigit__update_hash_3_0,2,3,4)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'update_hash'/3 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(minigit__update_hash_3_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(2);
	MR_sv(2) = ((MR_Word) MR_succip);
	MR_sv(1) = MR_r2;
	MR_np_call_localret_ent(fn__char__to_int_1_0,
		minigit__update_hash_3_0_i2);
MR_def_label(minigit__update_hash_3_0, 2)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_np_call_localret_ent(fn__uint64__cast_from_int_1_0,
		minigit__update_hash_3_0_i3);
MR_def_label(minigit__update_hash_3_0, 3)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(1) = MR_uint64_to_word((MR_word_to_uint64(MR_sv(1)) ^ MR_word_to_uint64(MR_r1)));
	MR_r1 = (MR_Integer) 1099511628211;
	MR_np_call_localret_ent(fn__uint64__cast_from_int_1_0,
		minigit__update_hash_3_0_i4);
MR_def_label(minigit__update_hash_3_0, 4)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = MR_uint64_to_word((MR_word_to_uint64(MR_sv(1)) * MR_word_to_uint64(MR_r1)));
	MR_decr_sp_and_return(2);
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE

MR_decl_entry(fn__f_117_105_110_116_54_52_95_95_62_62_2_0);
MR_decl_entry(fn__uint64__cast_to_int_1_0);
MR_decl_entry(fn__char__det_from_int_1_0);

MR_BEGIN_MODULE(minigit_module8)
	MR_init_entry1(fn__minigit__nibble_chars_2_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__fn__minigit__nibble_chars_2_0);
	MR_init_label9(fn__minigit__nibble_chars_2_0,27,3,4,5,7,6,9,10,12)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'nibble_chars'/3 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(fn__minigit__nibble_chars_2_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_GE(MR_r2,0)) {
		MR_GOTO_LAB(fn__minigit__nibble_chars_2_0_i27);
	}
	MR_r1 = (MR_Unsigned) 0U;
	MR_proceed();
MR_def_label(fn__minigit__nibble_chars_2_0, 27)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(4);
	MR_sv(4) = ((MR_Word) MR_succip);
	MR_sv(2) = MR_r1;
	MR_sv(1) = MR_r2;
	MR_r2 = (MR_Integer) ((MR_Unsigned) ((MR_Integer) MR_r2) * (MR_Unsigned) (MR_Integer) 4);
	MR_np_call_localret_ent(fn__f_117_105_110_116_54_52_95_95_62_62_2_0,
		fn__minigit__nibble_chars_2_0_i3);
MR_def_label(fn__minigit__nibble_chars_2_0, 3)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(3) = MR_r1;
	MR_r1 = (MR_Integer) 15;
	MR_np_call_localret_ent(fn__uint64__cast_from_int_1_0,
		fn__minigit__nibble_chars_2_0_i4);
MR_def_label(fn__minigit__nibble_chars_2_0, 4)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = MR_uint64_to_word((MR_word_to_uint64(MR_sv(3)) & MR_word_to_uint64(MR_r1)));
	MR_np_call_localret_ent(fn__uint64__cast_to_int_1_0,
		fn__minigit__nibble_chars_2_0_i5);
MR_def_label(fn__minigit__nibble_chars_2_0, 5)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_GE(MR_r1,10)) {
		MR_GOTO_LAB(fn__minigit__nibble_chars_2_0_i6);
	}
	MR_sv(3) = MR_r1;
	MR_r1 = (MR_Integer) 48;
	MR_np_call_localret_ent(fn__char__to_int_1_0,
		fn__minigit__nibble_chars_2_0_i7);
MR_def_label(fn__minigit__nibble_chars_2_0, 7)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = (MR_Integer) ((MR_Unsigned) ((MR_Integer) MR_r1) + (MR_Unsigned) ((MR_Integer) MR_sv(3)));
	MR_np_call_localret_ent(fn__char__det_from_int_1_0,
		fn__minigit__nibble_chars_2_0_i10);
MR_def_label(fn__minigit__nibble_chars_2_0, 6)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(3) = MR_r1;
	MR_r1 = (MR_Integer) 97;
	MR_np_call_localret_ent(fn__char__to_int_1_0,
		fn__minigit__nibble_chars_2_0_i9);
MR_def_label(fn__minigit__nibble_chars_2_0, 9)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = (MR_Integer) ((MR_Unsigned) (MR_Integer) ((MR_Unsigned) ((MR_Integer) MR_r1) + (MR_Unsigned) ((MR_Integer) MR_sv(3))) - (MR_Unsigned) (MR_Integer) 10);
	MR_np_call_localret_ent(fn__char__det_from_int_1_0,
		fn__minigit__nibble_chars_2_0_i10);
MR_def_label(fn__minigit__nibble_chars_2_0, 10)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(2);
	MR_sv(2) = MR_tempr1;
	MR_r2 = (MR_Integer) ((MR_Unsigned) ((MR_Integer) MR_sv(1)) - (MR_Unsigned) (MR_Integer) 1);
	}
	MR_np_localcall_lab(fn__minigit__nibble_chars_2_0,
		fn__minigit__nibble_chars_2_0_i12);
MR_def_label(fn__minigit__nibble_chars_2_0, 12)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_tag_alloc_heap(MR_r2, 1, (MR_Integer) 2);
	MR_tfield(1, MR_r2, 0) = MR_sv(2);
	MR_tfield(1, MR_r2, 1) = MR_r1;
	MR_r1 = MR_r2;
	MR_decr_sp_and_return(4);
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE

MR_decl_entry(io__open_output_4_0);
MR_decl_entry(io__write_string_4_0);
MR_decl_entry(io__close_output_3_0);

MR_BEGIN_MODULE(minigit_module9)
	MR_init_entry1(minigit__write_file_4_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__minigit__write_file_4_0);
	MR_init_label3(minigit__write_file_4_0,2,5,7)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'write_file'/4 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(minigit__write_file_4_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(2);
	MR_sv(2) = ((MR_Word) MR_succip);
	MR_sv(1) = MR_r2;
	MR_np_call_localret_ent(io__open_output_4_0,
		minigit__write_file_4_0_i2);
MR_def_label(minigit__write_file_4_0, 2)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_NE(MR_tag(MR_r1),0)) {
		MR_GOTO_LAB(minigit__write_file_4_0_i7);
	}
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_sv(1);
	MR_sv(1) = MR_tfield(0, MR_r1, 0);
	MR_r1 = MR_sv(1);
	MR_r2 = MR_tempr1;
	}
	MR_np_call_localret_ent(io__write_string_4_0,
		minigit__write_file_4_0_i5);
MR_def_label(minigit__write_file_4_0, 5)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = MR_sv(1);
	MR_succip_word = MR_sv(2);
	MR_decr_sp(2);
	MR_np_tailcall_ent(io__close_output_3_0);
MR_def_label(minigit__write_file_4_0, 7)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_decr_sp_and_return(2);
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE


MR_BEGIN_MODULE(minigit_module10)
	MR_init_entry1(minigit__read_file_string_4_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__minigit__read_file_string_4_0);
	MR_init_label4(minigit__read_file_string_4_0,2,5,6,3)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'read_file_string'/4 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(minigit__read_file_string_4_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(2);
	MR_sv(2) = ((MR_Word) MR_succip);
	MR_np_call_localret_ent(io__open_input_4_0,
		minigit__read_file_string_4_0_i2);
MR_def_label(minigit__read_file_string_4_0, 2)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_NE(MR_tag(MR_r1),0)) {
		MR_GOTO_LAB(minigit__read_file_string_4_0_i3);
	}
	MR_sv(1) = MR_tfield(0, MR_r1, 0);
	MR_r1 = MR_sv(1);
	MR_np_call_localret_ent(io__read_file_as_string_4_0,
		minigit__read_file_string_4_0_i5);
MR_def_label(minigit__read_file_string_4_0, 5)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_sv(1);
	MR_sv(1) = MR_r1;
	MR_r1 = MR_tempr1;
	}
	MR_np_call_localret_ent(io__close_input_3_0,
		minigit__read_file_string_4_0_i6);
MR_def_label(minigit__read_file_string_4_0, 6)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (MR_INT_NE(MR_tag(MR_sv(1)),0)) {
		MR_GOTO_LAB(minigit__read_file_string_4_0_i3);
	}
	MR_r1 = MR_tfield(0, MR_sv(1), 0);
	MR_decr_sp_and_return(2);
MR_def_label(minigit__read_file_string_4_0, 3)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = ((MR_Word) MR_string_const("", 0));
	MR_decr_sp_and_return(2);
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE

MR_decl_entry(string__remove_prefix_3_0);

MR_BEGIN_MODULE(minigit_module11)
	MR_init_entry1(minigit__get_field_3_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__minigit__get_field_3_0);
	MR_init_label3(minigit__get_field_3_0,3,6,4)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'get_field'/3 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(minigit__get_field_3_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(3);
	MR_sv(3) = ((MR_Word) MR_succip);
	if (MR_INT_NE(MR_r1,0)) {
		MR_GOTO_LAB(minigit__get_field_3_0_i3);
	}
	MR_r1 = ((MR_Word) MR_string_const("", 0));
	MR_decr_sp_and_return(3);
MR_def_label(minigit__get_field_3_0, 3)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_sv(2) = MR_tfield(1, MR_r1, 1);
	MR_sv(1) = MR_r2;
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_r2;
	MR_r2 = MR_tfield(1, MR_tempr1, 0);
	}
	MR_np_call_localret_ent(string__remove_prefix_3_0,
		minigit__get_field_3_0_i6);
MR_def_label(minigit__get_field_3_0, 6)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	if (!(MR_r1)) {
		MR_GOTO_LAB(minigit__get_field_3_0_i4);
	}
	MR_r1 = MR_r2;
	MR_decr_sp_and_return(3);
MR_def_label(minigit__get_field_3_0, 4)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r2 = MR_sv(1);
	MR_r1 = MR_sv(2);
	MR_succip_word = MR_sv(3);
	if (MR_INT_NE(MR_r1,0)) {
		MR_GOTO_LAB(minigit__get_field_3_0_i3);
	}
	MR_r1 = ((MR_Word) MR_string_const("", 0));
	MR_decr_sp_and_return(3);
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE


MR_BEGIN_MODULE(minigit_module12)
	MR_init_entry1(minigit__non_empty_string_1_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__minigit__non_empty_string_1_0);
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'non_empty_string'/1 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(minigit__non_empty_string_1_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_r1 = (strcmp((char *) ((MR_Word *) MR_r1), MR_string_const("", 0)) != 0);
	MR_proceed();
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE


MR_BEGIN_MODULE(minigit_module13)
	MR_init_entry1(fn__minigit__IntroducedFrom__func__cmd_commit__117__1_1_0);
	MR_INIT_PROC_LAYOUT_ADDR(mercury__fn__minigit__IntroducedFrom__func__cmd_commit__117__1_1_0);
	MR_init_label1(fn__minigit__IntroducedFrom__func__cmd_commit__117__1_1_0,2)
MR_BEGIN_CODE

/*-------------------------------------------------------------------------*/
/* code for 'IntroducedFrom__func__cmd_commit__117__1'/2 mode 0 */
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_local_thread_engine_base
#endif
MR_def_static(fn__minigit__IntroducedFrom__func__cmd_commit__117__1_1_0)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	MR_incr_sp(2);
	MR_sv(2) = ((MR_Word) MR_succip);
	MR_sv(1) = MR_tfield(0, MR_r1, 0);
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = ((MR_Word) MR_string_const(" ", 1));
	MR_r2 = MR_tfield(0, MR_tempr1, 1);
	}
	MR_np_call_localret_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0,
		fn__minigit__IntroducedFrom__func__cmd_commit__117__1_1_0_i2);
MR_def_label(fn__minigit__IntroducedFrom__func__cmd_commit__117__1_1_0, 2)
	MR_MAYBE_INIT_LOCAL_THREAD_ENGINE_BASE
	{
	MR_Word MR_tempr1;
	MR_tempr1 = MR_r1;
	MR_r1 = MR_sv(1);
	MR_r2 = MR_tempr1;
	MR_succip_word = MR_sv(2);
	MR_decr_sp(2);
	MR_np_tailcall_ent(fn__f_115_116_114_105_110_103_95_95_43_43_2_0);
	}
#ifdef MR_maybe_local_thread_engine_base
	#undef MR_maybe_local_thread_engine_base
	#define MR_maybe_local_thread_engine_base MR_thread_engine_base
#endif
MR_END_MODULE

static void mercury__minigit_maybe_bunch_0(void)
{
	minigit_module0();
	minigit_module1();
	minigit_module2();
	minigit_module3();
	minigit_module4();
	minigit_module5();
	minigit_module6();
	minigit_module7();
	minigit_module8();
	minigit_module9();
	minigit_module10();
	minigit_module11();
	minigit_module12();
	minigit_module13();
}

/* suppress gcc -Wmissing-decls warnings */
void mercury__minigit__init(void);
void mercury__minigit__init_type_tables(void);
void mercury__minigit__init_debugger(void);
#ifdef MR_DEEP_PROFILING
void mercury__minigit__write_out_proc_statics(FILE *deep_fp, FILE *procrep_fp);
#endif
#ifdef MR_RECORD_TERM_SIZES
void mercury__minigit__init_complexity_procs(void);
#endif
#ifdef MR_THREADSCOPE
void mercury__minigit__init_threadscope_string_table(void);
#endif
const char *mercury__minigit__grade_check(void);

void mercury__minigit__init(void)
{
	static MR_bool done = MR_FALSE;
	if (done) {
		return;
	}
	done = MR_TRUE;
	mercury__minigit_maybe_bunch_0();
	mercury__minigit__init_debugger();
}

void mercury__minigit__init_type_tables(void)
{
	static MR_bool done = MR_FALSE;
	if (done) {
		return;
	}
	done = MR_TRUE;
}


void mercury__minigit__init_debugger(void)
{
	static MR_bool done = MR_FALSE;
	if (done) {
		return;
	}
	done = MR_TRUE;
}

#ifdef MR_DEEP_PROFILING

void mercury__minigit__write_out_proc_statics(FILE *deep_fp, FILE *procrep_fp)
{
	MR_write_out_module_proc_reps_start(procrep_fp, &mercury_data__module_layout__minigit);
	MR_write_out_module_proc_reps_end(procrep_fp);
}

#endif

#ifdef MR_RECORD_TERM_SIZES

void mercury__minigit__init_complexity_procs(void)
{
}

#endif

#ifdef MR_THREADSCOPE

void mercury__minigit__init_threadscope_string_table(void)
{
}

#endif

// Ensure everything is compiled with the same grade.
const char *mercury__minigit__grade_check(void)
{
    return &MR_GRADE_VAR;
}
