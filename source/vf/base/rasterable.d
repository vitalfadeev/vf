module vf.base.rasterable;

import vf.base.layoutable : LayoutAble;
import vf.base.rasterizer : BaseRasterizer;


class RasterAble(Event,EVENT_TYPE,WX) : LayoutAble!(Event,EVENT_TYPE,WX)
{
    // drawable -> rasterable
    void to_raster( BaseRasterizer!WX rasterizer )
    {
        rasterizer.rasterize( ops );
    }
}

