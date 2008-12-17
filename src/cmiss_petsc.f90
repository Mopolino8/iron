!> \file
!> $Id$
!> \author Chris Bradley
!> \brief This module is a CMISS buffer module to the PETSc library.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is openCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand and University of Oxford, Oxford, United
!> Kingdom. Portions created by the University of Auckland and University
!> of Oxford are Copyright (C) 2007 by the University of Auckland and
!> the University of Oxford. All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!> This module is a CMISS buffer module to the PETSc library.
MODULE CMISS_PETSC
  
  USE BASE_ROUTINES
  USE CMISS_PETSC_TYPES
  USE KINDS
  USE ISO_VARYING_STRING
  USE TYPES
  
  IMPLICIT NONE
 
  PRIVATE

#include "include/finclude/petsc.h"
#include "include/finclude/petscis.h"
#include "include/finclude/petscksp.h"
#include "include/finclude/petscmat.h"
#include "include/finclude/petscpc.h"
#include "include/finclude/petscsnes.h"
#include "include/finclude/petscvec.h"
#include "include/finclude/petscviewer.h"

  !Module parameters

  !Insert mode types
  InsertMode, PARAMETER :: PETSC_INSERT_VALUES = INSERT_VALUES
  InsertMode, PARAMETER :: PETSC_ADD_VALUES = ADD_VALUES

  !Scatter mode types
  ScatterMode, PARAMETER :: PETSC_SCATTER_FORWARD = SCATTER_FORWARD
  ScatterMode, PARAMETER :: PETSC_SCATTER_REVERSE = SCATTER_REVERSE
  
  !KSPConvergedReason types
  KSPConvergedReason, PARAMETER :: PETSC_KSP_CONVERGED_RTOL = KSP_CONVERGED_RTOL
  KSPConvergedReason, PARAMETER :: PETSC_KSP_CONVERGED_ATOL = KSP_CONVERGED_ATOL
  KSPConvergedReason, PARAMETER :: PETSC_KSP_CONVERGED_ITS = KSP_CONVERGED_ITS
  KSPConvergedReason, PARAMETER :: PETSC_KSP_CONVERGED_CG_NEG_CURVE = KSP_CONVERGED_CG_NEG_CURVE
  KSPConvergedReason, PARAMETER :: PETSC_KSP_CONVERGED_CG_CONSTRAINED = KSP_CONVERGED_CG_CONSTRAINED
  KSPConvergedReason, PARAMETER :: PETSC_KSP_CONVERGED_STEP_LENGTH = KSP_CONVERGED_STEP_LENGTH
  KSPConvergedReason, PARAMETER :: PETSC_KSP_CONVERGED_HAPPY_BREAKDOWN = KSP_CONVERGED_HAPPY_BREAKDOWN
  KSPConvergedReason, PARAMETER :: PETSC_KSP_DIVERGED_NULL = KSP_DIVERGED_NULL
  KSPConvergedReason, PARAMETER :: PETSC_KSP_DIVERGED_ITS = KSP_DIVERGED_ITS
  KSPConvergedReason, PARAMETER :: PETSC_KSP_DIVERGED_DTOL = KSP_DIVERGED_DTOL
  KSPConvergedReason, PARAMETER :: PETSC_KSP_DIVERGED_BREAKDOWN = KSP_DIVERGED_BREAKDOWN
  KSPConvergedReason, PARAMETER :: PETSC_KSP_DIVERGED_BREAKDOWN_BICG = KSP_DIVERGED_BREAKDOWN_BICG
  KSPConvergedReason, PARAMETER :: PETSC_KSP_DIVERGED_NONSYMMETRIC = KSP_DIVERGED_NONSYMMETRIC
  KSPConvergedReason, PARAMETER :: PETSC_KSP_DIVERGED_INDEFINITE_PC = KSP_DIVERGED_INDEFINITE_PC
  KSPConvergedReason, PARAMETER :: PETSC_KSP_DIVERGED_NAN = KSP_DIVERGED_NAN
  KSPConvergedReason, PARAMETER :: PETSC_KSP_DIVERGED_INDEFINITE_MAT = KSP_DIVERGED_INDEFINITE_MAT
  KSPConvergedReason, PARAMETER :: PETSC_KSP_CONVERGED_ITERATING = KSP_CONVERGED_ITERATING  
  
  !KSP types
  KSPType, PARAMETER :: PETSC_KSPRICHARDSON = KSPRICHARDSON
  KSPType, PARAMETER :: PETSC_KSPCHEBYCHEV = KSPCHEBYCHEV
  KSPType, PARAMETER :: PETSC_KSPCG = KSPCG
  KSPType, PARAMETER :: PETSC_KSPCGNE = KSPCGNE
  KSPType, PARAMETER :: PETSC_KSPSTCG = KSPSTCG
  KSPType, PARAMETER :: PETSC_KSPGMRES = KSPGMRES
  KSPType, PARAMETER :: PETSC_KSPFGMRES = KSPFGMRES
  KSPType, PARAMETER :: PETSC_KSPLGMRES = KSPLGMRES
  KSPType, PARAMETER :: PETSC_KSPTCQMR = KSPTCQMR
  KSPType, PARAMETER :: PETSC_KSPBCGS = KSPBCGS
  KSPType, PARAMETER :: PETSC_KSPBCGSL = KSPBCGSL
  KSPType, PARAMETER :: PETSC_KSPCGS = KSPCGS
  KSPType, PARAMETER :: PETSC_KSPTFQMR = KSPTFQMR
  KSPType, PARAMETER :: PETSC_KSPCR = KSPCR
  KSPType, PARAMETER :: PETSC_KSPLSQR = KSPLSQR
  KSPType, PARAMETER :: PETSC_KSPPREONLY = KSPPREONLY
  KSPType, PARAMETER :: PETSC_KSPQCG = KSPQCG
  KSPType, PARAMETER :: PETSC_KSPBICG = KSPBICG
  KSPType, PARAMETER :: PETSC_KSPMINRES = KSPMINRES
  KSPType, PARAMETER :: PETSC_KSPSYMMLQ = KSPSYMMLQ
  KSPType, PARAMETER :: PETSC_KSPLCD = KSPLCD

  !MatStructure types
  MatStructure, PARAMETER :: PETSC_SAME_PRECONDITIONER = SAME_PRECONDITIONER
  MatStructure, PARAMETER :: PETSC_SAME_NONZERO_PATTERN = SAME_NONZERO_PATTERN
  MatStructure, PARAMETER :: PETSC_DIFFERENT_NONZERO_PATTERN = DIFFERENT_NONZERO_PATTERN

  !MatColoring types
  MatColoringType, PARAMETER :: PETSC_MATCOLORING_NATURAL = MATCOLORING_NATURAL
  MatColoringType, PARAMETER :: PETSC_MATCOLORING_SL = MATCOLORING_SL
  MatColoringType, PARAMETER :: PETSC_MATCOLORING_LF = MATCOLORING_LF
  MatColoringType, PARAMETER :: PETSC_MATCOLORING_ID = MATCOLORING_ID
  
  !PC types
  PCType, PARAMETER ::  PETSC_PCNONE = PCNONE
  PCType, PARAMETER ::  PETSC_PCJACOBI = PCJACOBI
  PCType, PARAMETER ::  PETSC_PCSOR = PCSOR
  PCType, PARAMETER ::  PETSC_PCLU = PCLU
  PCType, PARAMETER ::  PETSC_PCSHELL = PCSHELL
  PCType, PARAMETER ::  PETSC_PCBJACOBI = PCBJACOBI
  PCType, PARAMETER ::  PETSC_PCMG = PCMG
  PCType, PARAMETER ::  PETSC_PCEISENSTAT = PCEISENSTAT
  PCType, PARAMETER ::  PETSC_PCILU = PCILU
  PCType, PARAMETER ::  PETSC_PCICC = PCICC
  PCType, PARAMETER ::  PETSC_PCASM = PCASM
  PCType, PARAMETER ::  PETSC_PCKSP = PCKSP
  PCType, PARAMETER ::  PETSC_PCCOMPOSITE = PCCOMPOSITE
  PCType, PARAMETER ::  PETSC_PCREDUNDANT = PCREDUNDANT
  PCType, PARAMETER ::  PETSC_PCSPAI = PCSPAI
  PCType, PARAMETER ::  PETSC_PCMILU = PCMILU
  PCType, PARAMETER ::  PETSC_PCNN = PCNN
  PCType, PARAMETER ::  PETSC_PCCHOLESKY = PCCHOLESKY
  PCType, PARAMETER ::  PETSC_PCSAMG = PCSAMG
  PCType, PARAMETER ::  PETSC_PCPBJACOBI = PCPBJACOBI
  PCType, PARAMETER ::  PETSC_PCMAT = PCMAT
  PCType, PARAMETER ::  PETSC_PCHYPRE = PCHYPRE
  PCType, PARAMETER ::  PETSC_PCFIELDSPLIT = PCFIELDSPLIT
  PCType, PARAMETER ::  PETSC_PCML = PCML

  !SNES converged types
  SNESConvergedReason, PARAMETER :: PETSC_SNES_CONVERGED_FNORM_ABS = SNES_CONVERGED_FNORM_ABS
  SNESConvergedReason, PARAMETER :: PETSC_SNES_CONVERGED_FNORM_RELATIVE = SNES_CONVERGED_FNORM_RELATIVE
  SNESConvergedReason, PARAMETER :: PETSC_SNES_CONVERGED_PNORM_RELATIVE = SNES_CONVERGED_PNORM_RELATIVE
  SNESConvergedReason, PARAMETER :: PETSC_SNES_CONVERGED_ITS = SNES_CONVERGED_ITS
  SNESConvergedReason, PARAMETER :: PETSC_SNES_CONVERGED_TR_DELTA = SNES_CONVERGED_TR_DELTA
  SNESConvergedReason, PARAMETER :: PETSC_SNES_DIVERGED_FUNCTION_COUNT = SNES_DIVERGED_FUNCTION_COUNT
  SNESConvergedReason, PARAMETER :: PETSC_SNES_DIVERGED_LINEAR_SOLVE = SNES_DIVERGED_LINEAR_SOLVE
  SNESConvergedReason, PARAMETER :: PETSC_SNES_DIVERGED_FNORM_NAN = SNES_DIVERGED_FNORM_NAN
  SNESConvergedReason, PARAMETER :: PETSC_SNES_DIVERGED_MAX_IT = SNES_DIVERGED_MAX_IT
  SNESConvergedReason, PARAMETER :: PETSC_SNES_DIVERGED_LS_FAILURE = SNES_DIVERGED_LS_FAILURE
  SNESConvergedReason, PARAMETER :: PETSC_SNES_DIVERGED_LOCAL_MIN = SNES_DIVERGED_LOCAL_MIN
  SNESConvergedReason, PARAMETER :: PETSC_SNES_CONVERGED_ITERATING = SNES_CONVERGED_ITERATING

  !SNES types
  SNESType, PARAMETER :: PETSC_SNESLS = SNESLS
  SNESType, PARAMETER :: PETSC_SNESTR = SNESTR
  SNESType, PARAMETER :: PETSC_SNESTEST = SNESTEST

  !SNES line search types
  INTEGER(INTG), PARAMETER :: PETSC_SNES_LINESEARCH_NONORMS = 1
  INTEGER(INTG), PARAMETER :: PETSC_SNES_LINESEARCH_NO = 2
  INTEGER(INTG), PARAMETER :: PETSC_SNES_LINESEARCH_QUADRATIC = 3
  INTEGER(INTG), PARAMETER :: PETSC_SNES_LINESEARCH_CUBIC = 4  
  
  !Module types

  !Module variables

  LOGICAL, SAVE :: PETSC_HANDLE_ERROR

  !Interfaces

  INTERFACE

    SUBROUTINE ISDestroy(indexset,ierr)
      IS indexset
      PetscInt ierr
    END SUBROUTINE ISDestroy
    
    SUBROUTINE ISColoringDestroy(iscoloring,ierr)
      ISColoring iscoloring
      PetscInt ierr
    END SUBROUTINE ISColoringDestroy
    
    SUBROUTINE ISLocalToGlobalMappingApply(ctx,type,nin,idxin,nout,idxout,ierr)
      ISLocalToGlobalMapping ctx
      ISGlobalToLocalMappingType type
      PetscInt nin
      PetscInt idxin(*)
      PetscInt nout
      PetscInt idxout(*)
      PetscInt ierr
    END SUBROUTINE ISLocalToGlobalMappingApply
    
    SUBROUTINE ISLocalToGlobalMappingApplyIS(ctx,isin,isout,ierr)
      ISLocalToGlobalMapping ctx
      IS isin
      IS isout
      PetscInt ierr
    END SUBROUTINE ISLocalToGlobalMappingApplyIS
    
    SUBROUTINE ISLocalToGlobalMappingCreate(comm,N,globalnum,ctx,ierr)
      MPI_Comm comm
      PetscInt N
      PetscInt globalnum(*)
      ISLocalToGlobalMapping ctx
      PetscInt ierr
    END SUBROUTINE ISLocalToGlobalMappingCreate
    
    SUBROUTINE ISLocalToGlobalMappingDestroy(ctx,ierr)
      ISLocalToGlobalMapping ctx
      PetscInt ierr
    END SUBROUTINE ISLocalToGlobalMappingDestroy
    
    SUBROUTINE KSPCreate(comm,ksp,ierr)
      MPI_Comm comm
      KSP ksp
      PetscInt ierr
    END SUBROUTINE KSPCreate
    
    SUBROUTINE KSPDestroy(ksp,ierr)
      KSP ksp
      PetscInt ierr
    END SUBROUTINE KSPDestroy
    
    SUBROUTINE KSPGetConvergedReason(ksp,reason,ierr)
      KSP ksp
      KSPConvergedReason reason
      PetscInt ierr
    END SUBROUTINE KSPGetConvergedReason
    
    SUBROUTINE KSPGetIterationNumber(ksp,its,ierr)
      KSP ksp
      PetscInt its
      PetscInt ierr
    END SUBROUTINE KSPGetIterationNumber
    
    SUBROUTINE KSPGetPC(ksp,pc,ierr)
      KSP ksp
      PC pc
      PetscInt ierr
    END SUBROUTINE KSPGetPC
    
    SUBROUTINE KSPGetResidualNorm(ksp,rnorm,ierr)
      KSP ksp
      PetscReal rnorm
      PetscInt ierr
    END SUBROUTINE KSPGetResidualNorm
    
    SUBROUTINE KSPSetFromOptions(ksp,ierr)
      KSP ksp
      PetscInt ierr
    END SUBROUTINE KSPSetFromOptions
    
    SUBROUTINE KSPSetOperators(ksp,Amat,Pmat,flag,ierr)
      KSP ksp
      Mat Amat
      Mat Pmat
      MatStructure flag
      PetscInt ierr
    END SUBROUTINE KSPSetOperators
    
    SUBROUTINE KSPSetTolerances(ksp,rtol,atol,dtol,maxits,ierr)
      KSP ksp
      PetscReal rtol
      PetscReal atol
      PetscReal dtol
      PetscInt maxits
      PetscInt ierr
    END SUBROUTINE KSPSetTolerances
    
    SUBROUTINE KSPSetType(ksp,method,ierr)
      KSP ksp
      KSPType method
      PetscInt ierr
    END SUBROUTINE KSPSetType
    
    SUBROUTINE KSPSetUp(ksp,ierr)
      KSP ksp
      PetscInt ierr
    END SUBROUTINE KSPSetUp
    
    SUBROUTINE KSPSolve(ksp,b,x,ierr)
      KSP ksp
      Vec b
      Vec x
      PetscInt ierr
    END SUBROUTINE KSPSolve
    
    SUBROUTINE MatAssemblyBegin(A,assemblytype,ierr)
      Mat A
      MatAssemblyType assemblytype
      PetscInt ierr
    END SUBROUTINE MatAssemblyBegin
    
    SUBROUTINE MatAssemblyEnd(A,assemblytype,ierr)
      Mat A
      MatAssemblyType assemblytype
      PetscInt ierr
    END SUBROUTINE MatAssemblyEnd
    
    SUBROUTINE MatCreate(comm,A,ierr)
      MPI_Comm comm
      Mat A
      PetscInt ierr
    END SUBROUTINE MatCreate

    SUBROUTINE MatCreateMPIAIJ(comm,localm,localn,globalm,globaln,diagnumbernzperrow,diagnumbernzeachrow,offdiagnumbernzperrow, &
      & offdiagnumbernzeachrow,A,ierr)
      MPI_Comm comm
      PetscInt localm
      PetscInt localn
      PetscInt globalm
      PetscInt globaln
      PetscInt diagnumbernzperrow
      PetscInt diagnumbernzeachrow(*)
      PetscInt offdiagnumbernzperrow
      PetscInt offdiagnumbernzeachrow(*)
      Mat A
      PetscInt ierr
    END SUBROUTINE MatCreateMPIAIJ
        
    SUBROUTINE MatCreateMPIDense(comm,localm,localn,globalm,globaln,matrixdata,A,ierr)
      MPI_Comm comm
      PetscInt localm
      PetscInt localn
      PetscInt globalm
      PetscInt globaln
      PetscScalar matrixdata(*)
      Mat A
      PetscInt ierr
    END SUBROUTINE MatCreateMPIDense
        
    SUBROUTINE MatCreateSeqAIJ(comm,m,n,numbernzperrow,numbernzeachrow,A,ierr)
      MPI_Comm comm
      PetscInt m
      PetscInt n
      PetscInt numbernzperrow
      PetscInt numbernzeachrow(*)
      Mat A
      PetscInt ierr
    END SUBROUTINE MatCreateSeqAIJ
          
    SUBROUTINE MatCreateSeqDense(comm,m,n,matrixdata,A,ierr)
      MPI_Comm comm
      PetscInt m
      PetscInt n
      PetscScalar matrixdata(*)
      Mat A
      PetscInt ierr
    END SUBROUTINE MatCreateSeqDense

    SUBROUTINE MatDestroy(A,ierr)
      Mat A
      PetscInt ierr
    END SUBROUTINE MatDestroy
    
    SUBROUTINE MatFDColoringCreate(A,iscoloring,fdcoloring,ierr)
      Mat A
      ISColoring iscoloring
      MatFDColoring fdcoloring
      PetscInt ierr
    END SUBROUTINE MatFDColoringCreate
    
    SUBROUTINE MatFDColoringDestroy(fdcoloring,ierr)
      MatFDColoring fdcoloring
      PetscInt ierr
    END SUBROUTINE MatFDColoringDestroy
    
    SUBROUTINE MatFDColoringSetFromOptions(fdcoloring,ierr)
      MatFDColoring fdcoloring
      PetscInt ierr
    END SUBROUTINE MatFDColoringSetFromOptions
    
    SUBROUTINE MatGetArray(A,mat_data,mat_offset,ierr)
      Mat A
      PetscScalar mat_data(1)
      PetscOffset mat_offset
      PetscInt ierr
    END SUBROUTINE MatGetArray
    
    SUBROUTINE MatGetArrayF90(A,mat_data,ierr)
      Mat A
      PetscScalar, POINTER :: mat_data(:,:)
      PetscInt ierr
    END SUBROUTINE MatGetArrayF90
    
    SUBROUTINE MatGetColoring(A,coloring_type,iscoloring,ierr)
      Mat A
      MatColoringType coloring_type
      ISColoring iscoloring 
      PetscInt ierr
    END SUBROUTINE MatGetColoring
    
    SUBROUTINE MatGetOwnershipRange(A,firstrow,lastrow,ierr)
      Mat A
      PetscInt firstrow
      PetscInt lastrow
      PetscInt ierr
    END SUBROUTINE MatGetOwnershipRange
    
    SUBROUTINE MatGetValues(A,m,idxm,n,idxn,values,ierr)
      Mat A
      PetscInt m
      PetscInt idxm(*)
      PetscInt n
      PetscInt idxn(*)
      PetscScalar values(*)
      PetscInt ierr
    END SUBROUTINE MatGetValues
    
    SUBROUTINE MatRestoreArray(A,mat_data,mat_offset,ierr)
      Mat A
      PetscScalar mat_data(1)
      PetscOffset mat_offset
      PetscInt ierr
    END SUBROUTINE MatRestoreArray
        
    SUBROUTINE MatRestoreArrayF90(A,mat_data,ierr)
      Mat A
      PetscScalar, POINTER :: mat_data(:)
      PetscInt ierr
    END SUBROUTINE MatRestoreArrayF90
    
    SUBROUTINE MatSetLocalToGlobalMapping(A,ctx,ierr)
      Mat A
      ISLocalToGlobalMapping ctx
      PetscInt ierr
    END SUBROUTINE MatSetLocalToGlobalMapping

    SUBROUTINE MatSetOption(A,option,ierr)
      Mat A
      MatOption option
      PetscInt ierr
    END SUBROUTINE MatSetOption

    SUBROUTINE MatSetSizes(A,localm,localn,globalM,globalN,ierr)
      Mat A
      PetscInt localm
      PetscInt localn
      PetscInt globalM
      PetscInt globalN
      PetscInt ierr
    END SUBROUTINE MatSetSizes
    
    SUBROUTINE MatSetValue(A,row,col,value,insertmode,ierr)
      Mat A
      PetscInt row
      PetscInt col
      PetscScalar value
      InsertMode insertmode
      PetscInt ierr
    END SUBROUTINE MatSetValue
    
    SUBROUTINE MatSetValues(A,m,mindices,n,nindices,values,insertmode,ierr)
      Mat A
      PetscInt m
      PetscInt mindices(*)
      PetscInt n
      PetscInt nindices(*)
      PetscScalar values(*)
      InsertMode insertmode
      PetscInt ierr
    END SUBROUTINE MatSetValues
    
    SUBROUTINE MatSetValuesLocal(A,m,mindices,n,nindices,values,insertmode,ierr)
      Mat A
      PetscInt m
      PetscInt mindices(*)
      PetscInt n
      PetscInt nindices(*)
      PetscScalar values(*)
      InsertMode insertmode
      PetscInt ierr
    END SUBROUTINE MatSetValuesLocal
    
    SUBROUTINE MatSetValueLocal(A,row,col,value,insertmode,ierr)
      Mat A
      PetscInt row
      PetscInt col
      PetscScalar value
      InsertMode insertmode
      PetscInt ierr
    END SUBROUTINE MatSetValueLocal
    
    SUBROUTINE MatView(A,v,ierr)
      Mat A
      PetscViewer v
      PetscInt ierr
    END SUBROUTINE MatView

    SUBROUTINE MatZeroEntries(A,ierr)
      Mat A
      PetscInt ierr
    END SUBROUTINE MatZeroEntries
    
    SUBROUTINE PCSetType(pc,method,ierr)
      PC pc
      PCType method
      PetscInt ierr
    END SUBROUTINE PCSetType
    
    SUBROUTINE PetscFinalize(ierr)
      PetscInt ierr
    END SUBROUTINE PetscFinalize
    
    SUBROUTINE PetscInitialize(file,ierr)
      PetscChar(*) file
      PetscInt ierr
    END SUBROUTINE PetscInitialize

    SUBROUTINE PetscLogPrintSummary(comm,file,ierr)
      MPI_Comm comm
      PetscChar(*) file
      PetscInt ierr
    END SUBROUTINE PetscLogPrintSummary

    SUBROUTINE SNESCreate(comm,snes,ierr)
      MPI_Comm comm
      SNES snes
      PetscInt ierr
    END SUBROUTINE SNESCreate

    SUBROUTINE SNESDestroy(snes,ierr)
      SNES snes
      PetscInt ierr
    END SUBROUTINE SNESDestroy

    SUBROUTINE SNESGetConvergedReason(snes,reason,ierr)
      SNES snes
      SNESConvergedReason reason
      PetscInt ierr
    END SUBROUTINE SNESGetConvergedReason
    
    SUBROUTINE SNESGetFunctionNorm(snes,fnorm,ierr)
      SNES snes
      PetscReal fnorm
      PetscInt ierr
    END SUBROUTINE SNESGetFunctionNorm

    SUBROUTINE SNESGetIterationNumber(snes,iter,ierr)
      SNES snes
      PetscInt iter
      PetscInt ierr
    END SUBROUTINE SNESGetIterationNumber

    SUBROUTINE SNESLineSearchSet(snes,func,lsctx,ierr)
      SNES snes
      EXTERNAL func
      PetscFortranAddr lsctx
      PetscInt ierr
    END SUBROUTINE SNESLineSearchSet
    
    SUBROUTINE SNESLineSearchSetParams(snes,alpha,maxstep,steptol,ierr)
      SNES snes
      PetscReal alpha
      PetscReal maxstep
      PetscReal steptol
      PetscInt ierr
    END SUBROUTINE SNESLineSearchSetParams
    
    SUBROUTINE SNESSetFromOptions(snes,ierr)
      SNES snes
      PetscInt ierr
    END SUBROUTINE SNESSetFromOptions

    SUBROUTINE SNESSetFunction(snes,f,ffunction,ctx,ierr)
      USE TYPES
      SNES snes
      Vec f
      EXTERNAL ffunction
      TYPE(SOLUTION_TYPE), POINTER :: ctx
      PetscInt ierr
    END SUBROUTINE SNESSetFunction

    !Can't have a definition here as we have multiple contexts
    !SUBROUTINE SNESSetJacobian(snes,A,B,Jfunction,ctx,ierr)
    !  USE TYPES
    !  SNES snes
    !  Mat A
    !  Mat B      
    !  EXTERNAL Jfunction
    !  TYPE(SOLVER_TYPE), POINTER :: ctx
    !  PetscInt ierr
    !END SUBROUTINE SNESSetJacobian

    SUBROUTINE SNESSetTolerances(snes,abstol,rtol,stol,maxit,maxf,ierr)
      SNES snes
      PetscReal abstol
      PetscReal rtol
      PetscReal stol
      PetscInt maxit
      PetscInt maxf
      PetscInt ierr
    END SUBROUTINE SNESSetTolerances
    
    SUBROUTINE SNESSetTrustRegionTolerance(snes,trtol,ierr)
      SNES snes
      PetscReal trtol
      PetscInt ierr
    END SUBROUTINE SNESSetTrustRegionTolerance

    SUBROUTINE SNESSetType(snes,method,ierr)
      SNES snes
      SNESType method
      PetscInt ierr
    END SUBROUTINE SNESSetType

    SUBROUTINE SNESSolve(snes,b,x,ierr)
      SNES snes
      Vec b
      Vec x
      PetscInt ierr
    END SUBROUTINE SNESSolve

    SUBROUTINE VecAssemblyBegin(x,ierr)
      Vec x
      PetscInt ierr
    END SUBROUTINE VecAssemblyBegin

    SUBROUTINE VecAssemblyEnd(x,ierr)
      Vec x
      PetscInt ierr
    END SUBROUTINE VecAssemblyEnd

    SUBROUTINE VecCreate(comm,x,ierr)
      MPI_Comm comm
      Vec x
      PetscInt ierr
    END SUBROUTINE VecCreate

    SUBROUTINE VecCreateGhost(comm,localm,globalm,nghost,ghosts,x,ierr)
      MPI_Comm comm
      PetscInt localm
      PetscInt globalm
      PetscInt nghost
      PetscInt ghosts(*)
      Vec x
      PetscInt ierr
    END SUBROUTINE VecCreateGhost

    SUBROUTINE VecCreateGhostWithArray(comm,localm,globalm,nghost,ghosts,array,x,ierr)
      MPI_Comm comm
      PetscInt localm
      PetscInt globalm
      PetscInt nghost
      PetscInt ghosts(*)
      PetscScalar array(*)
      Vec x
      PetscInt ierr
    END SUBROUTINE VecCreateGhostWithArray

    SUBROUTINE VecCreateMPI(comm,localm,globalm,x,ierr)
      MPI_Comm comm
      PetscInt localm
      PetscInt globalm
      Vec x
      PetscInt ierr
    END SUBROUTINE VecCreateMPI

    SUBROUTINE VecCreateMPIWithArray(comm,localn,globaln,array,x,ierr)
      MPI_Comm comm
      PetscInt localn
      PetscInt globaln
      PetscScalar array(*)
      Vec x
      PetscInt ierr
    END SUBROUTINE VecCreateMPIWithArray

    SUBROUTINE VecCreateSeq(comm,m,x,ierr)
      MPI_Comm comm
      PetscInt m
      Vec x
      PetscInt ierr
    END SUBROUTINE VecCreateSeq

    SUBROUTINE VecCreateSeqWithArray(comm,n,array,x,ierr)
      MPI_Comm comm
      PetscInt n
      PetscScalar array(*)
      Vec x
      PetscInt ierr
    END SUBROUTINE VecCreateSeqWithArray

    SUBROUTINE VecDestroy(x,ierr)
      Vec x
      PetscInt ierr
    END SUBROUTINE VecDestroy

    SUBROUTINE VecDuplicate(old,new,ierr)
      Vec old,new
      PetscInt ierr
    END SUBROUTINE VecDuplicate

    SUBROUTINE VecGetArray(x,vec_data,vec_offset,ierr)
      Vec x
      PetscScalar vec_data(1)
      PetscOffset vec_offset
      PetscInt ierr
    END SUBROUTINE VecGetArray
    
    SUBROUTINE VecGetArrayF90(x,vec_data,ierr)
      Vec x
      PetscScalar, POINTER :: vec_data(:)
      PetscInt ierr
    END SUBROUTINE VecGetArrayF90

    SUBROUTINE VecGetLocalSize(x,size,ierr)
      Vec x
      PetscInt size
      PetscInt ierr
    END SUBROUTINE VecGetLocalSize

    SUBROUTINE VecGetOwnershipRange(x,low,high,ierr)
      Vec x
      PetscInt low
      PetscInt high
      PetscInt ierr
    END SUBROUTINE VecGetOwnershipRange

    SUBROUTINE VecGetSize(x,size,ierr)
      Vec x
      PetscInt size
      PetscInt ierr
    END SUBROUTINE VecGetSize

    SUBROUTINE VecGetValues(x,n,indices,values,ierr)
      Vec x
      PetscInt n
      PetscInt indices(*)
      PetscScalar values(*)
      PetscInt ierr
    END SUBROUTINE VecGetValues

    SUBROUTINE VecGhostGetLocalForm(g,l,ierr)
      Vec g
      Vec l
      PetscInt ierr
    END SUBROUTINE VecGhostGetLocalForm

    SUBROUTINE VecGhostRestoreLocalForm(g,l,ierr)
      Vec g
      Vec l
      PetscInt ierr
    END SUBROUTINE VecGhostRestoreLocalForm

   SUBROUTINE VecGhostUpdateBegin(x,insertmode,scattermode,ierr)
      Vec x
      InsertMode insertmode
      ScatterMode scattermode
      PetscInt ierr
    END SUBROUTINE VecGhostUpdateBegin

    SUBROUTINE VecGhostUpdateEnd(x,insertmode,scattermode,ierr)
      Vec x
      InsertMode insertmode
      ScatterMode scattermode
      PetscInt ierr
    END SUBROUTINE VecGhostUpdateEnd

    SUBROUTINE VecRestoreArray(x,vec_data,vec_offset,ierr)
      Vec x
      PetscScalar vec_data(1)
      PetscOffset vec_offset
      PetscInt ierr
    END SUBROUTINE VecRestoreArray

    SUBROUTINE VecRestoreArrayF90(x,vec_data,ierr)
      Vec x
      PetscScalar, POINTER :: vec_data(:)
      PetscInt ierr
    END SUBROUTINE VecRestoreArrayF90

    SUBROUTINE VecSet(x,value,ierr)
      Vec x
      PetscScalar value
      PetscInt ierr
    END SUBROUTINE VecSet

    SUBROUTINE VecSetFromOptions(x,ierr)
      Vec x
      PetscInt ierr
    END SUBROUTINE VecSetFromOptions

    SUBROUTINE VecSetLocalToGlobalMapping(v,ctx,ierr)
      Vec v
      ISLocalToGlobalMapping ctx
      PetscInt ierr
    END SUBROUTINE VecSetLocalToGlobalMapping

    SUBROUTINE VecSetSizes(x,localm,globalm,ierr)
      Vec x
      PetscInt localm,globalm
      PetscInt ierr
    END SUBROUTINE VecSetSizes

    SUBROUTINE VecSetValues(x,n,indices,values,insertmode,ierr)
      Vec x
      PetscInt n
      PetscInt indices(*)
      PetscScalar values(*)
      InsertMode insertmode
      PetscInt ierr
    END SUBROUTINE VecSetValues

    SUBROUTINE VecSetValuesLocal(x,n,indices,values,insertmode,ierr)
      Vec x
      PetscInt n
      PetscInt indices(*)
      PetscScalar values(*)
      InsertMode insertmode
      PetscInt ierr
    END SUBROUTINE VecSetValuesLocal

    SUBROUTINE VecView(x,v,ierr)
      Vec x
      PetscViewer v
      PetscInt ierr
    END SUBROUTINE VecView

  END INTERFACE

  INTERFACE PETSC_SNESSETJACOBIAN
    MODULE PROCEDURE PETSC_SNESSETJACOBIAN_SOLVER  
    MODULE PROCEDURE PETSC_SNESSETJACOBIAN_MATFDCOLORING
  END INTERFACE !PETSC_SNESSETJACOBIAN

  PUBLIC PETSC_ADD_VALUES,PETSC_INSERT_VALUES,PETSC_COMM_WORLD,PETSC_COMM_SELF,PETSC_DECIDE,PETSC_DEFAULT_INTEGER, &
    & PETSC_DEFAULT_DOUBLE_PRECISION,PETSC_NULL_CHARACTER,PETSC_NULL_DOUBLE,PETSC_NULL_INTEGER,PETSC_NULL_SCALAR, &
    & PETSC_SCATTER_FORWARD,PETSC_SCATTER_REVERSE
  
  PUBLIC PETSC_KSPRICHARDSON,PETSC_KSPCHEBYCHEV,PETSC_KSPCG,PETSC_KSPCGNE,PETSC_KSPSTCG,PETSC_KSPGMRES,PETSC_KSPFGMRES, &
    & PETSC_KSPLGMRES,PETSC_KSPTCQMR,PETSC_KSPBCGS,PETSC_KSPBCGSL,PETSC_KSPCGS,PETSC_KSPTFQMR,PETSC_KSPCR,PETSC_KSPLSQR, &
    & PETSC_KSPPREONLY,PETSC_KSPQCG,PETSC_KSPBICG,PETSC_KSPMINRES,PETSC_KSPSYMMLQ,PETSC_KSPLCD
  
  PUBLIC PETSC_PCNONE,PETSC_PCJACOBI,PETSC_PCSOR,PETSC_PCLU,PETSC_PCSHELL,PETSC_PCBJACOBI,PETSC_PCMG,PETSC_PCEISENSTAT, &
    & PETSC_PCILU,PETSC_PCICC,PETSC_PCASM,PETSC_PCKSP,PETSC_PCCOMPOSITE,PETSC_PCREDUNDANT,PETSC_PCSPAI,PETSC_PCMILU, &
    & PETSC_PCNN,PETSC_PCCHOLESKY,PETSC_PCSAMG,PETSC_PCPBJACOBI,PETSC_PCMAT,PETSC_PCHYPRE,PETSC_PCFIELDSPLIT,PETSC_PCML

  PUBLIC PETSC_SAME_PRECONDITIONER,PETSC_SAME_NONZERO_PATTERN,PETSC_DIFFERENT_NONZERO_PATTERN

  PUBLIC PETSC_ISINITIALISE,PETSC_ISFINALISE,PETSC_ISDESTROY

  PUBLIC PETSC_ISCOLORINGINITIALISE,PETSC_ISCOLORINGFINALISE,PETSC_ISCOLORINGDESTROY
  
  PUBLIC PETSC_ISLOCALTOGLOBALMAPPINGINITIALISE,PETSC_ISLOCALTOGLOBALMAPPINGFINALISE,PETSC_ISLOCALTOGLOBALMAPPINGAPPLY, &
    & PETSC_ISLOCALTOGLOBALMAPPINGAPPLYIS,PETSC_ISLOCALTOGLOBALMAPPINGCREATE,PETSC_ISLOCALTOGLOBALMAPPINGDESTROY

  PUBLIC PETSC_KSP_CONVERGED_RTOL,PETSC_KSP_CONVERGED_ATOL,PETSC_KSP_CONVERGED_ITS,PETSC_KSP_CONVERGED_CG_NEG_CURVE, &
    & PETSC_KSP_CONVERGED_CG_CONSTRAINED,PETSC_KSP_CONVERGED_STEP_LENGTH,PETSC_KSP_CONVERGED_HAPPY_BREAKDOWN, &
    & PETSC_KSP_DIVERGED_NULL,PETSC_KSP_DIVERGED_ITS,PETSC_KSP_DIVERGED_DTOL,PETSC_KSP_DIVERGED_BREAKDOWN, &
    & PETSC_KSP_DIVERGED_BREAKDOWN_BICG,PETSC_KSP_DIVERGED_NONSYMMETRIC,PETSC_KSP_DIVERGED_INDEFINITE_PC, &
    & PETSC_KSP_DIVERGED_NAN,PETSC_KSP_DIVERGED_INDEFINITE_MAT,PETSC_KSP_CONVERGED_ITERATING
  
  PUBLIC PETSC_KSPCREATE,PETSC_KSPDESTROY,PETSC_KSPGETCONVERGEDREASON,PETSC_KSPGETITERATIONNUMBER,PETSC_KSPGETPC, &
    & PETSC_KSPGETRESIDUALNORM,PETSC_KSPFINALISE,PETSC_KSPINITIALISE,PETSC_KSPSETFROMOPTIONS,PETSC_KSPSETOPERATORS, &
    & PETSC_KSPSETTYPE,PETSC_KSPSETUP,PETSC_KSPSETTOLERANCES,PETSC_KSPSOLVE

  PUBLIC MAT_COLUMN_ORIENTED,MAT_COLUMNS_SORTED,MAT_ROWS_SORTED,MAT_FINAL_ASSEMBLY,MAT_FLUSH_ASSEMBLY, &
    & MAT_NO_NEW_NONZERO_LOCATIONS

  PUBLIC PETSC_MATCOLORING_NATURAL,PETSC_MATCOLORING_SL,PETSC_MATCOLORING_LF,PETSC_MATCOLORING_ID

  PUBLIC PETSC_MATINITIALISE,PETSC_MATFINALISE,PETSC_MATASSEMBLYBEGIN,PETSC_MATASSEMBLYEND,PETSC_MATCREATE, &
    & PETSC_MATCREATEMPIAIJ,PETSC_MATCREATEMPIDENSE,PETSC_MATCREATESEQAIJ,PETSC_MATCREATESEQDENSE,PETSC_MATDESTROY, &
    & PETSC_MATFDCOLORINGCREATE,PETSC_MATFDCOLORINGDESTROY,PETSC_MATFDCOLORINGFINALISE,PETSC_MATFDCOLORINGINITIALISE, &
    & PETSC_MATFDCOLORINGSETFROMOPTIONS,PETSC_MATGETARRAY,PETSC_MATGETCOLORING,PETSC_MATGETOWNERSHIPRANGE,PETSC_MATGETVALUES, &
    & PETSC_MATRESTOREARRAY,PETSC_MATSETLOCALTOGLOBALMAPPING,PETSC_MATSETOPTION,PETSC_MATSETSIZES,PETSC_MATSETVALUE, &
    & PETSC_MATSETVALUES,PETSC_MATSETVALUELOCAL,PETSC_MATSETVALUESLOCAL,PETSC_MATVIEW,PETSC_MATZEROENTRIES
  
  PUBLIC PETSC_PCINITIALISE,PETSC_PCFINALISE,PETSC_PCSETTYPE

  PUBLIC PETSC_ERRORHANDLING_SET_OFF,PETSC_ERRORHANDLING_SET_ON
  
  PUBLIC PETSC_FINALIZE,PETSC_INITIALIZE,PETSC_LOGPRINTSUMMARY

  PUBLIC PETSC_SNESLS,PETSC_SNESTR,PETSC_SNESTEST
  
  PUBLIC PETSC_SNES_LINESEARCH_NONORMS,PETSC_SNES_LINESEARCH_NO,PETSC_SNES_LINESEARCH_QUADRATIC,PETSC_SNES_LINESEARCH_CUBIC

  PUBLIC PETSC_SNES_CONVERGED_FNORM_ABS,PETSC_SNES_CONVERGED_FNORM_RELATIVE,PETSC_SNES_CONVERGED_PNORM_RELATIVE, &
    & PETSC_SNES_CONVERGED_ITS,PETSC_SNES_CONVERGED_TR_DELTA,PETSC_SNES_DIVERGED_FUNCTION_COUNT,PETSC_SNES_DIVERGED_LINEAR_SOLVE, &
    & PETSC_SNES_DIVERGED_FNORM_NAN,PETSC_SNES_DIVERGED_MAX_IT,PETSC_SNES_DIVERGED_LS_FAILURE,PETSC_SNES_DIVERGED_LOCAL_MIN, &
    & PETSC_SNES_CONVERGED_ITERATING

  PUBLIC PETSC_SNESFINALISE,PETSC_SNESINITIALISE,PETSC_SNESCREATE,PETSC_SNESDESTROY,PETSC_SNESGETCONVERGEDREASON, &
    & PETSC_SNESGETFUNCTIONNORM,PETSC_SNESGETITERATIONNUMBER,PETSC_SNESLINESEARCHSET,PETSC_SNESLINESEARCHSETPARAMS, &
    & PETSC_SNESSETFROMOPTIONS,PETSC_SNESSETFUNCTION,PETSC_SNESSETJACOBIAN,PETSC_SNESSETTOLERANCES, &
    & PETSC_SNESSETTRUSTREGIONTOLERANCE,PETSC_SNESSETTYPE,PETSC_SNESSOLVE
  
  PUBLIC PETSC_VECINITIALISE,PETSC_VECFINALISE,PETSC_VECASSEMBLYBEGIN,PETSC_VECASSEMBLYEND,PETSC_VECCREATE,PETSC_VECCREATEGHOST, &
    & PETSC_VECCREATEGHOSTWITHARRAY,PETSC_VECCREATEMPI,PETSC_VECCREATEMPIWITHARRAY,PETSC_VECCREATESEQ, &
    & PETSC_VECCREATESEQWITHARRAY,PETSC_VECDESTROY,PETSC_VECDUPLICATE,PETSC_VECGETARRAY,PETSC_VECGETARRAYF90, &
    & PETSC_VECGETLOCALSIZE,PETSC_VECGETOWNERSHIPRANGE,PETSC_VECGETSIZE,PETSC_VECGETVALUES,PETSC_VECGHOSTGETLOCALFORM, &
    & PETSC_VECGHOSTRESTORELOCALFORM,PETSC_VECGHOSTUPDATEBEGIN,PETSC_VECGHOSTUPDATEEND,PETSC_VECRESTOREARRAY, &
    & PETSC_VECRESTOREARRAYF90,PETSC_VECSET,PETSC_VECSETFROMOPTIONS,PETSC_VECSETLOCALTOGLOBALMAPPING,PETSC_VECSETSIZES, &
    & PETSC_VECSETVALUES,PETSC_VECSETVALUESLOCAL,PETSC_VECVIEW

  PUBLIC PETSC_VIEWER_STDOUT_WORLD,PETSC_VIEWER_STDOUT_SELF,PETSC_VIEWER_DRAW_WORLD,PETSC_VIEWER_DRAW_SELF

CONTAINS

  !
  !================================================================================================================================
  !

  !>Set PETSc error handling on
  SUBROUTINE PETSC_ERRORHANDLING_SET_OFF(ERR,ERROR,*)

    !Argument Variables
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ERRORHANDLING_SET_OFF",ERR,ERROR,*999)

    PETSC_HANDLE_ERROR=.FALSE.
    
    CALL EXITS("PETSC_ERRORHANDLING_SET_OFF")
    RETURN
999 CALL ERRORS("PETSC_ERRORHANDLING_SET_OFF",ERR,ERROR)
    CALL EXITS("PETSC_ERRORHANDLING_SET_OFF")
    RETURN 1
  END SUBROUTINE PETSC_ERRORHANDLING_SET_OFF
    
  !
  !================================================================================================================================
  !

  !>Set PETSc error handling on
  SUBROUTINE PETSC_ERRORHANDLING_SET_ON(ERR,ERROR,*)

    !Argument Variables
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ERRORHANDLING_SET_ON",ERR,ERROR,*999)

    PETSC_HANDLE_ERROR=.TRUE.
    
    CALL EXITS("PETSC_ERRORHANDLING_SET_ON")
    RETURN
999 CALL ERRORS("PETSC_ERRORHANDLING_SET_ON",ERR,ERROR)
    CALL EXITS("PETSC_ERRORHANDLING_SET_ON")
    RETURN 1
  END SUBROUTINE PETSC_ERRORHANDLING_SET_ON
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc PetscFinalize routine
  SUBROUTINE PETSC_FINALIZE(ERR,ERROR,*)

    !Argument Variables
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_FINALIZE",ERR,ERROR,*999)

    CALL PetscFinalize(ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in PetscFinalize",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_FINALIZE")
    RETURN
999 CALL ERRORS("PETSC_FINALIZE",ERR,ERROR)
    CALL EXITS("PETSC_FINALIZE")
    RETURN 1
  END SUBROUTINE PETSC_FINALIZE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc PetscInitialize routine.
  SUBROUTINE PETSC_INITIALIZE(FILE,ERR,ERROR,*)

    !Argument Variables
    CHARACTER(LEN=*), INTENT(IN) :: FILE !<Filename for PETSc options file
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_INITIALIZE",ERR,ERROR,*999)

    PETSC_HANDLE_ERROR=.TRUE.
    CALL PetscInitialize(FILE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in PetscInitialize",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_INITIALIZE")
    RETURN
999 CALL ERRORS("PETSC_INITIALIZE",ERR,ERROR)
    CALL EXITS("PETSC_INITIALIZE")
    RETURN 1
  END SUBROUTINE PETSC_INITIALIZE
    
  !
  !================================================================================================================================
  !

  !Finalise the PETSc IS structure and destroy the IS
  SUBROUTINE PETSC_ISFINALISE(IS_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_IS_TYPE), INTENT(INOUT) :: IS_ !<The IS to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISFINALISE",ERR,ERROR,*999)

    IF(IS_%IS_/=PETSC_NULL) THEN
      CALL PETSC_ISDESTROY(IS_,ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_ISFINALISE")
    RETURN
999 CALL ERRORS("PETSC_ISFINALISE",ERR,ERROR)
    CALL EXITS("PETSC_ISFINALISE")
    RETURN 1
  END SUBROUTINE PETSC_ISFINALISE
    
  !
  !================================================================================================================================
  !
  
  !Initialise the PETSc IS structure
  SUBROUTINE PETSC_ISINITIALISE(IS_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_IS_TYPE), INTENT(INOUT) :: IS_ !<The IS to initialise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISINITIALISE",ERR,ERROR,*999)

    IS_%IS_=PETSC_NULL
    
    CALL EXITS("PETSC_ISINITIALISE")
    RETURN
999 CALL ERRORS("PETSC_ISINITIALISE",ERR,ERROR)
    CALL EXITS("PETSC_ISINITIALISE")
    RETURN 1
  END SUBROUTINE PETSC_ISINITIALISE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc ISDestroy routine.
  SUBROUTINE PETSC_ISDESTROY(IS_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_IS_TYPE), INTENT(IN) :: IS_ !<The index set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISDESTROY",ERR,ERROR,*999)

    CALL ISDestroy(IS_%IS_,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in ISDestroy",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_ISDESTROY")
    RETURN
999 CALL ERRORS("PETSC_ISDESTROY",ERR,ERROR)
    CALL EXITS("PETSC_ISDESTROY")
    RETURN 1
  END SUBROUTINE PETSC_ISDESTROY
    
  !
  !
  !================================================================================================================================
  !

  !Finalise the PETSc ISColoring structure and destroy the ISColoring
  SUBROUTINE PETSC_ISCOLORINGFINALISE(ISCOLORING,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_ISCOLORING_TYPE), INTENT(INOUT) :: ISCOLORING !<The ISColoring to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISCOLORINGFINALISE",ERR,ERROR,*999)

    IF(ISCOLORING%ISCOLORING/=PETSC_NULL) THEN
      CALL PETSC_ISCOLORINGDESTROY(ISCOLORING,ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_ISCOLORINGFINALISE")
    RETURN
999 CALL ERRORS("PETSC_ISCOLORINGFINALISE",ERR,ERROR)
    CALL EXITS("PETSC_ISCOLORINGFINALISE")
    RETURN 1
  END SUBROUTINE PETSC_ISCOLORINGFINALISE
    
  !
  !================================================================================================================================
  !
  
  !Initialise the PETSc ISColoring structure
  SUBROUTINE PETSC_ISCOLORINGINITIALISE(ISCOLORING,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_ISCOLORING_TYPE), INTENT(INOUT) :: ISCOLORING !<The ISColoring to initialise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISCOLORINGINITIALISE",ERR,ERROR,*999)

    ISCOLORING%ISCOLORING=PETSC_NULL
    
    CALL EXITS("PETSC_ISCOLORINGINITIALISE")
    RETURN
999 CALL ERRORS("PETSC_ISCOLORINGINITIALISE",ERR,ERROR)
    CALL EXITS("PETSC_ISCOLORINGINITIALISE")
    RETURN 1
  END SUBROUTINE PETSC_ISCOLORINGINITIALISE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc ISColoringDestroy routine.
  SUBROUTINE PETSC_ISCOLORINGDESTROY(ISCOLORING,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_ISCOLORING_TYPE), INTENT(IN) :: ISCOLORING !<The index set coloring
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISCOLORINGDESTROY",ERR,ERROR,*999)

    CALL ISColoringDestroy(ISCOLORING%ISCOLORING,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in ISColoringDestroy",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_ISCOLORINGDESTROY")
    RETURN
999 CALL ERRORS("PETSC_ISCOLORINGDESTROY",ERR,ERROR)
    CALL EXITS("PETSC_ISCOLORINGDESTROY")
    RETURN 1
  END SUBROUTINE PETSC_ISCOLORINGDESTROY
    
  !================================================================================================================================
  !

  !Finalise the PETSc ISLocalToGlobalMapping structure and destroy the KSP
  SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGFINALISE(ISLOCALTOGLOBALMAPPING,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_ISLOCALTOGLOBALMAPPING_TYPE), INTENT(INOUT) :: ISLOCALTOGLOBALMAPPING !<The ISLocalToGlobalMapping to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISLOCALTOGLOBALMAPPINGFINALISE",ERR,ERROR,*999)

    IF(ISLOCALTOGLOBALMAPPING%ISLOCALTOGLOBALMAPPING/=PETSC_NULL) THEN
      CALL PETSC_ISLOCALTOGLOBALMAPPINGDESTROY(ISLOCALTOGLOBALMAPPING,ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGFINALISE")
    RETURN
999 CALL ERRORS("PETSC_ISLOCALTOGLOBALMAPPINGFINALISE",ERR,ERROR)
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGFINALISE")
    RETURN 1
  END SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGFINALISE
    
  !
  !================================================================================================================================
  !
  
  !Initialise the PETSc ISLocalToGlobalMapping structure
  SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGINITIALISE(ISLOCALTOGLOBALMAPPING,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_ISLOCALTOGLOBALMAPPING_TYPE), INTENT(INOUT) :: ISLOCALTOGLOBALMAPPING !<The ISLocalToGlobalMapping to initialise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISLOCALTOGLOBALMAPPINGINITIALISE",ERR,ERROR,*999)

    ISLOCALTOGLOBALMAPPING%ISLOCALTOGLOBALMAPPING=PETSC_NULL
    
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGINITIALISE")
    RETURN
999 CALL ERRORS("PETSC_ISLOCALTOGLOBALMAPPINGINITIALISE",ERR,ERROR)
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGINITIALISE")
    RETURN 1
  END SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGINITIALISE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc ISLocalToGlobalMappingApply routine.
  SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGAPPLY(CTX,TYPE,NIN,IDXIN,NOUT,IDXOUT,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_ISLOCALTOGLOBALMAPPING_TYPE), INTENT(IN) :: CTX !<The local to global mapping context
    INTEGER(INTG), INTENT(IN) :: TYPE !<The type of local to global mapping
    INTEGER(INTG), INTENT(IN) :: NIN !<The number of local indicies
    INTEGER(INTG), INTENT(IN) :: IDXIN(*)
    INTEGER(INTG), INTENT(OUT) :: NOUT
    INTEGER(INTG), INTENT(OUT) :: IDXOUT(*)
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISLOCALTOGLOBALMAPPINGAPPLY",ERR,ERROR,*999)

    CALL ISLocalToGlobalMappingApply(CTX%ISLOCALTOGLOBALMAPPING,TYPE,NIN,IDXIN,NOUT,IDXOUT,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in ISLocalToGlobalMappingApply",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGAPPLY")
    RETURN
999 CALL ERRORS("PETSC_ISLOCALTOGLOBALMAPPINGAPPLY",ERR,ERROR)
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGAPPLY")
    RETURN 1
  END SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGAPPLY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc ISLocalToGlobalMappingApplyIS routine.
  SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGAPPLYIS(CTX,ISIN,ISOUT,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_ISLOCALTOGLOBALMAPPING_TYPE), INTENT(IN), INTENT(IN) :: CTX !<The local to global mapping context
    TYPE(PETSC_IS_TYPE), INTENT(IN) :: ISIN
    TYPE(PETSC_IS_TYPE), INTENT(OUT) :: ISOUT
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISLOCALTOGLOBALMAPPINGAPPLYIS",ERR,ERROR,*999)

    CALL ISLocalToGlobalMappingApplyIS(CTX%ISLOCALTOGLOBALMAPPING,ISIN%IS_,ISOUT%IS_,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in ISLocalToGlobalMappingApplyIS",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGAPPLYIS")
    RETURN
999 CALL ERRORS("PETSC_ISLOCALTOGLOBALMAPPINGAPPLYIS",ERR,ERROR)
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGAPPLYIS")
    RETURN 1
  END SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGAPPLYIS
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc ISLocalToGlobalMappingCreate routine.
  SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGCREATE(COMMUNICATOR,N,GLOBALNUM,CTX,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    INTEGER(INTG), INTENT(IN) :: N !<The number of local indices
    INTEGER(INTG), INTENT(IN) :: GLOBALNUM(*) !<The global number for each local index
    TYPE(PETSC_ISLOCALTOGLOBALMAPPING_TYPE), INTENT(INOUT) :: CTX !<The local to global mapping context
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISLOCALTOGLOBALMAPPINGCREATE",ERR,ERROR,*999)

    CALL ISLocalToGlobalMappingCreate(COMMUNICATOR,N,GLOBALNUM,CTX%ISLOCALTOGLOBALMAPPING,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in ISLocalToGlobalMappingCreate",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGCREATE")
    RETURN
999 CALL ERRORS("PETSC_ISLOCALTOGLOBALMAPPINGCREATE",ERR,ERROR)
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGCREATE")
    RETURN 1
  END SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGCREATE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc ISLocalToGlobalMappingDestroy routine.
  SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGDESTROY(CTX,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_ISLOCALTOGLOBALMAPPING_TYPE), INTENT(INOUT) :: CTX !<The local to global mapping context
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_ISLOCALTOGLOBALMAPPINGDESTROY",ERR,ERROR,*999)

    CALL ISLocalToGlobalMappingDestroy(CTX%ISLOCALTOGLOBALMAPPING,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in ISLocalToGlobalMappingDestroy",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGDESTROY")
    RETURN
999 CALL ERRORS("PETSC_ISLOCALTOGLOBALMAPPINGDESTROY",ERR,ERROR)
    CALL EXITS("PETSC_ISLOCALTOGLOBALMAPPINGDESTROY")
    RETURN 1
  END SUBROUTINE PETSC_ISLOCALTOGLOBALMAPPINGDESTROY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPCreate routine
  SUBROUTINE PETSC_KSPCREATE(COMMUNICATOR,KSP_,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator for the KSP creation
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<On exit, the Ksp information
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPCREATE",ERR,ERROR,*999)

    CALL KSPCreate(COMMUNICATOR,KSP_%KSP_,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPCreate",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPCREATE")
    RETURN
999 CALL ERRORS("PETSC_KSPCREATE",ERR,ERROR)
    CALL EXITS("PETSC_KSPCREATE")
    RETURN 1
  END SUBROUTINE PETSC_KSPCREATE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPDestroy routine
  SUBROUTINE PETSC_KSPDESTROY(KSP_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The Ksp to destroy
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPDESTROY",ERR,ERROR,*999)

    CALL KSPDestroy(KSP_%KSP_,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPDestroy",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPDESTROY")
    RETURN
999 CALL ERRORS("PETSC_KSPDESTROY",ERR,ERROR)
    CALL EXITS("PETSC_KSPDESTROY")
    RETURN 1
  END SUBROUTINE PETSC_KSPDESTROY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPGetConvergedReason routine
  SUBROUTINE PETSC_KSPGETCONVERGEDREASON(KSP_,REASON,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The KSP information
    INTEGER(INTG), INTENT(OUT) :: REASON !<On exit, the converged reason
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPGETCONVERGEDREASON",ERR,ERROR,*999)

    CALL KSPGetConvergedReason(KSP_%KSP_,REASON,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPGetConvergedReason",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPGETCONVERGEDREASON")
    RETURN
999 CALL ERRORS("PETSC_KSPGETCONVERGEDREASON",ERR,ERROR)
    CALL EXITS("PETSC_KSPGETCONVERGEDREASON")
    RETURN 1
  END SUBROUTINE PETSC_KSPGETCONVERGEDREASON
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPGetIterationNumber routine
  SUBROUTINE PETSC_KSPGETITERATIONNUMBER(KSP_,ITERATION_NUMBER,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The KSP information
    INTEGER(INTG), INTENT(OUT) :: ITERATION_NUMBER !<On exit, the number of iterations
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPGETITERATIONNUMBER",ERR,ERROR,*999)

    CALL KSPGetIterationNumber(KSP_%KSP_,ITERATION_NUMBER,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPGetIterationNumber",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPGETITERATIONNUMBER")
    RETURN
999 CALL ERRORS("PETSC_KSPGETITERATIONNUMBER",ERR,ERROR)
    CALL EXITS("PETSC_KSPGETITERATIONNUMBER")
    RETURN 1
  END SUBROUTINE PETSC_KSPGETITERATIONNUMBER
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPGetPC routine
  SUBROUTINE PETSC_KSPGETPC(KSP_,PC_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The Ksp to get the PC for
    TYPE(PETSC_PC_TYPE), INTENT(INOUT) :: PC_ !<On exit, the PC associated with the Ksp
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPGETPC",ERR,ERROR,*999)

    CALL KSPGetPC(KSP_%KSP_,PC_%PC_,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPGetPC",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPGETPC")
    RETURN
999 CALL ERRORS("PETSC_KSPGETPC",ERR,ERROR)
    CALL EXITS("PETSC_KSPGETPC")
    RETURN 1
  END SUBROUTINE PETSC_KSPGETPC
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPGetResidualNorm routine
  SUBROUTINE PETSC_KSPGETRESIDUALNORM(KSP_,RESIDUAL_NORM,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The Ksp to get the PC for
    REAL(DP), INTENT(OUT) :: RESIDUAL_NORM !<On exit, the residual norm for the KSP
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPGETRESIDUALNORM",ERR,ERROR,*999)

    CALL KSPGetResidualNorm(KSP_%KSP_,RESIDUAL_NORM,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPGetResidualNorm.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPGETRESIDUALNORM")
    RETURN
999 CALL ERRORS("PETSC_KSPGETRESIDUALNORM",ERR,ERROR)
    CALL EXITS("PETSC_KSPGETRESIDUALNORM")
    RETURN 1
  END SUBROUTINE PETSC_KSPGETRESIDUALNORM
    
  !
  !================================================================================================================================
  !

  !Finalise the PETSc KSP structure and destroy the KSP
  SUBROUTINE PETSC_KSPFINALISE(KSP_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The Ksp to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPFINALISE",ERR,ERROR,*999)

    IF(KSP_%KSP_/=PETSC_NULL) THEN
      CALL PETSC_KSPDESTROY(KSP_,ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPFINALISE")
    RETURN
999 CALL ERRORS("PETSC_KSPFINALISE",ERR,ERROR)
    CALL EXITS("PETSC_KSPFINALISE")
    RETURN 1
  END SUBROUTINE PETSC_KSPFINALISE
    
  !
  !================================================================================================================================
  !

  !Initialise the PETSc KSP structure
  SUBROUTINE PETSC_KSPINITIALISE(KSP_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The Ksp to initialise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPINITIALISE",ERR,ERROR,*999)

    KSP_%KSP_=PETSC_NULL
    
    CALL EXITS("PETSC_KSPINITIALISE")
    RETURN
999 CALL ERRORS("PETSC_KSPINITIALISE",ERR,ERROR)
    CALL EXITS("PETSC_KSPINITIALISE")
    RETURN 1
  END SUBROUTINE PETSC_KSPINITIALISE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPSetFromOptions routine
  SUBROUTINE PETSC_KSPSETFROMOPTIONS(KSP_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The Ksp to set the options for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPSETFROMOPTIONS",ERR,ERROR,*999)

    CALL KSPSetFromOptions(KSP_%KSP_,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPSetFromOptions",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPSETFROMOPTIONS")
    RETURN
999 CALL ERRORS("PETSC_KSPSETFROMOPTIONS",ERR,ERROR)
    CALL EXITS("PETSC_KSPSETFROMOPTIONS")
    RETURN 1
  END SUBROUTINE PETSC_KSPSETFROMOPTIONS
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPSetOperators routine
  SUBROUTINE PETSC_KSPSETOPERATORS(KSP_,AMAT,PMAT,FLAG,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The Ksp to set the operators for
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: AMAT !<The matrix associated with the linear system
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: PMAT !<The matrix to be used in constructing the precoditioner
    INTEGER(INTG), INTENT(IN) :: FLAG !<Preconditioner matrix structure flag
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPSETOPERATORS",ERR,ERROR,*999)

    CALL KSPSetOperators(KSP_%KSP_,AMAT%MAT,PMAT%MAT,FLAG,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPSetFromOperators",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPSETOPERATORS")
    RETURN
999 CALL ERRORS("PETSC_KSPSETOPERATORS",ERR,ERROR)
    CALL EXITS("PETSC_KSPSETOPERATORS")
    RETURN 1
  END SUBROUTINE PETSC_KSPSETOPERATORS
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPSetTolerances routine
  SUBROUTINE PETSC_KSPSETTOLERANCES(KSP_,RTOL,ATOL,DTOL,MAXITS,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The Ksp to set the tolerances for
    REAL(DP), INTENT(IN) :: RTOL !<The relative tolerance to set
    REAL(DP), INTENT(IN) :: ATOL !<The absolution tolerance to set
    REAL(DP), INTENT(IN) :: DTOL !<The divergence tolerance to set
    INTEGER(INTG), INTENT(IN) :: MAXITS !<The maximum number of iterations
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPSETTOLERANCES",ERR,ERROR,*999)

    CALL KSPSetTolerances(KSP_%KSP_,RTOL,ATOL,DTOL,MAXITS,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPSetTolerances",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPSETTOLERANCES")
    RETURN
999 CALL ERRORS("PETSC_KSPSETTOLERANCES",ERR,ERROR)
    CALL EXITS("PETSC_KSPSETTOLERANCES")
    RETURN 1
  END SUBROUTINE PETSC_KSPSETTOLERANCES
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPSetType routine
  SUBROUTINE PETSC_KSPSETTYPE(KSP_,METHOD,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The Ksp to set the type for
    KSPType, INTENT(IN) :: METHOD !<The Ksp method
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPSETTYPE",ERR,ERROR,*999)

    CALL KSPSetType(KSP_%KSP_,METHOD,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPSetType",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPSETTYPE")
    RETURN
999 CALL ERRORS("PETSC_KSPSETTYPE",ERR,ERROR)
    CALL EXITS("PETSC_KSPSETTYPE")
    RETURN 1
  END SUBROUTINE PETSC_KSPSETTYPE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPSetUp routine
  SUBROUTINE PETSC_KSPSETUP(KSP_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The Ksp to set up
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPSETUP",ERR,ERROR,*999)

    CALL KSPSetUp(KSP_%KSP_,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPSetUp",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPSETUP")
    RETURN
999 CALL ERRORS("PETSC_KSPSETUP",ERR,ERROR)
    CALL EXITS("PETSC_KSPSETUP")
    RETURN 1
  END SUBROUTINE PETSC_KSPSETUP
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc KSPSolve routine
  SUBROUTINE PETSC_KSPSOLVE(KSP_,B,X,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_KSP_TYPE), INTENT(INOUT) :: KSP_ !<The Ksp to set up
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: B !<The RHS vector
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT)  :: X !<The solution vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_KSPSOLVE",ERR,ERROR,*999)

    CALL KSPSolve(KSP_%KSP_,B%VEC,X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in KSPSolve",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_KSPSOLVE")
    RETURN
999 CALL ERRORS("PETSC_KSPSOLVE",ERR,ERROR)
    CALL EXITS("PETSC_KSPSOLVE")
    RETURN 1
  END SUBROUTINE PETSC_KSPSOLVE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc PetscLogPrintSummary routine.
  SUBROUTINE PETSC_LOGPRINTSUMMARY(COMMUNICATOR,FILE,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    CHARACTER(LEN=*), INTENT(IN) :: FILE !<Filename for the log summary
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_LOGPRINTSUMMARY",ERR,ERROR,*999)

    CALL PetscLogPrintSummary(COMMUNICATOR,FILE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in PetscLogPrintSummary",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_LOGPRINTSUMMARY")
    RETURN
999 CALL ERRORS("PETSC_LOGPRINTSUMMARY",ERR,ERROR)
    CALL EXITS("PETSC_LOGPRINTSUMMARY")
    RETURN 1
  END SUBROUTINE PETSC_LOGPRINTSUMMARY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatAssemblyBegin routine.
  SUBROUTINE PETSC_MATASSEMBLYBEGIN(A,ASSEMBLY_TYPE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !The matrix to assemble
    MatAssemblyType, INTENT(IN) :: ASSEMBLY_TYPE !<The assembly type 
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATASSEMBLYBEGIN",ERR,ERROR,*999)

    CALL MatAssemblyBegin(A%MAT,ASSEMBLY_TYPE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatAssemblyBegin",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATASSEMBLYBEGIN")
    RETURN
999 CALL ERRORS("PETSC_MATASSEMBLYBEGIN",ERR,ERROR)
    CALL EXITS("PETSC_MATASSEMBLYBEGIN")
    RETURN 1
  END SUBROUTINE PETSC_MATASSEMBLYBEGIN
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatAssemblyEnd routine.
  SUBROUTINE PETSC_MATASSEMBLYEND(A,ASSEMBLY_TYPE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to assemble
    MatAssemblyType, INTENT(IN) :: ASSEMBLY_TYPE !<The assembly type
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATASSEMBLYEND",ERR,ERROR,*999)

    CALL MatAssemblyEnd(A%MAT,ASSEMBLY_TYPE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatAssemblyEnd",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATASSEMBLYEND")
    RETURN
999 CALL ERRORS("PETSC_MATASSEMBLYEND",ERR,ERROR)
    CALL EXITS("PETSC_MATASSEMBLYEND")
    RETURN 1
  END SUBROUTINE PETSC_MATASSEMBLYEND
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatCreate routine.
  SUBROUTINE PETSC_MATCREATE(COMMUNICATOR,A,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI Communicator
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<On exit, the created matrix
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATCREATE",ERR,ERROR,*999)

    CALL MatCreate(COMMUNICATOR,A%MAT,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatCreate",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATCREATE")
    RETURN
999 CALL ERRORS("PETSC_MATCREATE",ERR,ERROR)
    CALL EXITS("PETSC_MATCREATE")
    RETURN 1
  END SUBROUTINE PETSC_MATCREATE    
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatCreateMPIAIJ routine.
  SUBROUTINE PETSC_MATCREATEMPIAIJ(COMMUNICATOR,LOCAL_M,LOCAL_N,GLOBAL_M,GLOBAL_N,DIAG_NUMBER_NZ_PERROW,DIAG_NUMBER_NZ_EACHROW, &
    & OFFDIAG_NUMBER_NZ_PERROW,OFFDIAG_NUMBER_NZ_EACHROW,A,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    INTEGER(INTG), INTENT(IN) :: LOCAL_M !<The number of local rows
    INTEGER(INTG), INTENT(IN) :: LOCAL_N !<The number of local columns
    INTEGER(INTG), INTENT(IN) :: GLOBAL_M !<The number of global rows
    INTEGER(INTG), INTENT(IN) :: GLOBAL_N !<The number of global columns
    INTEGER(INTG), INTENT(IN) :: DIAG_NUMBER_NZ_PERROW !<The maximum number of non-zeros per row in the diagonal part of the matrix
    INTEGER(INTG), INTENT(IN) :: DIAG_NUMBER_NZ_EACHROW(*) !<The number of non-zeros per row in the diagonal part of the matrix
    INTEGER(INTG), INTENT(IN) :: OFFDIAG_NUMBER_NZ_PERROW !<The maximum number of non-zeros per row in the off-diagonal part of the matrix
    INTEGER(INTG), INTENT(IN) :: OFFDIAG_NUMBER_NZ_EACHROW(*) !<The number of non-zeros per row in the off-diagonal part of the matrix
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<On exit, the matrix to create
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATCREATEMPIAIJ",ERR,ERROR,*999)

    CALL MatCreateMPIAIJ(COMMUNICATOR,LOCAL_M,LOCAL_N,GLOBAL_M,GLOBAL_N,DIAG_NUMBER_NZ_PERROW,DIAG_NUMBER_NZ_EACHROW, &
      & OFFDIAG_NUMBER_NZ_PERROW,OFFDIAG_NUMBER_NZ_EACHROW,A%MAT,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatCreateMPIAIJ",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATCREATEMPIAIJ")
    RETURN
999 CALL ERRORS("PETSC_MATCREATEMPIAIJ",ERR,ERROR)
    CALL EXITS("PETSC_MATCREATEMPIAIJ")
    RETURN 1
  END SUBROUTINE PETSC_MATCREATEMPIAIJ
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatCreateMPIDense routine.
  SUBROUTINE PETSC_MATCREATEMPIDENSE(COMMUNICATOR,LOCAL_M,LOCAL_N,GLOBAL_M,GLOBAL_N,MATRIX_DATA,A,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    INTEGER(INTG), INTENT(IN) :: LOCAL_M !<The number of local rows
    INTEGER(INTG), INTENT(IN) :: LOCAL_N !<The number of local columns
    INTEGER(INTG), INTENT(IN) :: GLOBAL_M !<The number of global columns
    INTEGER(INTG), INTENT(IN) :: GLOBAL_N !<The number of global rows
    REAL(DP), INTENT(IN) :: MATRIX_DATA(*) !<Optional, the allocated matrix data.
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<On exit, the matrix to create
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATCREATEMPIDENSE",ERR,ERROR,*999)

    CALL MatCreateMPIDense(COMMUNICATOR,LOCAL_M,LOCAL_N,GLOBAL_M,GLOBAL_N,MATRIX_DATA,A%MAT,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatCreateMPIDense",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATCREATEMPIDENSE")
    RETURN
999 CALL ERRORS("PETSC_MATCREATEMPIDENSE",ERR,ERROR)
    CALL EXITS("PETSC_MATCREATEMPIDENSE")
    RETURN 1
  END SUBROUTINE PETSC_MATCREATEMPIDENSE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatCreateSeqAIJ routine.
  SUBROUTINE PETSC_MATCREATESEQAIJ(COMMUNICATOR,M,N,NUMBER_NZ_PERROW,NUMBER_NZ_EACHROW,A,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    INTEGER(INTG), INTENT(IN) :: M !<The number of rows
    INTEGER(INTG), INTENT(IN) :: N !<The number of columns
    INTEGER(INTG), INTENT(IN) :: NUMBER_NZ_PERROW !<The maximum number of non-zeros per row
    INTEGER(INTG), INTENT(IN) :: NUMBER_NZ_EACHROW(*) !<The number of non-zeros in each row
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<On exit, the created matrix
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATCREATESEQAIJ",ERR,ERROR,*999)

    CALL MatCreateSeqAIJ(COMMUNICATOR,M,N,NUMBER_NZ_PERROW,NUMBER_NZ_EACHROW,A%MAT,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatCreateSeqAIJ",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATCREATESEQAIJ")
    RETURN
999 CALL ERRORS("PETSC_MATCREATESEQAIJ",ERR,ERROR)
    CALL EXITS("PETSC_MATCREATESEQAIJ")
    RETURN 1
  END SUBROUTINE PETSC_MATCREATESEQAIJ
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatCreateSeqDense routine.
  SUBROUTINE PETSC_MATCREATESEQDENSE(COMMUNICATOR,M,N,MATRIX_DATA,A,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI Communicator
    INTEGER(INTG), INTENT(IN) :: M !<The number of rows
    INTEGER(INTG), INTENT(IN) :: N !<The number of columns
    REAL(DP), INTENT(IN) :: MATRIX_DATA(*) !<Optional, the allocated matrix data
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<On exit, the created matrix
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATCREATESEQDENSE",ERR,ERROR,*999)

    CALL MatCreateSeqDense(COMMUNICATOR,M,N,MATRIX_DATA,A%MAT,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatCreateSeqDense",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATCREATESEQDENSE")
    RETURN
999 CALL ERRORS("PETSC_MATCREATESEQDENSE",ERR,ERROR)
    CALL EXITS("PETSC_MATCREATESEQDENSE")
    RETURN 1
  END SUBROUTINE PETSC_MATCREATESEQDENSE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatDestroy routine.
  SUBROUTINE PETSC_MATDESTROY(A,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to destroy
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATDESTROY",ERR,ERROR,*999)

    CALL MatDestroy(A%MAT,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatDestroy",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATDESTROY")
    RETURN
999 CALL ERRORS("PETSC_MATDESTROY",ERR,ERROR)
    CALL EXITS("PETSC_MATDESTROY")
    RETURN 1
  END SUBROUTINE PETSC_MATDESTROY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatFDColoringCreate routine.
  SUBROUTINE PETSC_MATFDCOLORINGCREATE(A,ISCOLORING,FDCOLORING,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The PETSc matrix to create the FD coloring for
    TYPE(PETSC_ISCOLORING_TYPE), INTENT(IN) :: ISCOLORING !<The index set coloring to create the finite difference coloring for
    TYPE(PETSC_MATFDCOLORING_TYPE), INTENT(OUT) :: FDCOLORING !<On exit, the matrix finite difference coloring
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATFDCOLORINGCREATE",ERR,ERROR,*999)

    CALL MatFDColoringCreate(A%MAT,ISCOLORING%ISCOLORING,FDCOLORING%MATFDCOLORING,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatFDColoringCreate",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATFDCOLORINGCREATE")
    RETURN
999 CALL ERRORS("PETSC_MATFDCOLORINGCREATE",ERR,ERROR)
    CALL EXITS("PETSC_MATFDCOLORINGCREATE")
    RETURN 1
  END SUBROUTINE PETSC_MATFDCOLORINGCREATE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatFDColoringDestroy routine.
  SUBROUTINE PETSC_MATFDCOLORINGDESTROY(MATFDCOLORING,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MATFDCOLORING_TYPE), INTENT(INOUT) :: MATFDCOLORING !<The matrix finite difference coloring to destroy
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATFDCOLORINGDESTROY",ERR,ERROR,*999)

    CALL MatFDColoringDestroy(MATFDCOLORING%MATFDCOLORING,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatFDColoringDestroy",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATFDCOLORINGDESTROY")
    RETURN
999 CALL ERRORS("PETSC_MATFDCOLORINGDESTROY",ERR,ERROR)
    CALL EXITS("PETSC_MATFDCOLORINGDESTROY")
    RETURN 1
  END SUBROUTINE PETSC_MATFDCOLORINGDESTROY
    
  !
  !================================================================================================================================
  !

  !Finalise the PETSc MatFDColoring structure and destroy the MatFDColoring
  SUBROUTINE PETSC_MATFDCOLORINGFINALISE(MATFDCOLORING,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MATFDCOLORING_TYPE), INTENT(INOUT) :: MATFDCOLORING !<The MatFDColoring to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATFDCOLORINGFINALISE",ERR,ERROR,*999)

    IF(MATFDCOLORING%MATFDCOLORING/=PETSC_NULL) THEN
      CALL PETSC_MATFDCOLORINGDESTROY(MATFDCOLORING,ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATFDCOLORINGFINALISE")
    RETURN
999 CALL ERRORS("PETSC_MATFDCOLORINGFINALISE",ERR,ERROR)
    CALL EXITS("PETSC_MATFDCOLORINGFINALISE")
    RETURN 1
  END SUBROUTINE PETSC_MATFDCOLORINGFINALISE
    
  !
  !================================================================================================================================
  !
  
  !Initialise the PETSc MatFDColoring structure
  SUBROUTINE PETSC_MATFDCOLORINGINITIALISE(MATFDCOLORING,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MATFDCOLORING_TYPE), INTENT(INOUT) :: MATFDCOLORING !<The MatFDColoring to initialise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATFDCOLORINGINITIALISE",ERR,ERROR,*999)

    MATFDCOLORING%MATFDCOLORING=PETSC_NULL
    
    CALL EXITS("PETSC_MATFDCOLORINGINITIALISE")
    RETURN
999 CALL ERRORS("PETSC_MATFDCOLORINGINITIALISE",ERR,ERROR)
    CALL EXITS("PETSC_MATFDCOLORINGINITIALISE")
    RETURN 1
  END SUBROUTINE PETSC_MATFDCOLORINGINITIALISE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatFDColoringSetFromOptions routine.
  SUBROUTINE PETSC_MATFDCOLORINGSETFROMOPTIONS(MATFDCOLORING,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MATFDCOLORING_TYPE), INTENT(INOUT) :: MATFDCOLORING !<The matrix finite difference coloring to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATFDCOLORINGSETFROMOPTIONS",ERR,ERROR,*999)

    CALL MatFDColoringSetFromOptions(MATFDCOLORING%MATFDCOLORING,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatFDColoringSetFromOptions",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATFDCOLORINGSETFROMOPTIONS")
    RETURN
999 CALL ERRORS("PETSC_MATFDCOLORINGSETFROMOPTIONS",ERR,ERROR)
    CALL EXITS("PETSC_MATFDCOLORINGSETFROMOPTIONS")
    RETURN 1
  END SUBROUTINE PETSC_MATFDCOLORINGSETFROMOPTIONS
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatGetArray routine.
  SUBROUTINE PETSC_MATGETARRAY(A,ARRAY,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT), TARGET :: A !<The matrix to get the array for
    REAL(DP), POINTER :: ARRAY(:) !<On exit, a pointer to the matrix array
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATGETARRAY",ERR,ERROR,*999)

    IF(ASSOCIATED(ARRAY)) THEN
      CALL FLAG_ERROR("Array is already associated",ERR,ERROR,*999)
    ELSE
      CALL MatGetArray(A%MAT,A%MAT_DATA,A%MAT_OFFSET,ERR)
      IF(ERR/=0) THEN
        IF(PETSC_HANDLE_ERROR) THEN
          CHKERRQ(ERR)
        ENDIF
        CALL FLAG_ERROR("PETSc error in MatGetArray",ERR,ERROR,*999)
      ENDIF
      ARRAY=>A%MAT_DATA(A%MAT_OFFSET:)
    ENDIF
    
    CALL EXITS("PETSC_MATGETARRAY")
    RETURN
999 CALL ERRORS("PETSC_MATGETARRAY",ERR,ERROR)
    CALL EXITS("PETSC_MATGETARRAY")
    RETURN 1
  END SUBROUTINE PETSC_MATGETARRAY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatGetColoring routine.
  SUBROUTINE PETSC_MATGETCOLORING(A,COLORING_TYPE,ISCOLORING,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to get the ownership range of
    MatColoringType, INTENT(IN) :: COLORING_TYPE !<The coloring type
    TYPE(PETSC_ISCOLORING_TYPE), INTENT(OUT) :: ISCOLORING !<On exit, the index set coloring
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATGETCOLORING",ERR,ERROR,*999)

    CALL MatGetColoring(A%MAT,COLORING_TYPE,ISCOLORING%ISCOLORING,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatGetColoring",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATGETCOLORING")
    RETURN
999 CALL ERRORS("PETSC_MATGETCOLORING",ERR,ERROR)
    CALL EXITS("PETSC_MATGETCOLORING")
    RETURN 1
  END SUBROUTINE PETSC_MATGETCOLORING
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatGetOwnershipRange routine.
  SUBROUTINE PETSC_MATGETOWNERSHIPRANGE(A,FIRST_ROW,LAST_ROW,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to get the ownership range of
    INTEGER(INTG), INTENT(OUT) :: FIRST_ROW !<On exit, the first row for the matrix
    INTEGER(INTG), INTENT(OUT) :: LAST_ROW !<On exit, the last row for the matrix
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATGETOWNERSHIPRANGE",ERR,ERROR,*999)

    CALL MatGetOwnershipRange(A%MAT,FIRST_ROW,LAST_ROW,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatGetOwnershipRange",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATGETOWNERSHIPRANGE")
    RETURN
999 CALL ERRORS("PETSC_MATGETOWNERSHIPRANGE",ERR,ERROR)
    CALL EXITS("PETSC_MATGETOWNERSHIPRANGE")
    RETURN 1
  END SUBROUTINE PETSC_MATGETOWNERSHIPRANGE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatGetValues routine.
  SUBROUTINE PETSC_MATGETVALUES(A,M,M_INDICES,N,N_INDICES,VALUES,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to get the values of
    INTEGER(INTG), INTENT(IN) :: M !<The number of row indices
    INTEGER(INTG), INTENT(IN) :: M_INDICES(*) !<The row indices
    INTEGER(INTG), INTENT(IN) :: N !<The number of column indices
    INTEGER(INTG), INTENT(IN) :: N_INDICES(*) !<The column indices
    REAL(DP), INTENT(OUT) :: VALUES(*) !<The values to get
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATGETVALUES",ERR,ERROR,*999)

    CALL MatGetValues(A%MAT,M,M_INDICES,N,N_INDICES,VALUES,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatGetValues",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATGETVALUES")
    RETURN
999 CALL ERRORS("PETSC_MATGETVALUES",ERR,ERROR)
    CALL EXITS("PETSC_MATGETVALUES")
    RETURN 1
  END SUBROUTINE PETSC_MATGETVALUES
    
  !
  !================================================================================================================================
  !

  !Finalise the PETSc Mat structure and destroy the KSP
  SUBROUTINE PETSC_MATFINALISE(MAT_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: MAT_ !<The MAT to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATFINALISE",ERR,ERROR,*999)

    IF(MAT_%MAT/=PETSC_NULL) THEN
      CALL PETSC_MATDESTROY(MAT_,ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATFINALISE")
    RETURN
999 CALL ERRORS("PETSC_MATFINALISE",ERR,ERROR)
    CALL EXITS("PETSC_MATFINALISE")
    RETURN 1
  END SUBROUTINE PETSC_MATFINALISE
    
  !
  !================================================================================================================================
  !

  !Initialise the PETSc Mat structure
  SUBROUTINE PETSC_MATINITIALISE(MAT_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: MAT_ !<The MAT to initialise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATINITIALISE",ERR,ERROR,*999)

    MAT_%MAT=PETSC_NULL
    MAT_%MAT_DATA(1)=0
    MAT_%MAT_OFFSET=0
    
    CALL EXITS("PETSC_MATINITIALISE")
    RETURN
999 CALL ERRORS("PETSC_MATINITIALISE",ERR,ERROR)
    CALL EXITS("PETSC_MATINITIALISE")
    RETURN 1
  END SUBROUTINE PETSC_MATINITIALISE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatRestoreArray routine.
  SUBROUTINE PETSC_MATRESTOREARRAY(A,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to restore the array for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATRESTOREARRAY",ERR,ERROR,*999)

    CALL MatRestoreArray(A%MAT,A%MAT_DATA,A%MAT_OFFSET,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatRestoreArray",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATRESTOREARRAY")
    RETURN
999 CALL ERRORS("PETSC_MATRESTOREARRAY",ERR,ERROR)
    CALL EXITS("PETSC_MATRESTOREARRAY")
    RETURN 1
  END SUBROUTINE PETSC_MATRESTOREARRAY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatSetLocalToGlobalMapping routine.
  SUBROUTINE PETSC_MATSETLOCALTOGLOBALMAPPING(A,CTX,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to set the local to global mapping for
    TYPE(PETSC_ISLOCALTOGLOBALMAPPING_TYPE), INTENT(IN) :: CTX !<The local to global mapping context
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATSETLOCALTOGLOBALMAPPING",ERR,ERROR,*999)

    CALL MatSetLocalToGlobalMapping(A%MAT,CTX%ISLOCALTOGLOBALMAPPING,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatSetLocalToGlobalMapping",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATSETLOCALTOGLOBALMAPPING")
    RETURN
999 CALL ERRORS("PETSC_MATSETLOCALTOGLOBALMAPPING",ERR,ERROR)
    CALL EXITS("PETSC_MATSETLOCALTOGLOBALMAPPING")
    RETURN 1
  END SUBROUTINE PETSC_MATSETLOCALTOGLOBALMAPPING
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatSetOption routine.
  SUBROUTINE PETSC_MATSETOPTION(A,OPTION,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to set the option for
    MatOption, INTENT(IN) :: OPTION !<The option to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATSETOPTION",ERR,ERROR,*999)

    CALL MatSetOption(A%MAT,OPTION,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatSetOption",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATSETOPTION")
    RETURN
999 CALL ERRORS("PETSC_MATSETOPTION",ERR,ERROR)
    CALL EXITS("PETSC_MATSETOPTION")
    RETURN 1
  END SUBROUTINE PETSC_MATSETOPTION
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatSetSizes routine.
  SUBROUTINE PETSC_MATSETSIZES(A,LOCAL_M,LOCAL_N,GLOBAL_M,GLOBAL_N,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to set the size of
    INTEGER(INTG), INTENT(IN) :: LOCAL_M !<Number of local rows
    INTEGER(INTG), INTENT(IN) :: LOCAL_N !<Number of local columns
    INTEGER(INTG), INTENT(IN) :: GLOBAL_M !<Number of global rows
    INTEGER(INTG), INTENT(IN) :: GLOBAL_N !<Number of global columns
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATSETSIZES",ERR,ERROR,*999)

    CALL MatSetSizes(A%MAT,LOCAL_M,LOCAL_N,GLOBAL_M,GLOBAL_N,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatSetSizes",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATSETSIZES")
    RETURN
999 CALL ERRORS("PETSC_MATSETSIZES",ERR,ERROR)
    CALL EXITS("PETSC_MATSETSIZES")
    RETURN 1
  END SUBROUTINE PETSC_MATSETSIZES
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatSetValue routine.
  SUBROUTINE PETSC_MATSETVALUE(A,ROW,COL,VALUE,INSERT_MODE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to set the values of
    INTEGER(INTG), INTENT(IN) :: ROW !<The row index
    INTEGER(INTG), INTENT(IN) :: COL !<The column index
    REAL(DP), INTENT(IN) :: VALUE !<The value to set
    InsertMode, INTENT(IN) :: INSERT_MODE !<The insert mode
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATSETVALUE",ERR,ERROR,*999)

    CALL MatSetValue(A%MAT,ROW,COL,VALUE,INSERT_MODE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatSetValue",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATSETVALUE")
    RETURN
999 CALL ERRORS("PETSC_MATSETVALUE",ERR,ERROR)
    CALL EXITS("PETSC_MATSETVALUE")
    RETURN 1
  END SUBROUTINE PETSC_MATSETVALUE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatSetValues routine.
  SUBROUTINE PETSC_MATSETVALUES(A,M,M_INDICES,N,N_INDICES,VALUES,INSERT_MODE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to set the values of
    INTEGER(INTG), INTENT(IN) :: M !<The number of row indices
    INTEGER(INTG), INTENT(IN) :: M_INDICES(*) !<The row indices
    INTEGER(INTG), INTENT(IN) :: N !<The number of column indices
    INTEGER(INTG), INTENT(IN) :: N_INDICES(*) !<The column indices
    REAL(DP), INTENT(IN) :: VALUES(*) !<The values to set
    InsertMode, INTENT(IN) :: INSERT_MODE !<The insert mode
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATSETVALUES",ERR,ERROR,*999)

    CALL MatSetValues(A%MAT,M,M_INDICES,N,N_INDICES,VALUES,INSERT_MODE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatSetValues",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATSETVALUES")
    RETURN
999 CALL ERRORS("PETSC_MATSETVALUES",ERR,ERROR)
    CALL EXITS("PETSC_MATSETVALUES")
    RETURN 1
  END SUBROUTINE PETSC_MATSETVALUES
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatSetValueLocal routine.
  SUBROUTINE PETSC_MATSETVALUELOCAL(A,ROW,COL,VALUE,INSERT_MODE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to set the values of
    INTEGER(INTG), INTENT(IN) :: ROW !<The row index
    INTEGER(INTG), INTENT(IN) :: COL !<The column index
    REAL(DP), INTENT(IN) :: VALUE !<The value to set
    InsertMode, INTENT(IN) :: INSERT_MODE !<The insert mode
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATSETVALUELOCAL",ERR,ERROR,*999)

    CALL MatSetValueLocal(A%MAT,ROW,COL,VALUE,INSERT_MODE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatSetValueLocal",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATSETVALUELOCAL")
    RETURN
999 CALL ERRORS("PETSC_MATSETVALUELOCAL",ERR,ERROR)
    CALL EXITS("PETSC_MATSETVALUELOCAL")
    RETURN 1
  END SUBROUTINE PETSC_MATSETVALUELOCAL
  
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatSetValuesLocal routine.
  SUBROUTINE PETSC_MATSETVALUESLOCAL(A,M,M_INDICES,N,N_INDICES,VALUES,INSERT_MODE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to set the values of
    INTEGER(INTG), INTENT(IN) :: M !<The number of row indices
    INTEGER(INTG), INTENT(IN) :: M_INDICES(*) !<The row indices
    INTEGER(INTG), INTENT(IN) :: N !<The number of column indices
    INTEGER(INTG), INTENT(IN) :: N_INDICES(*) !<The column indices
    REAL(DP), INTENT(IN) :: VALUES(*) !<The values to set
    InsertMode, INTENT(IN) :: INSERT_MODE !<The insert mode
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATSETVALUESLOCAL",ERR,ERROR,*999)

    CALL MatSetValuesLocal(A%MAT,M,M_INDICES,N,N_INDICES,VALUES,INSERT_MODE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatSetValuesLocal",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATSETVALUESLOCAL")
    RETURN
999 CALL ERRORS("PETSC_MATSETVALUESLOCAL",ERR,ERROR)
    CALL EXITS("PETSC_MATSETVALUESLOCAL")
    RETURN 1
  END SUBROUTINE PETSC_MATSETVALUESLOCAL
  
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatView routine.
  SUBROUTINE PETSC_MATVIEW(A,V,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to view
    PetscViewer, INTENT(IN) :: V !<The viewer
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATVIEW",ERR,ERROR,*999)

    CALL MatView(A%MAT,V,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatView",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATVIEW")
    RETURN
999 CALL ERRORS("PETSC_MATVIEW",ERR,ERROR)
    CALL EXITS("PETSC_MATVIEW")
    RETURN 1
  END SUBROUTINE PETSC_MATVIEW
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc MatZeroEntries routine.
  SUBROUTINE PETSC_MATZEROENTRIES(A,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The matrix to zero the entries of
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_MATZEROENTRIES",ERR,ERROR,*999)

    CALL MatZeroEntries(A%MAT,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in MatZeroEntries",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_MATZEROENTRIES")
    RETURN
999 CALL ERRORS("PETSC_MATZEROENTRIES",ERR,ERROR)
    CALL EXITS("PETSC_MATZEROENTRIES")
    RETURN 1
  END SUBROUTINE PETSC_MATZEROENTRIES
    
  !
  !================================================================================================================================
  !

  !Finalise the PETSc PC structure and destroy the KSP
  SUBROUTINE PETSC_PCFINALISE(PC_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_PC_TYPE), INTENT(INOUT) :: PC_ !<The PC to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_PCFINALISE",ERR,ERROR,*999)

    IF(PC_%PC_/=PETSC_NULL) THEN
      !Do nothing - should be destroyed when the KSP is destroyed.
    ENDIF
    
    CALL EXITS("PETSC_PCFINALISE")
    RETURN
999 CALL ERRORS("PETSC_PCFINALISE",ERR,ERROR)
    CALL EXITS("PETSC_PCFINALISE")
    RETURN 1
  END SUBROUTINE PETSC_PCFINALISE
    
  !
  !================================================================================================================================
  !

  !Initialise the PETSc PC structure
  SUBROUTINE PETSC_PCINITIALISE(PC_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_PC_TYPE), INTENT(INOUT) :: PC_ !<The PC to initialise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_PCINITIALISE",ERR,ERROR,*999)

    PC_%PC_=PETSC_NULL
    
    CALL EXITS("PETSC_PCINITIALISE")
    RETURN
999 CALL ERRORS("PETSC_PCINITIALISE",ERR,ERROR)
    CALL EXITS("PETSC_PCINITIALISE")
    RETURN 1
  END SUBROUTINE PETSC_PCINITIALISE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc PCSetType routine.
  SUBROUTINE PETSC_PCSETTYPE(PC_,METHOD,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_PC_TYPE), INTENT(INOUT) :: PC_ !<The preconditioner to set the type of
    PCType, INTENT(IN) :: METHOD !<The preconditioning method to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_PCSETTYPE",ERR,ERROR,*999)

    CALL PCSetType(PC_%PC_,METHOD,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in PCSetType",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_PCSETTYPE")
    RETURN
999 CALL ERRORS("PETSC_PCSETTYPE",ERR,ERROR)
    CALL EXITS("PETSC_PCSETTYPE")
    RETURN 1
  END SUBROUTINE PETSC_PCSETTYPE
    
   !
  !================================================================================================================================
  !

  !Finalise the PETSc SNES structure and destroy the SNES
  SUBROUTINE PETSC_SNESFINALISE(SNES_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESFINALISE",ERR,ERROR,*999)

    IF(SNES_%SNES_/=PETSC_NULL) THEN
      CALL PETSC_SNESDESTROY(SNES_,ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESFINALISE")
    RETURN
999 CALL ERRORS("PETSC_SNESFINALISE",ERR,ERROR)
    CALL EXITS("PETSC_SNESFINALISE")
    RETURN 1
  END SUBROUTINE PETSC_SNESFINALISE
    
  !
  !================================================================================================================================
  !

  !Initialise the PETSc SNES structure
  SUBROUTINE PETSC_SNESINITIALISE(SNES_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The snes to 
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESINITIALISE",ERR,ERROR,*999)

    SNES_%SNES_=PETSC_NULL
     
    CALL EXITS("PETSC_SNESINITIALISE")
    RETURN
999 CALL ERRORS("PETSC_SNESINITIALISE",ERR,ERROR)
    CALL EXITS("PETSC_SNESINITIALISE")
    RETURN 1
  END SUBROUTINE PETSC_SNESINITIALISE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESCreate routine.
  SUBROUTINE PETSC_SNESCREATE(COMMUNICATOR,SNES_,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator for the SNES creation
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<On exit, the SNES information
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESCREATE",ERR,ERROR,*999)

    CALL SNESCreate(COMMUNICATOR,SNES_%SNES_,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESCreate",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESCREATE")
    RETURN
999 CALL ERRORS("PETSC_SNESCREATE",ERR,ERROR)
    CALL EXITS("PETSC_SNESCREATE")
    RETURN 1
  END SUBROUTINE PETSC_SNESCREATE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESDestroy routine.
  SUBROUTINE PETSC_SNESDESTROY(SNES_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to destroy
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESDESTROY",ERR,ERROR,*999)

    CALL SNESDestroy(SNES_%SNES_,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESDestroy",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESDESTROY")
    RETURN
999 CALL ERRORS("PETSC_SNESDESTROY",ERR,ERROR)
    CALL EXITS("PETSC_SNESDESTROY")
    RETURN 1
  END SUBROUTINE PETSC_SNESDESTROY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESGetConvergedReason routine.
  SUBROUTINE PETSC_SNESGETCONVERGEDREASON(SNES_,REASON,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to get the converged reason for
    INTEGER(INTG), INTENT(OUT) :: REASON !<On exit, the converged reason
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESGETCONVERGEDREASON",ERR,ERROR,*999)

    CALL SNESGetConvergedReason(SNES_%SNES_,REASON,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESGetConvergedReason",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESGETCONVERGEDREASON")
    RETURN
999 CALL ERRORS("PETSC_SNESGETCONVERGEDREASON",ERR,ERROR)
    CALL EXITS("PETSC_SNESGETCONVERGEDREASON")
    RETURN 1
  END SUBROUTINE PETSC_SNESGETCONVERGEDREASON
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESGetFunctionNorm routine.
  SUBROUTINE PETSC_SNESGETFUNCTIONNORM(SNES_,FUNCTION_NORM,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to get the function norm for
    REAL(DP), INTENT(OUT) :: FUNCTION_NORM !<On exit, the function norm
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESGETFUNCTIONNORM",ERR,ERROR,*999)

    CALL SNESGetFunctionNorm(SNES_%SNES_,FUNCTION_NORM,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESGetFunctionNorm",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESGETFUNCTIONNORM")
    RETURN
999 CALL ERRORS("PETSC_SNESGETFUNCTIONNORM",ERR,ERROR)
    CALL EXITS("PETSC_SNESGETFUNCTIONNORM")
    RETURN 1
  END SUBROUTINE PETSC_SNESGETFUNCTIONNORM
    
 !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESGetIterationNumber routine.
  SUBROUTINE PETSC_SNESGETITERATIONNUMBER(SNES_,ITERATION_NUMBER,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to get the iteration number for
    INTEGER(INTG), INTENT(OUT) :: ITERATION_NUMBER !<On exit, the number of iterations
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESGETITERATIONNUMBER",ERR,ERROR,*999)

    CALL SNESGetIterationNumber(SNES_%SNES_,ITERATION_NUMBER,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESGetIterationNumber",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESGETITERATIONNUMBER")
    RETURN
999 CALL ERRORS("PETSC_SNESGETITERATIONNUMBER",ERR,ERROR)
    CALL EXITS("PETSC_SNESGETITERATIONNUMBER")
    RETURN 1
  END SUBROUTINE PETSC_SNESGETITERATIONNUMBER
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESLineSearchSet routine.
  SUBROUTINE PETSC_SNESLINESEARCHSET(SNES_,LINESEARCH_TYPE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to set the line search for
    INTEGER(INTG), INTENT(IN) :: LINESEARCH_TYPE !<The line search type
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESLINESEARCHSET",ERR,ERROR,*999)

    SELECT CASE(LINESEARCH_TYPE)
    CASE(PETSC_SNES_LINESEARCH_NONORMS)
      CALL SNESLineSearchSet(SNES_%SNES_,SNESLINESEARCHNONORMS,PETSC_NULL_OBJECT,ERR)
    CASE(PETSC_SNES_LINESEARCH_NO)
      CALL SNESLineSearchSet(SNES_%SNES_,SNESLINESEARCHNO,PETSC_NULL_OBJECT,ERR)
    CASE(PETSC_SNES_LINESEARCH_QUADRATIC)
      CALL SNESLineSearchSet(SNES_%SNES_,SNESLINESEARCHQUADRATIC,PETSC_NULL_OBJECT,ERR)
    CASE(PETSC_SNES_LINESEARCH_CUBIC)
      CALL SNESLineSearchSet(SNES_%SNES_,SNESLINESEARCHCUBIC,PETSC_NULL_OBJECT,ERR)
    CASE DEFAULT
      CALL FLAG_ERROR("Invalid line search type.",ERR,ERROR,*999)
    END SELECT
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESLineSearchSet.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESLINESEARCHSET")
    RETURN
999 CALL ERRORS("PETSC_SNESLINESEARCHSET",ERR,ERROR)
    CALL EXITS("PETSC_SNESLINESEARCHSET")
    RETURN 1
  END SUBROUTINE PETSC_SNESLINESEARCHSET
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESLineSearchSetParams routine.
  SUBROUTINE PETSC_SNESLINESEARCHSETPARAMS(SNES_,ALPHA,MAXSTEP,STEPTOL,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to set the line search parameters for
    REAL(DP), INTENT(IN) :: ALPHA !<The scalar such that 0.5f_{n+1} . f_{n+1} <= .5*f_n . f_n - alpha |f_n . J . f_n| 
    REAL(DP), INTENT(IN) :: MAXSTEP !<The maximum norm of the update vector
    REAL(DP), INTENT(IN) :: STEPTOL !<the minimum norm fraction of the the original step after scaling
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESLINESEARCHSETPARAMS",ERR,ERROR,*999)

    CALL SNESLineSearchSetParams(SNES_%SNES_,ALPHA,MAXSTEP,STEPTOL,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESLineSearchSetParams",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESLINESEARCHSETPARAMS")
    RETURN
999 CALL ERRORS("PETSC_SNESLINESEARCHSETPARAMS",ERR,ERROR)
    CALL EXITS("PETSC_SNESLINESEARCHSETPARAMS")
    RETURN 1
  END SUBROUTINE PETSC_SNESLINESEARCHSETPARAMS
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESSetFromOptions routine.
  SUBROUTINE PETSC_SNESSETFROMOPTIONS(SNES_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to set from the command line options
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESSETFROMOPTIONS",ERR,ERROR,*999)

    CALL SNESSetFromOptions(SNES_%SNES_,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESSetFromOptions",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESSETFROMOPTIONS")
    RETURN
999 CALL ERRORS("PETSC_SNESSETFROMOPTIONS",ERR,ERROR)
    CALL EXITS("PETSC_SNESSETFROMOPTIONS")
    RETURN 1
  END SUBROUTINE PETSC_SNESSETFROMOPTIONS
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESSetFunction routine.
  SUBROUTINE PETSC_SNESSETFUNCTION(SNES_,F,FFUNCTION,CTX,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to set the function for
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: F !<The residual vector
    EXTERNAL FFUNCTION !<The external function to call
    TYPE(SOLUTION_TYPE), POINTER :: CTX !<The solver data to pass to the function
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESSETFUNCTION",ERR,ERROR,*999)

    CALL SNESSetFunction(SNES_%SNES_,F%VEC,FFUNCTION,CTX,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESSetFunction",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESSETFUNCTION")
    RETURN
999 CALL ERRORS("PETSC_SNESSETFUNCTION",ERR,ERROR)
    CALL EXITS("PETSC_SNESSETFUNCTION")
    RETURN 1
  END SUBROUTINE PETSC_SNESSETFUNCTION
    
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESSetJacobian routine for MatFDColoring contexts.
  SUBROUTINE PETSC_SNESSETJACOBIAN_MATFDCOLORING(SNES_,A,B,JFUNCTION,CTX,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to set the function for
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The Jacobian matrix
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: B !<The Jacobian preconditioning matrix
    EXTERNAL JFUNCTION !<The external function to call
    TYPE(PETSC_MATFDCOLORING_TYPE) :: CTX !<The MatFDColoring data to pass to the function
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESSETJACOBIAN_MATFDCOLORING",ERR,ERROR,*999)

    CALL SNESSetJacobian(SNES_%SNES_,A%MAT,B%MAT,JFUNCTION,CTX%MATFDCOLORING,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESSetJacobian",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESSETJACOBIAN_MATFDCOLORING")
    RETURN
999 CALL ERRORS("PETSC_SNESSETJACOBIAN_MATFDCOLORING",ERR,ERROR)
    CALL EXITS("PETSC_SNESSETJACOBIAN_MATFDCOLORING")
    RETURN 1
  END SUBROUTINE PETSC_SNESSETJACOBIAN_MATFDCOLORING
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESSetJacobian routine for solver contexts.
  SUBROUTINE PETSC_SNESSETJACOBIAN_SOLVER(SNES_,A,B,JFUNCTION,CTX,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to set the function for
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: A !<The Jacobian matrix
    TYPE(PETSC_MAT_TYPE), INTENT(INOUT) :: B !<The Jacobian preconditioning matrix
    EXTERNAL JFUNCTION !<The external function to call
    TYPE(SOLVER_TYPE), POINTER :: CTX !<The solver data to pass to the function
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESSETJACOBIAN_SOLVER",ERR,ERROR,*999)

    CALL SNESSetJacobian(SNES_%SNES_,A%MAT,B%MAT,JFUNCTION,CTX,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESSetJacobian",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESSETJACOBIAN_SOLVER")
    RETURN
999 CALL ERRORS("PETSC_SNESSETJACOBIAN_SOLVER",ERR,ERROR)
    CALL EXITS("PETSC_SNESSETJACOBIAN_SOLVER")
    RETURN 1
  END SUBROUTINE PETSC_SNESSETJACOBIAN_SOLVER

  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESSetTolerances routine.
  SUBROUTINE PETSC_SNESSETTOLERANCES(SNES_,ABSTOL,RTOL,STOL,MAXIT,MAXF,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to set the tolerances for
    REAL(DP), INTENT(IN) :: ABSTOL !<The absolute convergence tolerance
    REAL(DP), INTENT(IN) :: RTOL !<The relative convergence tolerance
    REAL(DP), INTENT(IN) :: STOL !<The convergence tolerance for the change in the solution between steps
    INTEGER(INTG), INTENT(IN) :: MAXIT !<The maximum number of iterations
    INTEGER(INTG), INTENT(IN) :: MAXF !<The maximum number of function evaluations
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESSETTOLERANCES",ERR,ERROR,*999)

    CALL SNESSetTolerances(SNES_%SNES_,ABSTOL,RTOL,STOL,MAXIT,MAXF,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESSetTolerances",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESSETTOLERANCES")
    RETURN
999 CALL ERRORS("PETSC_SNESSETTOLERANCES",ERR,ERROR)
    CALL EXITS("PETSC_SNESSETTOLERANCES")
    RETURN 1
  END SUBROUTINE PETSC_SNESSETTOLERANCES
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESSetTrustRegionTolerance routine.
  SUBROUTINE PETSC_SNESSETTRUSTREGIONTOLERANCE(SNES_,TRTOL,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to set the tolerances for
    REAL(DP), INTENT(IN) :: TRTOL !<The trust region tolerance
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESSETTRUSTREGIONTOLERANCE",ERR,ERROR,*999)

    CALL SNESSetTrustRegionTolerance(SNES_%SNES_,TRTOL,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESSetTrustRegionTolerance",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESSETTRUSTREGIONTOLERANCE")
    RETURN
999 CALL ERRORS("PETSC_SNESSETTRUSTREGIONTOLERANCE",ERR,ERROR)
    CALL EXITS("PETSC_SNESSETTRUSTREGIONTOLERANCE")
    RETURN 1
  END SUBROUTINE PETSC_SNESSETTRUSTREGIONTOLERANCE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESSetType routine.
  SUBROUTINE PETSC_SNESSETTYPE(SNES_,METHOD,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to set the type for
    SNESType, INTENT(IN) :: METHOD !<The SNES type
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESSETTYPE",ERR,ERROR,*999)

    CALL SNESSetType(SNES_%SNES_,METHOD,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESSetType",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESSETTYPE")
    RETURN
999 CALL ERRORS("PETSC_SNESSETTYPE",ERR,ERROR)
    CALL EXITS("PETSC_SNESSETTYPE")
    RETURN 1
  END SUBROUTINE PETSC_SNESSETTYPE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc SNESSolve routine.
  SUBROUTINE PETSC_SNESSOLVE(SNES_,B,X,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_SNES_TYPE), INTENT(INOUT) :: SNES_ !<The SNES to solve
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: B !<The constant part of the equation
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The solution vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_SNESSOLVE",ERR,ERROR,*999)

    CALL SNESSolve(SNES_%SNES_,B%VEC,X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in SNESSolve",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_SNESSOLVE")
    RETURN
999 CALL ERRORS("PETSC_SNESSOLVE",ERR,ERROR)
    CALL EXITS("PETSC_SNESSOLVE")
    RETURN 1
  END SUBROUTINE PETSC_SNESSOLVE
    
  !
  !================================================================================================================================
  !

  !Finalise the PETSc Vec structure and destroy the KSP
  SUBROUTINE PETSC_VECFINALISE(VEC_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: VEC_ !<The Vec to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECFINALISE",ERR,ERROR,*999)

    IF(VEC_%VEC/=PETSC_NULL) THEN
      CALL PETSC_VECDESTROY(VEC_,ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECFINALISE")
    RETURN
999 CALL ERRORS("PETSC_VECFINALISE",ERR,ERROR)
    CALL EXITS("PETSC_VECFINALISE")
    RETURN 1
  END SUBROUTINE PETSC_VECFINALISE
    
  !
  !================================================================================================================================
  !

  !Initialise the PETSc Vec structure
  SUBROUTINE PETSC_VECINITIALISE(VEC_,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: VEC_ !<The Vec to initialise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECINITIALISE",ERR,ERROR,*999)

    VEC_%VEC=PETSC_NULL
    VEC_%VEC_DATA(1)=0
    VEC_%VEC_OFFSET=0
    
    CALL EXITS("PETSC_VECINITIALISE")
    RETURN
999 CALL ERRORS("PETSC_VECINITIALISE",ERR,ERROR)
    CALL EXITS("PETSC_VECINITIALISE")
    RETURN 1
  END SUBROUTINE PETSC_VECINITIALISE
  
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecAssemblyBegin routine.
  SUBROUTINE PETSC_VECASSEMBLYBEGIN(X,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to begin the assembly of
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECASSEMBLYBEGIN",ERR,ERROR,*999)

    CALL VecAssemblyBegin(X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecAssemblyBegin",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECASSEMBLYBEGIN")
    RETURN
999 CALL ERRORS("PETSC_VECASSEMBLYBEGIN",ERR,ERROR)
    CALL EXITS("PETSC_VECASSEMBLYBEGIN")
    RETURN 1
  END SUBROUTINE PETSC_VECASSEMBLYBEGIN
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecAssemblyEnd routine.
  SUBROUTINE PETSC_VECASSEMBLYEND(X,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to end the assembly of
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECASSEMBLYEND",ERR,ERROR,*999)

    CALL VecAssemblyEnd(X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecAssemblyEnd",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECASSEMBLYEND")
    RETURN
999 CALL ERRORS("PETSC_VECASSEMBLYEND",ERR,ERROR)
    CALL EXITS("PETSC_VECASSEMBLYEND")
    RETURN 1
  END SUBROUTINE PETSC_VECASSEMBLYEND
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecCreate routine.
  SUBROUTINE PETSC_VECCREATE(COMMUNICATOR,X,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<On exit, the created vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECCREATE",ERR,ERROR,*999)

    CALL VecCreate(COMMUNICATOR,X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecCreate",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECCREATE")
    RETURN
999 CALL ERRORS("PETSC_VECCREATE",ERR,ERROR)
    CALL EXITS("PETSC_VECCREATE")
    RETURN 1
  END SUBROUTINE PETSC_VECCREATE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecCreateGhost routine.
  SUBROUTINE PETSC_VECCREATEGHOST(COMMUNICATOR,LOCAL_SIZE,GLOBAL_SIZE,NUMBER_GHOST,GHOSTS,X,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    INTEGER(INTG), INTENT(IN) :: LOCAL_SIZE !<The number of local elements
    INTEGER(INTG), INTENT(IN) :: GLOBAL_SIZE !<The number of global elements
    INTEGER(INTG), INTENT(IN) :: NUMBER_GHOST !<The number of ghost elements
    INTEGER(INTG), INTENT(IN) :: GHOSTS(*) !<The global location of the each ghost element
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<On exit, the created vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECCREATEGHOST",ERR,ERROR,*999)

    CALL VecCreateGhost(COMMUNICATOR,LOCAL_SIZE,GLOBAL_SIZE,NUMBER_GHOST,GHOSTS,X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecCreateGhost",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECCREATEGHOST")
    RETURN
999 CALL ERRORS("PETSC_VECCREATEGHOST",ERR,ERROR)
    CALL EXITS("PETSC_VECCREATEGHOST")
    RETURN 1
  END SUBROUTINE PETSC_VECCREATEGHOST
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecCreateGhostWithArray routine.
  SUBROUTINE PETSC_VECCREATEGHOSTWITHARRAY(COMMUNICATOR,LOCAL_SIZE,GLOBAL_SIZE,NUMBER_GHOST,GHOSTS,ARRAY,X,ERR,ERROR,*)

   !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    INTEGER(INTG), INTENT(IN) :: LOCAL_SIZE !<The number of local elements
    INTEGER(INTG), INTENT(IN) :: GLOBAL_SIZE !<The number of global elements
    INTEGER(INTG), INTENT(IN) :: NUMBER_GHOST !<The number of ghost elements
    INTEGER(INTG), INTENT(IN) :: GHOSTS(*) !<The global location of the each ghost element
    REAL(DP), INTENT(OUT) :: ARRAY(*) !<The preallocated array of matrix data
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<On exit, the created vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECCREATEGHOSTWITHARRAY",ERR,ERROR,*999)

    CALL VecCreateGhostWithArray(COMMUNICATOR,LOCAL_SIZE,GLOBAL_SIZE,NUMBER_GHOST,GHOSTS,ARRAY,X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecCreateGhostWithArray",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECCREATEGHOSTWITHARRAY")
    RETURN
999 CALL ERRORS("PETSC_VECCREATEGHOSTWITHARRAY",ERR,ERROR)
    CALL EXITS("PETSC_VECCREATEGHOSTWITHARRAY")
    RETURN 1
  END SUBROUTINE PETSC_VECCREATEGHOSTWITHARRAY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecCreateMPI routine.
  SUBROUTINE PETSC_VECCREATEMPI(COMMUNICATOR,LOCAL_SIZE,GLOBAL_SIZE,X,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    INTEGER(INTG), INTENT(IN) :: LOCAL_SIZE !<The number of local elements
    INTEGER(INTG), INTENT(IN) :: GLOBAL_SIZE !<The number of global elements
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<On exit, the created vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECCREATEMPI",ERR,ERROR,*999)

    CALL VecCreateMPI(COMMUNICATOR,LOCAL_SIZE,GLOBAL_SIZE,X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecCreateMPI",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECCREATEMPI")
    RETURN
999 CALL ERRORS("PETSC_VECCREATEMPI",ERR,ERROR)
    CALL EXITS("PETSC_VECCREATEMPI")
    RETURN 1
  END SUBROUTINE PETSC_VECCREATEMPI
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecCreateMPIWithArray routine.
  SUBROUTINE PETSC_VECCREATEMPIWITHARRAY(COMMUNICATOR,LOCAL_SIZE,GLOBAL_SIZE,ARRAY,X,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    INTEGER(INTG), INTENT(IN) :: LOCAL_SIZE !<The number of local elements
    INTEGER(INTG), INTENT(IN) :: GLOBAL_SIZE !<The number of global elements
    REAL(DP), INTENT(OUT) :: ARRAY(*) !<The preallocated array for the vector data
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<On exit, the created vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECCREATEMPIWITHARRAY",ERR,ERROR,*999)

    CALL VecCreateMPIWithArray(COMMUNICATOR,LOCAL_SIZE,GLOBAL_SIZE,ARRAY,X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecCreateMPIWithArray",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECCREATEMPIWITHARRAY")
    RETURN
999 CALL ERRORS("PETSC_VECCREATEMPIWITHARRAY",ERR,ERROR)
    CALL EXITS("PETSC_VECCREATEMPIWITHARRAY")
    RETURN 1
  END SUBROUTINE PETSC_VECCREATEMPIWITHARRAY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecCreateSeq routine.
  SUBROUTINE PETSC_VECCREATESEQ(COMMUNICATOR,SIZE,X,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    INTEGER(INTG), INTENT(IN) :: SIZE !<The size of the vector
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<On exit, the created vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECCREATESEQ",ERR,ERROR,*999)

    CALL VecCreateSeq(COMMUNICATOR,SIZE,X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecCreateSeq",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECCREATESEQ")
    RETURN
999 CALL ERRORS("PETSC_VECCREATESEQ",ERR,ERROR)
    CALL EXITS("PETSC_VECCREATESEQ")
    RETURN 1
  END SUBROUTINE PETSC_VECCREATESEQ
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecCreateSeqWithArray routine.
  SUBROUTINE PETSC_VECCREATESEQWITHARRAY(COMMUNICATOR,SIZE,ARRAY,X,ERR,ERROR,*)

    !Argument Variables
    MPI_Comm, INTENT(IN) :: COMMUNICATOR !<The MPI communicator
    INTEGER(INTG), INTENT(IN) :: SIZE !<The size of the vector
    REAL(DP), INTENT(OUT) :: ARRAY(*) !<The preallocated array for the vector data
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<On exit, the created vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECCREATESEQWITHARRAY",ERR,ERROR,*999)

    CALL VecCreateSeqWithArray(COMMUNICATOR,SIZE,ARRAY,X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecCreateSeqWithArray",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECCREATESEQWITHARRAY")
    RETURN
999 CALL ERRORS("PETSC_VECCREATESEQWITHARRAY",ERR,ERROR)
    CALL EXITS("PETSC_VECCREATESEQWITHARRAY")
    RETURN 1
  END SUBROUTINE PETSC_VECCREATESEQWITHARRAY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecDestroy routine.
  SUBROUTINE PETSC_VECDESTROY(X,ERR,ERROR,*)

   !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to destroy
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECDESTROY",ERR,ERROR,*999)

    CALL VecDestroy(X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecDestroy",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECDESTROY")
    RETURN
999 CALL ERRORS("PETSC_VECDESTROY",ERR,ERROR)
    CALL EXITS("PETSC_VECDESTROY")
    RETURN 1
  END SUBROUTINE PETSC_VECDESTROY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecDuplicate routine.
  SUBROUTINE PETSC_VECDUPLICATE(OLD,NEW,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: OLD !<The vector to duplicate
    TYPE(PETSC_VEC_TYPE), INTENT(OUT) :: NEW !<On exit, the new duplicated vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECDUPLICATE",ERR,ERROR,*999)

    CALL VecDuplicate(OLD%VEC,NEW%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecDuplicate",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECDUPLICATE")
    RETURN
999 CALL ERRORS("PETSC_VECDUPLICATE",ERR,ERROR)
    CALL EXITS("PETSC_VECDUPLICATE")
    RETURN 1
  END SUBROUTINE PETSC_VECDUPLICATE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecGetArray routine.
  SUBROUTINE PETSC_VECGETARRAY(X,ARRAY,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT), TARGET :: X !<The vector to get the array of
    REAL(DP), POINTER :: ARRAY(:) !<On exit, a pointer to the array of the vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECGETARRAY",ERR,ERROR,*999)

    IF(ASSOCIATED(ARRAY)) THEN
      CALL FLAG_ERROR("Array is already associated",ERR,ERROR,*999)
    ELSE
      CALL VecGetArray(X%VEC,X%VEC_DATA,X%VEC_OFFSET,ERR)
      IF(ERR/=0) THEN
        IF(PETSC_HANDLE_ERROR) THEN
          CHKERRQ(ERR)
        ENDIF
        CALL FLAG_ERROR("PETSc error in VecGetArray",ERR,ERROR,*999)
      ENDIF
      ARRAY=>X%VEC_DATA(X%VEC_OFFSET:)
    ENDIF
    
    CALL EXITS("PETSC_VECGETARRAY")
    RETURN
999 CALL ERRORS("PETSC_VECGETARRAY",ERR,ERROR)
    CALL EXITS("PETSC_VECGETARRAY")
    RETURN 1
  END SUBROUTINE PETSC_VECGETARRAY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecGetArrayF90 routine.
  SUBROUTINE PETSC_VECGETARRAYF90(X,ARRAY,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT), TARGET :: X !<The vector to get the array of
    REAL(DP), POINTER :: ARRAY(:) !<On exit, a pointer to the array of the vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECGETARRAYF90",ERR,ERROR,*999)

    IF(ASSOCIATED(ARRAY)) THEN
      CALL FLAG_ERROR("Array is already associated",ERR,ERROR,*999)
    ELSE
      CALL VecGetArrayF90(X%VEC,ARRAY,ERR)
      IF(ERR/=0) THEN
        IF(PETSC_HANDLE_ERROR) THEN
          CHKERRQ(ERR)
        ENDIF
        CALL FLAG_ERROR("PETSc error in VecGetArrayF90",ERR,ERROR,*999)
      ENDIF
    ENDIF
    
    CALL EXITS("PETSC_VECGETARRAYF90")
    RETURN
999 CALL ERRORS("PETSC_VECGETARRAYF90",ERR,ERROR)
    CALL EXITS("PETSC_VECGETARRAYF90")
    RETURN 1
  END SUBROUTINE PETSC_VECGETARRAYF90
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecGetLocalSize routine.
  SUBROUTINE PETSC_VECGETLOCALSIZE(X,SIZE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to get the local size of
    INTEGER(INTG), INTENT(OUT) :: SIZE !<On exit, the local size of the vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECGETLOCALSIZE",ERR,ERROR,*999)

    CALL VecGetLocalSize(X%VEC,SIZE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecGetLocalSize",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECGETLOCALSIZE")
    RETURN
999 CALL ERRORS("PETSC_VECGETLOCALSIZE",ERR,ERROR)
    CALL EXITS("PETSC_VECGETLOCALSIZE")
    RETURN 1
  END SUBROUTINE PETSC_VECGETLOCALSIZE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecGetOwnershipRange routine.
  SUBROUTINE PETSC_VECGETOWNERSHIPRANGE(X,LOW,HIGH,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to get the ownership range of 
    INTEGER(INTG), INTENT(OUT) :: LOW !<On exit, the low end of the range
    INTEGER(INTG), INTENT(OUT) :: HIGH !<On exit, the high end of the range
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECGETOWNERSHIPRANGE",ERR,ERROR,*999)

    CALL VecGetOwnershipRange(X%VEC,LOW,HIGH,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
        ENDIF
      CALL FLAG_ERROR("PETSc error in VecGetOwnershipRange",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECGETOWNERSHIPRANGE")
    RETURN
999 CALL ERRORS("PETSC_VECGETOWNERSHIPRANGE",ERR,ERROR)
    CALL EXITS("PETSC_VECGETOWNERSHIPRANGE")
    RETURN 1
  END SUBROUTINE PETSC_VECGETOWNERSHIPRANGE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecGetSize routine.
  SUBROUTINE PETSC_VECGETSIZE(X,SIZE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to get the size of
    INTEGER(INTG), INTENT(OUT) :: SIZE !<On exit, the size of the vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECGETSIZE",ERR,ERROR,*999)

    CALL VecGetSize(X%VEC,SIZE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecGetSize",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECGETSIZE")
    RETURN
999 CALL ERRORS("PETSC_VECGETSIZE",ERR,ERROR)
    CALL EXITS("PETSC_VECGETSIZE")
    RETURN 1
  END SUBROUTINE PETSC_VECGETSIZE
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecGetValues routine.
  SUBROUTINE PETSC_VECGETVALUES(X,N,INDICES,VALUES,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to set the values for
    INTEGER(INTG), INTENT(IN) :: N !<The number of indicies to get
    INTEGER(INTG), INTENT(IN) :: INDICES(*) !<The indices to get
    REAL(DP), INTENT(OUT) :: VALUES(*) !<On return, the values at the specified indicies
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECGETVALUES",ERR,ERROR,*999)

    CALL VecGetValues(X%VEC,N,INDICES,VALUES,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecGetValues",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECGETVALUES")
    RETURN
999 CALL ERRORS("PETSC_VECGETVALUES",ERR,ERROR)
    CALL EXITS("PETSC_VECGETVALUES")
    RETURN 1
  END SUBROUTINE PETSC_VECGETVALUES
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecGhostGetLocalForm routine.
  SUBROUTINE PETSC_VECGHOSTGETLOCALFORM(G,L,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: G !<The global form of the vector
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: L !<On exit, the local form of the vector with ghosts
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECGHOSTGETLOCALFORM",ERR,ERROR,*999)

    CALL VecGhostGetLocalForm(G%VEC,L%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecGhostGetLocalForm",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECGHOSTGETLOCALFORM")
    RETURN
999 CALL ERRORS("PETSC_VECGHOSTGETLOCALFORM",ERR,ERROR)
    CALL EXITS("PETSC_VECGHOSTGETLOCALFORM")
    RETURN 1
  END SUBROUTINE PETSC_VECGHOSTGETLOCALFORM
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecGhostRestoreLocalForm routine.
  SUBROUTINE PETSC_VECGHOSTRESTORELOCALFORM(G,L,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: G !<The global form of the vector
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: L !<The local form of the vector
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECGHOSTRESTORELOCALFORM",ERR,ERROR,*999)

    CALL VecGhostRestoreLocalForm(G%VEC,L%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecGhostRestoreLocalForm",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECGHOSTRESTORELOCALFORM")
    RETURN
999 CALL ERRORS("PETSC_VECGHOSTRESTORELOCALFORM",ERR,ERROR)
    CALL EXITS("PETSC_VECGHOSTRESTORELOCALFORM")
    RETURN 1
  END SUBROUTINE PETSC_VECGHOSTRESTORELOCALFORM
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecGhostUpdateBegin routine.
  SUBROUTINE PETSC_VECGHOSTUPDATEBEGIN(X,INSERT_MODE,SCATTER_MODE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to begin the ghost update for
    InsertMode, INTENT(IN) :: INSERT_MODE !<The insert mode
    ScatterMode, INTENT(IN) :: SCATTER_MODE !<The scatter mode
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECGHOSTUPDATEBEGIN",ERR,ERROR,*999)

    CALL VecGhostUpdateBegin(X%VEC,INSERT_MODE,SCATTER_MODE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecGhostUpdateBegin",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECGHOSTUPDATEBEGIN")
    RETURN
999 CALL ERRORS("PETSC_VECGHOSTUPDATEBEGIN",ERR,ERROR)
    CALL EXITS("PETSC_VECGHOSTUPDATEBEGIN")
    RETURN 1
  END SUBROUTINE PETSC_VECGHOSTUPDATEBEGIN
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecGhostUpdateEnd routine.
  SUBROUTINE PETSC_VECGHOSTUPDATEEND(X,INSERT_MODE,SCATTER_MODE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to end the ghost update for
    InsertMode, INTENT(IN) :: INSERT_MODE !<The insert mode
    ScatterMode, INTENT(IN) :: SCATTER_MODE !<The scatter mode
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECGHOSTUPDATEEND",ERR,ERROR,*999)

    CALL VecGhostUpdateEnd(X%VEC,INSERT_MODE,SCATTER_MODE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecGhostUpdateEnd",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECGHOSTUPDATEEND")
    RETURN
999 CALL ERRORS("PETSC_VECGHOSTUPDATEEND",ERR,ERROR)
    CALL EXITS("PETSC_VECGHOSTUPDATEEND")
    RETURN 1
  END SUBROUTINE PETSC_VECGHOSTUPDATEEND
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecRestoreArray routine.
  SUBROUTINE PETSC_VECRESTOREARRAY(X,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to restore the array of
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECRESTOREARRAY",ERR,ERROR,*999)

    CALL VecRestoreArray(X%VEC,X%VEC_DATA,X%VEC_OFFSET,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecRestoreArray",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECRESTOREARRAY")
    RETURN
999 CALL ERRORS("PETSC_VECRESTOREARRAY",ERR,ERROR)
    CALL EXITS("PETSC_VECRESTOREARRAY")
    RETURN 1
  END SUBROUTINE PETSC_VECRESTOREARRAY
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecRestoreArrayF90 routine.
  SUBROUTINE PETSC_VECRESTOREARRAYF90(X,ARRAY,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to restore the array of
    REAL(DP), POINTER :: ARRAY(:) !<A pointer to the data to restore
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECRESTOREARRAYF90",ERR,ERROR,*999)

    CALL VecRestoreArrayF90(X%VEC,ARRAY,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecRestoreArrayF90",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECRESTOREARRAYF90")
    RETURN
999 CALL ERRORS("PETSC_VECRESTOREARRAYF90",ERR,ERROR)
    CALL EXITS("PETSC_VECRESTOREARRAYF90")
    RETURN 1
  END SUBROUTINE PETSC_VECRESTOREARRAYF90
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecSet routine.
  SUBROUTINE PETSC_VECSET(X,VALUE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to set the value of
    REAL(DP), INTENT(IN) :: VALUE !<The value to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECSET",ERR,ERROR,*999)

    CALL VecSet(X%VEC,VALUE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecSet",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECSET")
    RETURN
999 CALL ERRORS("PETSC_VECSET",ERR,ERROR)
    CALL EXITS("PETSC_VECSET")
    RETURN 1
  END SUBROUTINE PETSC_VECSET
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecSetFromOptions routine.
  SUBROUTINE PETSC_VECSETFROMOPTIONS(X,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to set the options for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECSETFROMOPTIONS",ERR,ERROR,*999)

    CALL VecSetFromOptions(X%VEC,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecSetFromOptions",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECSETFROMOPTIONS")
    RETURN
999 CALL ERRORS("PETSC_VECSETFROMOPTIONS",ERR,ERROR)
    CALL EXITS("PETSC_VECSETFROMOPTIONS")
    RETURN 1
  END SUBROUTINE PETSC_VECSETFROMOPTIONS
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecSetLocalToGlobalMapping routine.
  SUBROUTINE PETSC_VECSETLOCALTOGLOBALMAPPING(X,CTX,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to set the local to global mapping for
    TYPE(PETSC_ISLOCALTOGLOBALMAPPING_TYPE), INTENT(IN) :: CTX !<The local to global mapping context
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECSETLOCALTOGLOBALMAPPING",ERR,ERROR,*999)

    CALL VecSetLocalToGlobalMapping(X%VEC,CTX%ISLOCALTOGLOBALMAPPING,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecSetLocalToGlobalMapping",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECSETLOCALTOGLOBALMAPPING")
    RETURN
999 CALL ERRORS("PETSC_VECSETLOCALTOGLOBALMAPPING",ERR,ERROR)
    CALL EXITS("PETSC_VECSETLOCALTOGLOBALMAPPING")
    RETURN 1
  END SUBROUTINE PETSC_VECSETLOCALTOGLOBALMAPPING
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecSetValues routine.
  SUBROUTINE PETSC_VECSETVALUES(X,N,INDICES,VALUES,INSERT_MODE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to set the values for
    INTEGER(INTG), INTENT(IN) :: N !<The number of indicies
    INTEGER(INTG), INTENT(IN) :: INDICES(*) !<The indices
    REAL(DP), INTENT(IN) :: VALUES(*) !<The values to set
    InsertMode, INTENT(IN) :: INSERT_MODE !<The insert mode
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECSETVALUES",ERR,ERROR,*999)

    CALL VecSetValues(X%VEC,N,INDICES,VALUES,INSERT_MODE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecSetValues",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECSETVALUES")
    RETURN
999 CALL ERRORS("PETSC_VECSETVALUES",ERR,ERROR)
    CALL EXITS("PETSC_VECSETVALUES")
    RETURN 1
  END SUBROUTINE PETSC_VECSETVALUES
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecSetValuesLocal routine.
  SUBROUTINE PETSC_VECSETVALUESLOCAL(X,N,INDICES,VALUES,INSERT_MODE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to set the values of
    INTEGER(INTG), INTENT(IN) :: N !<The number of indices
    INTEGER(INTG), INTENT(IN) :: INDICES(*) !<The local indices
    REAL(DP), INTENT(IN) :: VALUES(*) !<The values to set
    InsertMode :: INSERT_MODE !<The insert mode
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECSETVALUESLOCAL",ERR,ERROR,*999)

    CALL VecSetValuesLocal(X%VEC,N,INDICES,VALUES,INSERT_MODE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecSetValuesLocal",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECSETVALUESLOCAL")
    RETURN
999 CALL ERRORS("PETSC_VECSETVALUESLOCAL",ERR,ERROR)
    CALL EXITS("PETSC_VECSETVALUESLOCAL")
    RETURN 1
  END SUBROUTINE PETSC_VECSETVALUESLOCAL
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecSetSizes routine.
  SUBROUTINE PETSC_VECSETSIZES(X,LOCAL_SIZE,GLOBAL_SIZE,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to set the sizes of
    INTEGER(INTG), INTENT(IN) :: LOCAL_SIZE !<The number of local elements
    INTEGER(INTG), INTENT(IN) :: GLOBAL_SIZE !<The number of global elements
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECSETSIZES",ERR,ERROR,*999)

    CALL VecSetSizes(X%VEC,LOCAL_SIZE,GLOBAL_SIZE,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecSetSizes",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECSETSIZES")
    RETURN
999 CALL ERRORS("PETSC_VECSETSIZES",ERR,ERROR)
    CALL EXITS("PETSC_VECSETSIZES")
    RETURN 1
  END SUBROUTINE PETSC_VECSETSIZES
    
  !
  !================================================================================================================================
  !

  !>Buffer routine to the PETSc VecView routine.
  SUBROUTINE PETSC_VECVIEW(X,V,ERR,ERROR,*)

    !Argument Variables
    TYPE(PETSC_VEC_TYPE), INTENT(INOUT) :: X !<The vector to view
    PetscViewer, INTENT(IN) :: V !<The viewer
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("PETSC_VECVIEW",ERR,ERROR,*999)

    CALL VecView(X%VEC,V,ERR)
    IF(ERR/=0) THEN
      IF(PETSC_HANDLE_ERROR) THEN
        CHKERRQ(ERR)
      ENDIF
      CALL FLAG_ERROR("PETSc error in VecView",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("PETSC_VECVIEW")
    RETURN
999 CALL ERRORS("PETSC_VECVIEW",ERR,ERROR)
    CALL EXITS("PETSC_VECVIEW")
    RETURN 1
  END SUBROUTINE PETSC_VECVIEW
    
  !
  !================================================================================================================================
  !

END MODULE CMISS_PETSC
    