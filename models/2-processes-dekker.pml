//  ====  LTL  ====  //

int critical = 0;
bool inCS[2] = {false, false};

#define MUTEX (critical <= 1)
#define NO_STARVATION(i) (inCS[i] == true)

ltl mutex { [] MUTEX };
ltl no_starvation { []<> NO_STARVATION(0) };

//  ====  Algorithm  ====  //

int turn = 0;
bool want[2] = {false, false};

inline acquire(i)
{
    want[i] = true;

    do
    :: (want[1 - i] == false) -> break;
    :: (want[1 - i] == true && turn == i) -> skip;
    :: else ->
       want[i] = false;
       (turn == i);
       want[i] = true;
    od;
}

inline release(i)
{
    turn = 1 - i;
    want[i] = false;
}

//  ====  Processes  ====  //

active [2] proctype P()
{
do
:: acquire(_pid);
   critical++;
   inCS[_pid] = true;
   printf("Process #%d enter CS.\n", _pid);
   printf("Process #%d leave CS.\n", _pid);
   inCS[_pid] = false;
   critical--;
   release(_pid);
od;
}

