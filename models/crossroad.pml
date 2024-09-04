// LTL

ltl safetySD { [] !((SD_LIGHT == GREEN) && (WE_LIGHT == GREEN || DE_LIGHT == GREEN || WN_LIGHT == GREEN || DN_LIGHT == GREEN || NS_LIGHT == GREEN)) };
ltl safetyWN { [] !((WN_LIGHT == GREEN) && (DE_LIGHT == GREEN || SD_LIGHT == GREEN || NS_LIGHT == GREEN)) };
ltl safetyDN { [] !((DN_LIGHT == GREEN) && (SD_LIGHT == GREEN || NS_LIGHT == GREEN)) };
ltl safetyDE { [] !((DE_LIGHT == GREEN) && (SD_LIGHT == GREEN || WN_LIGHT == GREEN || NS_LIGHT == GREEN)) };
ltl safetyNS { [] !((NS_LIGHT == GREEN) && (WE_LIGHT == GREEN || DE_LIGHT == GREEN || WN_LIGHT == GREEN || DN_LIGHT == GREEN || SD_LIGHT == GREEN)) };
ltl safetyWE { [] !((WE_LIGHT == GREEN) && (SD_LIGHT == GREEN || NS_LIGHT == GREEN)) };

ltl livenessSD { [] ((SD_SENSE && SD_LIGHT == RED) -> <> (SD_LIGHT == GREEN)) };
ltl livenessWN { [] ((WN_SENSE && WN_LIGHT == RED) -> <> (WN_LIGHT == GREEN)) };
ltl livenessDN { [] ((DN_SENSE && DN_LIGHT == RED) -> <> (DN_LIGHT == GREEN)) };
ltl livenessDE { [] ((DE_SENSE && DE_LIGHT == RED) -> <> (DE_LIGHT == GREEN)) };
ltl livenessNS { [] ((NS_SENSE && NS_LIGHT == RED) -> <> (NS_LIGHT == GREEN)) };
ltl livenessWE { [] ((WE_SENSE && WE_LIGHT == RED) -> <> (WE_LIGHT == GREEN)) };

ltl fairnessSD { [] <> !(SD_LIGHT == GREEN && SD_SENSE) };
ltl fairnessWN { [] <> !(WN_LIGHT == GREEN && WN_SENSE) };
ltl fairnessDN { [] <> !(DN_LIGHT == GREEN && DN_SENSE) };
ltl fairnessDE { [] <> !(DE_LIGHT == GREEN && DE_SENSE) };
ltl fairnessNS { [] <> !(NS_LIGHT == GREEN && NS_SENSE) };
ltl fairnessWE { [] <> !(WE_LIGHT == GREEN && WE_SENSE) };

// Traffic lights for direaction: SD, WN, DN, DE, NS, WE
mtype:light = {RED, GREEN};
mtype:light SD_LIGHT = RED;
mtype:light WN_LIGHT = RED;
mtype:light DN_LIGHT = RED;
mtype:light DE_LIGHT = RED;
mtype:light NS_LIGHT = RED;
mtype:light WE_LIGHT = RED;

// Presence of cars in a given direction: SD, WN, DN, DE, NS, WE
bool SD_SENSE = false;
bool WN_SENSE = false;
bool DN_SENSE = false;
bool DE_SENSE = false;
bool NS_SENSE = false;
bool WE_SENSE = false;

// Locks for direction: SD, WN, DN, DE, NS, WE
bool SD_LOCK = false;
bool WN_LOCK = false;
bool DN_LOCK = false;
bool DE_LOCK = false;
bool NS_LOCK = false;
bool WE_LOCK = false;

// Direction controllers: SD, WN, DN, DE, NS, WE
proctype ControllerSD() {
	do
	:: (SD_SENSE && SD_LIGHT == RED) -> {
	  atomic { (!WE_LOCK && !DE_LOCK && !WN_LOCK && !DN_LOCK && !NS_LOCK); SD_LOCK = true; };
	  SD_LIGHT = GREEN;
	};
	:: (!SD_SENSE && SD_LIGHT == GREEN) -> {
		SD_LIGHT = RED;
		SD_LOCK = false;
	};
	od;
}

proctype ControllerWN() {
	do
	:: (WN_SENSE && WN_LIGHT == RED) -> {
	  atomic { (!NS_LOCK && !DE_LOCK && !SD_LOCK); WN_LOCK = true; };
		WN_LIGHT = GREEN;
	};
	:: (!WN_SENSE && WN_LIGHT == GREEN) -> {
		WN_LIGHT = RED;
		WN_LOCK = false;
	};
	od;
}

proctype ControllerDN() {
	do
	:: (DN_SENSE && DN_LIGHT == RED) -> {
	  atomic { (!NS_LOCK && !SD_LOCK); DN_LOCK = true; };
		DN_LIGHT = GREEN;
	};
	:: (!DN_SENSE && DN_LIGHT == GREEN) -> {
		DN_LIGHT = RED;
		DN_LOCK = false;
	};
	od;
}

proctype ControllerDE() {
	do
	:: (DE_SENSE && DE_LIGHT == RED) -> {
	  atomic { (!NS_LOCK && !WN_LOCK && !SD_LOCK); DE_LOCK = true; };
	  DE_LIGHT = GREEN;
	};
	:: (!DE_SENSE && DE_LIGHT == GREEN) -> {
		DE_LIGHT = RED;
		DE_LOCK = false;
	};
	od;
}

proctype ControllerNS() {
	do
	:: (NS_SENSE && NS_LIGHT == RED) -> {
	  atomic { (!SD_LOCK && !DN_LOCK && !DE_LOCK && !WN_LOCK && !WE_LOCK); NS_LOCK = true; };
		NS_LIGHT = GREEN;
	};
	:: (!NS_SENSE && NS_LIGHT == GREEN) -> {
		NS_LIGHT = RED;
		NS_LOCK = false;
	};
	od;
}

proctype ControllerWE() {
	do
	:: (WE_SENSE && WE_LIGHT == RED) -> {
	  atomic { (!SD_LOCK && !NS_LOCK); WE_LOCK = true; };
	  WE_LIGHT = GREEN;
	};
	:: (!WE_SENSE && WE_LIGHT == GREEN) -> {
		WE_LIGHT = RED;
		WE_LOCK = false;
	};
	od;
}

// External environment controller
proctype EnvironmentController() {
	do
	:: (!SD_SENSE && SD_LIGHT == RED) -> SD_SENSE = true;
	:: (!WN_SENSE && WN_LIGHT == RED) -> WN_SENSE = true;
	:: (!DN_SENSE && DN_LIGHT == RED) -> DN_SENSE = true;
	:: (!DE_SENSE && DE_LIGHT == RED) -> DE_SENSE = true;
	:: (!NS_SENSE && NS_LIGHT == RED) -> NS_SENSE = true;
	:: (!WE_SENSE && WE_LIGHT == RED) -> WE_SENSE = true;

	:: (SD_SENSE && SD_LIGHT == GREEN) -> SD_SENSE = false;
	:: (WN_SENSE && WN_LIGHT == GREEN) -> WN_SENSE = false;
	:: (DN_SENSE && DN_LIGHT == GREEN) -> DN_SENSE = false;
	:: (DE_SENSE && DE_LIGHT == GREEN) -> DE_SENSE = false;
	:: (NS_SENSE && NS_LIGHT == GREEN) -> NS_SENSE = false;
	:: (WE_SENSE && WE_LIGHT == GREEN) -> WE_SENSE = false;
	od;
}

init {
	atomic {
		run EnvironmentController();
		run ControllerSD();
		run ControllerWN(); 
		run ControllerDN();
		run ControllerDE();
		run ControllerNS();
		run ControllerWE();
	}
}
