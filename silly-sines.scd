(
	s.waitForBoot{
		~receiverPort = 1952;
		thisProcess.openUDPPort(~receiverPort);
	}
)
(
	~numSines = 10;

	~numSines.do{|sinenum|
		var name = "sine%".format(sinenum).asSymbol;
		var xpath, ypath;

		// Make synth
		Ndef(name, {|amp=0.05, pan=0|
			var f = \freq.kr(444, 0.1);
			var p = \pan.kr(0, 0.01);
			var sig = SinOsc.ar(f, mul: amp);

			Pan2.ar(sig, p)
		}).set(\freq, exprand(80.0,1500.0)).play;

		// Create responder function
		xpath = "/circle%/x".format(sinenum).asSymbol;
		OSCdef.new("circle%x".format(sinenum).asSymbol, {|msg|
			var val = msg[1];
			Ndef(name).set(\pan, val.linlin(0.0,1.0,-1.0,1.0))
		}, xpath);

		ypath = "/circle%/y".format(sinenum).asSymbol;
		OSCdef.new("circle%y".format(sinenum).asSymbol, {|msg|
			var val = msg[1];
			Ndef(name).set(\freq, val.linexp(0.0,1.0,80.0,15500.0))
		}, ypath);
	};
)
