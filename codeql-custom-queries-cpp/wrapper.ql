/**
 * @name abc123
 * @description Buffer write operations that do not control the length
 *              of data written may overflow
 * @kind problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id cpp/very-likely-overrunning-write
 * @tags reliability
 *       security
 *       external/cwe/cwe-120
 *       external/cwe/cwe-787
 *       external/cwe/cwe-805
 */

 import semmle.code.cpp.security.BufferWrite
 import semmle.code.cpp.dataflow.DataFlow
 import semmle.code.cpp.controlflow.ControlFlow
 

// Define a custom predicate to get the allocation size through wrapper functions
predicate getAllocationSizeThroughWrapper(Expr dest, int size) {
  exists(FunctionCall fc |
    fc.getTarget().hasName("OSacquire") and // Replace with your wrapper function name
    fc.getArgument(0) = dest and
    size = 15 // Replace with the logic to determine the size
  )
}

 /*
	* See CWE-120/UnboundedWrite.ql for a summary of CWE-120 alert cases.
	*/
 
 from BufferWrite bw, Expr dest, int destSize, int estimated, ValueFlowAnalysis reason
 where
	 not bw.hasExplicitLimit() and // has no explicit size limit
	 dest = bw.getDest() and
	 (destSize = getBufferSize(dest, _) or getAllocationSizeThroughWrapper(dest, destSize)) and
	 estimated = bw.getMaxDataLimited(reason) and
	 // we can deduce from non-trivial range analysis that too much data may be copied
	 estimated > destSize
 select bw,
	 "This '" + bw.getBWDesc() + "' operation requires " + estimated +
		 " bytes but the destination is only " + destSize + " bytes."