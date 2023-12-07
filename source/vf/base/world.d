module vf.base.world;

import vf.base.element : Element;

LaType;
la;
LA_TO_DST;
Element;
EV_APP_WORLD_REL;
EV_APP_WORLD_BTN;


class BaseWorld : Element
{
    alias THIS      = typeof(this);
    alias BaseWorld = typeof(this);

    override
    void 
    sense (LaType la_type) {  // this:RDI, la_type:RSI
        // dst
        //   NULL : to each
        //   X    : to X
        switch (la_type) {
            case EV_APP_WORLD_REL:
            case EV_APP_WORLD_BTN:
                if (this.at(wx)) {  // wx - world x, rx - relative x
                    this.sense (la_type);
                    enter.sense (la_type);  // recursive
                }
                // send ev_btn in each e at wx
                //   recursive
                //
                // find e at wx
                //   if can focused
                //     set focus
                //     send ev_btn

                auto dst = LA_TO_DST;
                if (dst is null)  // to each
                    each ()
                        .sense (la_type);
                else              // to one
                    one (dst)
                        .sense (la_type);
                break;
            default:
        }
    }


    EachElementIter
    each (Element dst) {
        // each e in tree
        return EachElementIter();
    }


    OneElementIter
    one (Element dst) {
        // find first 'dst' in tree
        return OneElementIter();
    }


    struct 
    EachElementIter(E) {
        E cur;

        void 
        sense (LaType la_type) {  // this:RDI, la_type:RSI
            cur.sense (la_type);
        }
    }

    struct 
    OneElementIter(E) {
        E cur;

        void 
        sense (LaType la_type) {  // this:RDI, la_type:RSI
            cur.sense (la_type);
        }
    }
}
