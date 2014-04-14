/*
 * midi_commands.xc
 *
 *  Created on: 14-04-2014
 *      Author: blazi
 */

#include "midi_commands.h"

short midi_data_bytes(short command) {
    switch(command) {
    case NOTE_ON:
    case NOTE_OFF:
    case PITCH:
        return 2;
        break;
    }
    return 0;
}
