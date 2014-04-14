/*
 * midi_commands.h
 *
 *  Created on: 13-04-2014
 *      Author: blazi
 */

#ifndef MIDI_COMMANDS_H_
#define MIDI_COMMANDS_H_

#define NOTE_ON     9
#define NOTE_OFF    8
#define PITCH       14

short midi_data_bytes(short command);

#endif /* MIDI_COMMANDS_H_ */
