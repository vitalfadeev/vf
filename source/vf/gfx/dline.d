module vf.gfx.dline;


version(X86_64)
version(Win64)
{
    //
}
else  // native D
{
    import ldc.attributes;
    pragma( inline, false )
    @optStrategy("minsize")// minsize,none,optsize
    auto ref d_line(W,H,AW,AH)( W w, H h, AW absw, AH absh )
    {
        if ( absw == absh )
            return d_line_45( w, h, absw, absh );        // 45 degress /
        else
        if ( absw > absh )
            return d_line_30( w, h, absw, absh );        // 0..45 degress
        else
            return d_line_60( w, h, absw, absh );        // 45..90 degress
    }
}
