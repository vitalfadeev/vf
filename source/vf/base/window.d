module vf.base.window;

import vf.base.focus_manager : FocusManager;

E;
EV_APP_ELEMENT_SET_FOCUS;
EV_APP_ELEMENT_AUT_FOCUS;
la;
sx_to_wx;


class 
BaseWindow (LaType) {
    alias THIS       = typeof(this);
    alias BaseWindow = typeof(this);

    FocusManager!(
        E,
        LaType,
        EV_APP_ELEMENT_SET_FOCUS,
        EV_APP_ELEMENT_AUT_FOCUS,
        ()=>(la.element)
    ) focus_manager;


    //this(ARGS...)( ARGS args )
    //{
    //    _create_window( args );
    //    _create_renderer();
    //}

    void 
    sense (LaType la_type) {  // this:RDI, la_type:RSI
        switch (la_type) {
            case EV_APP_ELEMENT_FOCUSED: focus_manager.sense (la_type); break;
            case EV_REL: emit( EV_APP_WORLD_REL, sx_to_wx (la.rel) ); break;
            case EV_BTN: emit( EV_APP_WORLD_BTN, sx_to_wx (la.btn) ); break;
            default:
        }
    }

    void 
    move_to_center() {
        //
    }


    void 
    show() {
        //
    }


    void 
    draw() {
        //
    }


    //// private
    //void _create_window(ARGS...)( ARGS args )
    //{
    //    //
    //}

    //void _create_renderer()
    //{
    //    //
    //}
}
