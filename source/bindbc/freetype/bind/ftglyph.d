
//          Copyright 2019 - 2021 Michael D. Parker
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.freetype.bind.ftglyph;

import bindbc.freetype.config,
       bindbc.freetype.bind.freetype,
       bindbc.freetype.bind.ftimage,
       bindbc.freetype.bind.ftrender,
       bindbc.freetype.bind.fttypes;

alias FT_Glyph = FT_GlyphRec*;

struct FT_GlyphRec {
    FT_Library library;
    FT_Glyph_Class* clazz;
    FT_Glyph_Format format;
    FT_Vector advance;
}

alias FT_BitmapGlyph = FT_BitmapGlyphRec*;

struct FT_BitmapGlyphRec {
    FT_GlyphRec root;
    FT_Int left;
    FT_Int top;
    FT_Bitmap bitmap;
}

alias FT_OutlineGlyph = FT_OutlineGlyphRec*;

struct FT_OutlineGlyphRec {
    FT_GlyphRec root;
    FT_Outline outline;
}

alias FT_Glyph_BBox_Mode = int;
enum {
    FT_GLYPH_BBOX_UNSCALED = 0,
    FT_GLYPH_BBOX_SUBPIXELS = 0,
    FT_GLYPH_BBOX_GRIDFIT = 1,
    FT_GLYPH_BBOX_TRUNCATE = 2,
    FT_GLYPH_BBOX_PIXELS = 3
}

static if(staticBinding) {
	extern(C) @nogc nothrow {
        FT_Error FT_Get_Glyph(FT_GlyphSlot slot, FT_Glyph* aglyph);
        FT_Error FT_Glyph_Copy(FT_Glyph source, FT_Glyph* target);
        FT_Error FT_Glyph_Transform(FT_Glyph glyph, FT_Matrix* matrix, FT_Vector* delta);
        void FT_Glyph_Get_CBox(FT_Glyph glyph, FT_UInt bbox_mode, FT_BBox* acbox);
        FT_Error FT_Glyph_To_Bitmap(FT_Glyph* the_glyph, FT_Render_Mode render_mode, FT_Vector* origin, FT_Bool destroy);
        void FT_Done_Glyph(FT_Glyph glyph);
        void FT_Matrix_Multiply(const(FT_Matrix)* a, FT_Matrix* b);
        FT_Error FT_Matrix_Invert(FT_Matrix* matrix);
    }
    static if(ftSupport >= FTSupport.ft210) {
        FT_Error FT_New_Glyph(FT_Library library, FT_Glyph_Format format, FT_Glyph* aglyph);
    }
}
else {
    extern(C) @nogc nothrow {
        alias pFT_Get_Glyph = FT_Error function(FT_GlyphSlot slot, FT_Glyph* aglyph);
        alias pFT_Glyph_Copy = FT_Error function(FT_Glyph source, FT_Glyph* target);
        alias pFT_Glyph_Transform = FT_Error function(FT_Glyph glyph, FT_Matrix* matrix, FT_Vector* delta);
        alias pFT_Glyph_Get_CBox = void function(FT_Glyph glyph, FT_UInt bbox_mode, FT_BBox* acbox);
        alias pFT_Glyph_To_Bitmap = FT_Error function(FT_Glyph* the_glyph, FT_Render_Mode render_mode, FT_Vector* origin, FT_Bool destroy);
        alias pFT_Done_Glyph = void function(FT_Glyph glyph);
        alias pFT_Matrix_Multiply = void function(const(FT_Matrix)* a, FT_Matrix* b);
        alias pFT_Matrix_Invert = FT_Error function(FT_Matrix* matrix);

        static if(ftSupport >= FTSupport.ft210) {
            alias pFT_New_Glyph = FT_Error function(FT_Library library, FT_Glyph_Format format, FT_Glyph* aglyph);
        }
    }

    __gshared {
        pFT_Get_Glyph FT_Get_Glyph;
        pFT_Glyph_Copy FT_Glyph_Copy;
        pFT_Glyph_Transform FT_Glyph_Transform;
        pFT_Glyph_Get_CBox FT_Glyph_Get_CBox;
        pFT_Glyph_To_Bitmap FT_Glyph_To_Bitmap;
        pFT_Done_Glyph FT_Done_Glyph;
        pFT_Matrix_Multiply FT_Matrix_Multiply;
        pFT_Matrix_Invert FT_Matrix_Invert;

        static if(ftSupport >= FTSupport.ft210) {
            pFT_New_Glyph FT_New_Glyph;
        }
    }
}