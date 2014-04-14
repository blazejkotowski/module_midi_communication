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
    time += MIDI_BITTIME;
    while(1) {
        select {
            case !is_receiving => p_MIDI_IN when pinsneq(1) :> void:
                t :> time;
                time += MIDI_BITTIME*3/2;
                is_receiving = 1;
                break;
            case is_receiving => t when timerafter(time) :> void:
                time += MIDI_BITTIME;
                if(bits_count++ < 8) {
                    p_MIDI_IN :> >> byte;
                }
                else {
                    p_MIDI_IN :> void;
                    _midi_parse(listener, message, byte >> 24);
                    if(message.state == message.length) {
                        listener.command(message);
                        message.state = 0;
                    }
                    bits_count = 0;
                    is_receiving = 0;
                }
                break;
        }
    }
}

void _midi_parse(client interface i_midi_listener listener, struct s_midi_message &message, unsigned byte) {
//    printf("0x%X ", byte);
    if(byte >> 7 == 1) {
        // Active sense
        if(byte == 0xfe) {
            message.state = 0;
            message.length = -1;
        }
        else {
            int command = byte >> 4;
            message.length = midi_data_bytes(command);
            message.channel =  (byte << 28) >> 28;
            message.command = command;
            message.state = 0;
        }
    }
    // Data byte
    else if(message.state < message.length) {
        message.data[message.state] = byte;
        message.state++;
    }
}

