module vf.platforms.xcb.wx_px;

import vf.platforms.xcb.wx : WX;
import vf.platforms.xcb.px : PX;


PX to_px( WX wx )
{
    // Fixed -> short
    return PX( wx.x.a >> 16, wx.y.a >> 16 );
}
