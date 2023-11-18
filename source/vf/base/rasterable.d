module vf.base.rasterable;

import vf.base.layoutable : LayoutAble;
import vf.base.rasterizer : BaseRasterizer;


class RasterAble(Event,EventType,WX) : LayoutAble!(Event,EventType,WX)
{
    alias RasterAble = typeof( this );

    // drawable -> rasterable
    void to_raster( BaseRasterizer!(RasterAble,Event,EventType,WX) rasterizer )
    {
        rasterizer.rasterize( this );
    }
}

