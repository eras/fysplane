// SuperCollder motor sound

{ SinOsc.ar(110, 0, 0.2) }.play;
{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;

{ FSinOsc.ar(FSinOsc.ar(10, 0.0, 400, 450)) * 0.1 }.play;

(
motor = { arg freq = 100;
	{ SinOsc.ar(SinOsc.kr(20, 0.0, 20, freq), 0.0, 0.1) +
		SinOsc.ar(SinOsc.kr(20, 0.0, 20, freq * 2), 0.0, 0.1) }
};
)

(
g = { arg freq = 100;
	{ SinOsc.ar(SinOsc.kr(20, 0.0, 20, freq), 0.0, 0.1) +
		SinOsc.ar(SinOsc.kr(20, 0.0, 20, freq * 2), 0.0, 0.1)} };

g.value({ XLine.kr(100, 130, 10) }).play
)

(
f = { arg a, b;
    a - b;
};
f.value(5, 3);
)

SynthDef("motor", { arg freq = 100;
	Out.ar(0,
		SinOsc.ar(SinOsc.kr(20, 0.0, 20, freq), 0.0, 0.1) +
		SinOsc.ar(SinOsc.kr(20, 0.0, 20, freq * 2), 0.0, 0.1) +
        0
	)
	}).add;

Synth.new("motor", ["freq", 100]);
Synth.new("motor", ["freq", XLine.kr(100, 200, 10)]);

(
s.recSampleFormat = "int16";
    s.recChannels = 1;
    s.recHeaderFormat = "WAV";

    s.waitForBoot({
       s.prepareForRecord("myoutput.wav");
      Synth.new("motor", ["freq", 100]);
      s.record;
      wait(5);
      s.stopRecording;
    });
)


SynthDef("tutorial-Rand", { Out.ar(0, SinOsc.ar(Rand(440, 660), 0, 0.2)) }).add;

Synth("tutorial-Rand");

(
plot { [
    SyncSaw.ar(800, 1200),
    Impulse.ar(800) // to show sync rate
] }
)

{ Pulse.ar(30, 0.5, 0.05) }.play;;

{ SyncSaw.ar(30, 40, 0.1) }.play;
//////

// The makeEffect function below wraps a simpler function within itself and provides
// a crossfade into the effect (so you can add it without clicks), control over wet
// and dry mix, etc.
// Such functionality is useful for a variety of effects, and SynthDef-wrap
// lets you reuse the common code.
(
// the basic wrapper
~makeEffect = {| name, func, lags, numChannels = 2 |

    SynthDef(name, {| i_bus = 0, gate = 1, wet = 1|
        var in, out, env, lfo;
        in = In.ar(i_bus, numChannels);
        env = Linen.kr(gate, 2, 1, 2, 2); // fade in the effect

        // call the wrapped function. The in and env arguments are passed to the function
        // as the first two arguments (prependArgs).
        // Any other arguments of the wrapped function will be Controls.
        out = SynthDef.wrap(func, lags, [in, env]);

        XOut.ar(i_bus, wet * env, out);
    }, [0, 0, 0.1] ).add;

};
)

// now make a wah
(
~makeEffect.value(\wah, {|in, env, rate = 0.7, ffreq = 1200, depth = 0.8, rq = 0.1|
    // in and env come from the wrapper. The rest are controls
     var lfo;
    lfo = LFNoise1.kr(rate, depth * ffreq, ffreq);
    RLPF.ar(in, lfo, rq, 10).distort * 0.15; },
    [0.1, 0.1, 0.1, 0.1],  // lags for rate ffreq, depth and rq
    2    // numChannels
);
)

// now make a simple reverb
(
~makeEffect.value(\reverb, {|in, env|
    // in and env come from the wrapper.
    var input;
    input = in;
    16.do({ input = AllpassC.ar(input, 0.04, Rand(0.001,0.04), 3)});
    input; },
    nil,  // no lags
    2    // numChannels
);
)

// something to process
x = { {Decay2.ar(Dust2.ar(3), mul: PinkNoise.ar(0.2))} ! 2}.play;

y = Synth.tail(s, \wah);
z = Synth.tail(s, \reverb, [\wet, 0.5]);

// we used an arg named gate, so Node-release can crossfade out the effects
y.release;

// setting gate to zero has the same result
z.set(\gate, 0);

x.free;