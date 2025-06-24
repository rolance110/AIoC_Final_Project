// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

void  hsG_0__0 (struct dummyq_struct * I1323, EBLK  * I1318, U  I695);
void  hsG_0__0 (struct dummyq_struct * I1323, EBLK  * I1318, U  I695)
{
    U  I1585;
    U  I1586;
    U  I1587;
    struct futq * I1588;
    struct dummyq_struct * pQ = I1323;
    I1585 = ((U )vcs_clocks) + I695;
    I1587 = I1585 & ((1 << fHashTableSize) - 1);
    I1318->I740 = (EBLK  *)(-1);
    I1318->I741 = I1585;
    if (0 && rmaProfEvtProp) {
        vcs_simpSetEBlkEvtID(I1318);
    }
    if (I1585 < (U )vcs_clocks) {
        I1586 = ((U  *)&vcs_clocks)[1];
        sched_millenium(pQ, I1318, I1586 + 1, I1585);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I695 == 1)) {
        I1318->I743 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I740 = I1318;
        peblkFutQ1Tail = I1318;
    }
    else if ((I1588 = pQ->I1226[I1587].I763)) {
        I1318->I743 = (struct eblk *)I1588->I761;
        I1588->I761->I740 = (RP )I1318;
        I1588->I761 = (RmaEblk  *)I1318;
    }
    else {
        sched_hsopt(pQ, I1318, I1585);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
