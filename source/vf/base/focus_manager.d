module vf.base.focus_manager;

import vf.traits : Switch;


struct 
FocusManager(E,LaType,EV_APP_ELEMENT_SET_FOCUS,EV_APP_ELEMENT_AUT_FOCUS,LA_TO_E) {
    E focused;

    void 
    set_focus () {
        focused = LA_TO_E;
    }

    void 
    aut_focus() {
        focused = null;
    }

    void 
    sense (LaType la_type) {  // this:RDI, la_type:RSI
        switch (la_type) {
            case EV_APP_ELEMENT_SET_FOCUS: set_focus (); break;
            case EV_APP_ELEMENT_AUT_FOCUS: aut_focus (); break;
            default:
                Switch !(LaType,EVS,_focused_sense) (la_type);
                //Switch!(A, EV_KEY,EV_BTN,EV_REL, _sense)( la_type );
        }
    }

    void
    _focused_sense (LaType la_type) {
        if (focused !is null) 
            focused.sense (la_type);
    }
}
