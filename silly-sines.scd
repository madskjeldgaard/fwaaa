(
	s.waitForBoot{
		~receiverPort = 1952;
		thisProcess.openUDPPort(~receiverPort);
	}
)
(
	~num_circles = 10;

	~num_circles.do{|numCircle|
		var name = "sine%".format(numCircle).asSymbol;
		var path = {|cnum, xy| "/circle%/%".format(cnum, xy).asSymbol };

		// Make synth
		Ndef(name, {|amp=0.05, pan=0|
			var f = \freq.kr(444, 0.1);
			var p = \pan.kr(0, 0.01);
			var sig = SinOsc.ar(f, mul: amp);

			Pan2.ar(sig, p)
		}).set(\freq, exprand(80.0,1500.0)).play;

		// Create responder function
		OSCdef.new("circle%x".format(numCircle).asSymbol, {|msg|
			var val = msg[1];
			Ndef(name).set(\pan, val.linlin(0.0,1.0,-1.0,1.0))
		}, path.value(numCircle, "x"));

		OSCdef.new("circle%y".format(numCircle).asSymbol, {|msg|
			var val = msg[1];
			Ndef(name).set(\freq, val.linexp(0.0,1.0,80.0,15500.0))
		}, path.value(numCircle, "y"));
	};
)
