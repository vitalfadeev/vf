module vf.base.rasterable;

import vf.base.layoutable : LayoutAble;
import vf.base.rasterizer : BaseRasterizer;


class RasterAble(Event,EventType,WX) : LayoutAble!(Event,EventType,WX)
{
    alias THIS           = typeof( this );
    alias RasterAble     = typeof( this );
    alias BaseRasterizer = .BaseRasterizer!THIS;

    // drawable -> rasterable
    void to_raster( BaseRasterizer rasterizer )
    {
        rasterizer.rasterize( this );
    }
}

