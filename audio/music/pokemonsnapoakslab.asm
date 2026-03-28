Music_SnapOaksLab:
        channel_count 4
        channel 1, Music_SnapOaksLab_Ch1
        channel 2, Music_SnapOaksLab_Ch2
        channel 3, Music_SnapOaksLab_Ch3
        channel 4, Music_SnapOaksLab_Ch4

Music_SnapOaksLab_Ch1:
        tempo 148
        volume 7, 7
        vibrato 18, 3, 4
        duty_cycle 2
        stereo_panning TRUE, TRUE
        note_type 12, 11, 2
        octave 3
        note D_, 2
        octave 4
        note F#, 2
        note A_, 2
        note D_, 2
Music_SnapOaksLab_Ch1_Loop:
        sound_call Music_SnapOaksLab_Ch1_Pat1
        sound_call Music_SnapOaksLab_Ch1_Pat2
        sound_call Music_SnapOaksLab_Ch1_Pat3
        sound_call Music_SnapOaksLab_Ch1_Pat4
        sound_jump Music_SnapOaksLab_Ch1_Loop

Music_SnapOaksLab_Ch1_Pat1:
        octave 3
        note D_, 2
        octave 4
        note F#, 2
        note A_, 2
        note B_, 2
        note A_, 2
        note F#, 2
        note D_, 2
        octave 3
        note A_, 2
        sound_ret

Music_SnapOaksLab_Ch1_Pat2:
        octave 3
        note B_, 2
        octave 4
        note D_, 2
        note F#, 2
        note A_, 2
        note F#, 2
        note D_, 2
        note B_, 2
        octave 3
        note G_, 2
        sound_ret

Music_SnapOaksLab_Ch1_Pat3:
        octave 3
        note E_, 2
        octave 4
        note G_, 2
        note B_, 2
        note C#, 2
        note B_, 2
        note G_, 2
        note E_, 2
        octave 3
        note B_, 2
        sound_ret

Music_SnapOaksLab_Ch1_Pat4:
        octave 3
        note F#, 2
        octave 4
        note A_, 2
        note C#, 2
        note D_, 2
        note C#, 2
        note A_, 2
        note F#, 2
        octave 3
        note D_, 2
        sound_ret

Music_SnapOaksLab_Ch2:
        duty_cycle 1
        stereo_panning TRUE, FALSE
        vibrato 16, 2, 5
        note_type 12, 10, 4
        octave 2
        note D_, 2
        note A_, 2
        note D_, 2
        note A_, 2
Music_SnapOaksLab_Ch2_Loop:
        sound_call Music_SnapOaksLab_Ch2_Pat1
        sound_call Music_SnapOaksLab_Ch2_Pat2
        sound_call Music_SnapOaksLab_Ch2_Pat3
        sound_call Music_SnapOaksLab_Ch2_Pat4
        sound_jump Music_SnapOaksLab_Ch2_Loop

Music_SnapOaksLab_Ch2_Pat1:
        octave 2
        note D_, 4
        octave 3
        note A_, 4
        note D_, 4
        octave 2
        note A_, 4
        sound_ret

Music_SnapOaksLab_Ch2_Pat2:
        octave 2
        note B_, 4
        octave 3
        note F#, 4
        note B_, 4
        octave 2
        note F#, 4
        sound_ret

Music_SnapOaksLab_Ch2_Pat3:
        octave 2
        note E_, 4
        octave 3
        note B_, 4
        note E_, 4
        octave 2
        note B_, 4
        sound_ret

Music_SnapOaksLab_Ch2_Pat4:
        octave 2
        note A_, 4
        octave 3
        note E_, 4
        note A_, 4
        octave 2
        note E_, 4
        sound_ret

Music_SnapOaksLab_Ch3:
        stereo_panning TRUE, TRUE
        note_type 12, 2, 6
        octave 2
        note D_, 2
        rest 2
        note A_, 2
        rest 2
Music_SnapOaksLab_Ch3_Loop:
        sound_call Music_SnapOaksLab_Ch3_Pat1
        sound_call Music_SnapOaksLab_Ch3_Pat2
        sound_call Music_SnapOaksLab_Ch3_Pat3
        sound_call Music_SnapOaksLab_Ch3_Pat4
        sound_jump Music_SnapOaksLab_Ch3_Loop

Music_SnapOaksLab_Ch3_Pat1:
        octave 2
        note D_, 2
        rest 2
        note A_, 2
        rest 2
        note D_, 2
        rest 2
        note F#, 2
        rest 2
        sound_ret

Music_SnapOaksLab_Ch3_Pat2:
        octave 2
        note B_, 2
        rest 2
        note F#, 2
        rest 2
        note B_, 2
        rest 2
        note D_, 2
        rest 2
        sound_ret

Music_SnapOaksLab_Ch3_Pat3:
        octave 2
        note E_, 2
        rest 2
        note B_, 2
        rest 2
        note E_, 2
        rest 2
        note G_, 2
        rest 2
        sound_ret

Music_SnapOaksLab_Ch3_Pat4:
        octave 2
        note A_, 2
        rest 2
        note E_, 2
        rest 2
        note A_, 2
        rest 2
        note C#, 2
        rest 2
        sound_ret

Music_SnapOaksLab_Ch4:
        toggle_noise 2
        drum_speed 12
        rest 4
Music_SnapOaksLab_Ch4_Loop:
        drum_note 3, 1
        rest 1
        drum_note 3, 1
        rest 1
        drum_note 4, 1
        rest 1
        drum_note 8, 2
        rest 2
        drum_note 3, 1
        rest 1
        drum_note 3, 1
        rest 1
        drum_note 4, 1
        rest 1
        drum_note 7, 2
        rest 2
        sound_jump Music_SnapOaksLab_Ch4_Loop
