module vf.base.enterable;

import vf.base.rasterable : RasterAble;
import xcb.xproto         : XCB_EVENT_MASK_BUTTON_PRESS;
import vf.input.vf.la  : ElementUpdatedLa;
import vf.input.vf.queue  : send_la;


LaType;
WX;

class 
EnterAble : RasterAble {
    alias THIS      = typeof(this);
    alias EnterAble = typeof(this);

    Enter enter;

    void 
    each (void delegate( typeof(this) e ) dg) {
        enter.each (dg);
    }

    void 
    each_recursive (void delegate( typeof(this) e ) dg) {
        enter.each_recursive (dg);
    }

    override void 
    redraw () {
        send_la (ElementUpdatedLa(this)); // updated, need redraw rect, in window
        // find element in World
        //   get location
        //   get size
        // find Window with World
        //   get world_offset
        //   test ( element.location and element.size ) in window.area
        //     redraw window rect <- is Update element in window
    }

    override void 
    calc_size () {
        super.calc_size ();
        enter.calc_size (this);
    }

    void 
    calc_size (EnterAble outer) {
        final switch ( size_mode ) {
            case SIZE_MODE.OUTER: _size = outer.size; break;
            case SIZE_MODE.FIXED:  calc_size (); break;
            case SIZE_MODE.INTER: _size = outer.size; break;
        }
    }

    override void 
    sense (LaType la_type) {
        super.sense (la_type);
        enter.sense (la_type);  // recursive
    }

    override void 
    to_raster (BaseRasterizer rasterizer) {
        super.to_raster (rasterizer);
        enter.to_raster (rasterizer);
    }

    override void 
    draw() {
        super.draw ();
        enter.draw ();
    }


    struct 
    Enter {
        EnterAble[] arr;
        alias arr this;

        void 
        sense (LaType la_type) {
            foreach (ref o; arr)
                o.sense (la_type);
        }


        void 
        each (void delegate( EnterAble e ) dg) {
            foreach (ref o; arr)
                dg (o);
        }

        void 
        each_recursive (void delegate( EnterAble e ) dg) {
            foreach (ref o; enter) {
                dg (o);
                o.each_recursive (dg);
            }
        }


        auto 
        size (EnterAble outer) {
            Size _size;

            foreach (o; arr) {
                o.calc_size (outer);
                _size.grow (o.size);
            }

            return _size;
        }


        void 
        calc_size (EnterAble outer) {
            foreach (ref o; arr)
                o.calc_size (outer);
        }


        override void 
        to_raster (BaseRasterizer rasterizer) {
            foreach (ref o; arr)
                o.to_raster (rasterizer);
        }


        override void 
        draw () {
            foreach (ref o; arr)
                o.draw ();
        }


        void 
        put (EnterAble o) {
            arr ~= o;
        }
    }
}
