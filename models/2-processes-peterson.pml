bool flag[2];
int afterYou;
bool pK = false;
bool qK = false;

#define ttt pK == false && qK == true
ltl test { always !ttt }

inline acquire(i)
{
	flag[i] = true;
	afterYou = i;

	do
	:: (flag[1 - i] == true && afterYou == i) -> skip;
	:: else -> break;
	od
}

inline release(i)
{
	flag[i] = false;
}

active proctype P()
{
do
::	acquire(0);
	pK = true;
	pK = false;
	release(0);
od
}

active proctype Q()
{
do
::	acquire(1);
	qK = true;
	qK = false;
	release(1);
od
}

init
{
atomic
{
	flag[0] = false;
	flag[1] = false;
}
}
