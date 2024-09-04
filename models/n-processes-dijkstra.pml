#define PROC_NUM 4

//  ====  LTL  ====  //

int critical = 0;
bool inCS[PROC_NUM];

#define MUTEX (critical <= 1)
#define NO_STARVATION(i) (inCS[i] == true)

ltl mutex { [] MUTEX };
ltl no_starvation { ([]<> NO_STARVATION(0)) && ([]<> NO_STARVATION(1)) && ([]<> NO_STARVATION(2)) && ([]<> NO_STARVATION(3)) };

//  ====  Algorithm  ====  //

bool b[PROC_NUM];
bool c[PROC_NUM];
int k = 0;

inline acquire(i)
{
    b[i] = true;

L0: do
    :: (k == i) -> break;
    :: else ->
       c[i] = true;
       if
       :: (b[k]) -> k = i;
       :: else -> skip;
       fi;
    od;

    c[i] = false;
    int j = 0;
    do
    :: (j >= PROC_NUM) -> break;
    :: (j < PROC_NUM && i != j && !c[j]) -> goto L0;
    :: else -> j++;
    od;
}

inline release(i)
{
    c[i] = true;
    b[i] = true;
}

//  ====  Processes  ====  //

proctype P(int i)
{
do
:: acquire(i);
   critical++;
   inCS[i] = true;
   printf("Process #%d enter CS.\n", i);
   printf("Process #%d leave CS.\n", i);
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
           b[i] = true;
           c[i] = true;
           inCS[i] = false;
           run P(i);
           i++;
        od;
    }
}

