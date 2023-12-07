module vf.base.la_switch;

import vf.traits : Switch;


template
LaSwitch(LaType,ARGS...) {
    void
    sense (LaType la_type) {
        Switch!(LaType,ARGS) (la_type);
    }
}
