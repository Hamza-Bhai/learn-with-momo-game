#!/usr/bin/env bash
# Synthesizes the game's sound effects with ffmpeg (no third-party audio). Usage: tools/gen_sfx.sh
set -e
O=assets/audio/sfx
enc="-ac 1 -ar 22050 -c:a libvorbis -q:a 3"
ffmpeg -y -loglevel error -f lavfi -i "aevalsrc='0.7*sin(2*PI*(400+2500*t)*t)*exp(-30*t)':s=22050:d=0.15" $enc $O/pop.ogg
ffmpeg -y -loglevel error -f lavfi -i "aevalsrc='0.6*sin(2*PI*(320-200*t)*t)*exp(-12*t)':s=22050:d=0.25" $enc $O/boop.ogg
ffmpeg -y -loglevel error -f lavfi -i "anoisesrc=c=pink:a=0.5:d=0.45:r=22050" -af "bandpass=f=1200:w=800,afade=in:d=0.2,afade=out:st=0.2:d=0.25,volume=2" $enc $O/whoosh.ogg
ffmpeg -y -loglevel error -f lavfi -i "aevalsrc='0.8*(random(0)*2-1)*exp(-45*mod(t,0.22))':s=22050:d=0.9" -af "bandpass=f=1800:w=1500,volume=2" $enc $O/clap.ogg
ffmpeg -y -loglevel error -f lavfi -i "aevalsrc='0.5*sin(2*PI*if(lt(t,0.09),523,if(lt(t,0.18),659,if(lt(t,0.27),784,1047)))*t)*exp(-6*mod(t,0.09))':s=22050:d=0.6" $enc $O/confetti.ogg
ls -la $O
