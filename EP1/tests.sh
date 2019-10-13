#!/bin/sh
echo 'Running tests...\n'
TESTSDIR=tests
CONT=1
for TEST in $( ls $TESTSDIR ); do
    echo '#'$CONT $TEST
    cat $TESTSDIR/$TEST
    echo 'translated grammar:'
    ./mcalc < $TESTSDIR/$TEST
    echo 'result from interpreter:'
    ./mcalc < $TESTSDIR/$TEST | ./direto
    echo '\n'
    CONT=$((CONT + 1))
done

