#!/bin/sh
#___INFO__MARK_BEGIN__
##########################################################################
#
#  The Contents of this file are made available subject to the terms of
#  the Sun Industry Standards Source License Version 1.2
#
#  Sun Microsystems Inc., March, 2001
#
#
#  Sun Industry Standards Source License Version 1.2
#  =================================================
#  The contents of this file are subject to the Sun Industry Standards
#  Source License Version 1.2 (the "License"); You may not use this file
#  except in compliance with the License. You may obtain a copy of the
#  License at http://www.gridengine.sunsource.net/license.html
#
#  Software provided under this License is provided on an "AS IS" basis,
#  WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
#  WITHOUT LIMITATION, WARRANTIES THAT THE SOFTWARE IS FREE OF DEFECTS,
#  MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE, OR NON-INFRINGING.
#  See the License for the specific provisions governing your rights and
#  obligations concerning the Software.
#
#  The Initial Developer of the Original Code is: Sun Microsystems, Inc.
#
#  Copyright: 2001 by Sun Microsystems, Inc.
#
#  All Rights Reserved.
#
##########################################################################
#___INFO__MARK_END__
#
# shutdown of MPI conforming with the CODINE/GRD
# Parallel Environment interface
#

#-----------------------------------
# KillTree
KillTree()
{
#
# Kill all the remaining processes 
# related to a given CRE Job ID
# using the output generated by "terminate_method"
#
cat $1 | while read cmd; do
    host=`echo $cmd | nawk '{print $3}'`
    plist="`$cmd | grep -v spmd | nawk '{print $1}'`"
    exec rsh -n $host kill -9 $plist
done
}
#
# Accounting output:
# Call parser to get accounting info for MPI apps
#
DEBUG=0
$SGE_ROOT/mpi/sunhpc/loose-integration/accounting/ctacct2.pl $JOB_ID $USER $TMPDIR $SGE_JOB_SPOOL_DIR $DEBUG
if [ $DEBUG -eq 1 ]; then
  cat /tmp/debugout | mail $USER
  cat /tmp/acctsummary | mail $USER
else
  cat $TMPDIR/acctsummary | mail $USER
fi
#

#
# Just remove machine-file that was written by startmpi.sh
#
rm $TMPDIR/machines

#
# Clean-up any remaining, if any, MPI processes
#
if [ -s $TMPDIR/ptree.list ]; then
   myptree=$TMPDIR/ptree.list
   KillTree $myptree
#
#  Delete all temporary files
#
   /bin/rm  $myptree
fi

rshcmd=rsh
case "$ARC" in
   hp|hp10|hp11) rshcmd=remsh ;;
   *) ;;
esac
if [ -s $TMPDIR/$rshcmd ]; then
   rm $TMPDIR/$rshcmd
fi

exit 0
