#define PROC_NUM 4

//  ====  LTL  ====  //

int critical = 0;
bool inCS[PROC_NUM];

#define MUTEX (critical <= 1)
#define NO_STARVATION(i) (inCS[i] == true)

ltl mutex { [] MUTEX };
ltl no_starvation { ([]<> NO_STARVATION(0)) && ([]<> NO_STARVATION(1)) && ([]<> NO_STARVATION(2)) && ([]<> NO_STARVATION(3)) };

//  ====  Algorithm  ====  //

int level[PROC_NUM];
int turn[PROC_NUM];

inline acquire(i)
{
    int l = 1;
    do
    :: (l >= PROC_NUM) -> break;
    :: else ->
       level[i] = l;
       turn[l] = i;

       do
       :: (turn[l] != i) -> break;
       :: else ->
          int k = 0;
          do
          :: (k >= PROC_NUM) -> goto NL;
          :: (k < PROC_NUM && k != i && level[k] >= l) -> break;
          :: else -> k++;
          od;
       od;

NL:  l++;
    od;
}

inline release(i)
{
    level[i] = 0;
}

//  ====  Processes  ====  //

proctype P(int i)
{
    do
    :: acquire(i);
       critical++;
       inCS[i] = true;
       printf("Process %d enter CS.\n", i);
       printf("Process %d leave CS.\n", i);
       inCS[i] = false;
       critical--;
       release(i);
    od;
}

init
{
    atomic
    {
        int i = 0;
        do
        :: (i >= PROC_NUM) -> break;
        :: else ->
           level[i] = 0;
           turn[i] = 0;
           inCS[i] = false;
           run P(i);
           i++;
        od;
    }
}

