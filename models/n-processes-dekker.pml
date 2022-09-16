#define PROC_NUM 4

//  ====  LTL  ====  //

bool inMutex[PROC_NUM];
bool inCS[PROC_NUM];
int critical = 0;

#define MUTEX (critical <= 1)
#define NO_STARVATION(i) (inCS[i] == true)
#define PROGRESSIVE(i) ((inMutex[0] == true) -> <>(inMutex[0] == false))

ltl mutex { [] MUTEX };
ltl no_starvation { []<> NO_STARVATION(0) };
ltl progressive { [] PROGRESSIVE(0) };

//  ====  Algorithm  ====  //

bool want[PROC_NUM];
int turn = 0;

inline acquire()
{
    want[_pid] = true;

    do
    :: int k = 0;
       bool someone_want = false;
       do
       :: (k >= PROC_NUM) -> break;
       :: (k < PROC_NUM && _pid != k && want[k] == true) -> someone_want = true; break;
       :: else -> k++;
       od;
       if
       :: (someone_want == true && turn != _pid) ->
          want[_pid] = false;
          (turn == _pid);
          want[_pid] = true;
       :: (someone_want == true && turn == _pid) -> skip;
       :: else -> break;
       fi;
    od;
}

inline release()
{
    turn = (turn + 1) % PROC_NUM;
    want[_pid] = false;
}

//  ====  Processes  ====  //

active [PROC_NUM] proctype P()
{
    inMutex[_pid] = false;
    inCS[_pid] = false;
    want[_pid] = false;
58
    do
    :: inMutex[_pid] = true;
       acquire();
       critical++;
       inCS[_pid] = true;
       printf("Process %d enter CS.\n", _pid);
       printf("Process %d leave CS.\n", _pid);
       inCS[_pid] = false;
       critical--;
       release();
       inMutex[_pid] = false;
    od
}

