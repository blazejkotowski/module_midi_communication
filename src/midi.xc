/*
 * midi.xc
 *
 *  Created on: 13-04-2014
 *      Author: blazi
 */

#include "midi.h"

[[combinable]]
void midi_receive(in port p_MIDI_IN, client interface i_midi_listener listener) {
    timer t;
    unsigned time, byte, is_receiving = 0, bits_count = 0;

    struct s_midi_message message;
    message.state = 0;
    message.length = -1;

    t :> time;

    while(1) {
        select {
            case !is_receiving => p_MIDI_IN when pinsneq(1) :> void:
                is_receiving = 1;
                time += MIDI_BITTIME/2;
                break;
            case is_receiving => t when timerafter(time) :> void:
                if(bits_count < 8)
                    p_MIDI_IN :> >> byte;
                else {
                    p_MIDI_IN :> void;
                    _midi_parse(message, byte >> 24);
                    if(message.state == message.length)
                        listener.command(message);
                    bits_count = 0;
                    byte = 0;
                    is_receiving = 0;
                }
                time += MIDI_BITTIME;
                break;
        }
    }
}

void _midi_parse(struct s_midi_message &message, unsigned byte) {
    // Command byte
    if(byte >> 7 == 1) {
        switch(byte >> 4) {
        case NOTE_ON:
            message.length = 2;
            message.channel = (byte << 28) >> 28;
            message.state = 0;
            message.command = NOTE_ON;
            break;
        case NOTE_OFF:
            message.length = 2;
            message.state = 0;
            message.command = NOTE_OFF;
            printf("NOTE OFF\n");
            break;
        }
    }
    // Data byte
    else if(message.state < message.length) {
        message.data[message.state] = byte;
        message.state++;
    }
}

