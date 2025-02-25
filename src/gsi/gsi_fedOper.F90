module gsi_fedOper
!$$$  subprogram documentation block
!                .      .    .                                       .
! subprogram:	 module gsi_fedOper
!
! abstract: an obOper extension for fedNode type
!
! program history log:
!   2023-07-10  D. Dowell - created new module for FED (flash extent
!                           density); gsi_dbzOper.F90 code used as a
!                           starting point for developing this new module
!
!   input argument list: see Fortran 90 style document below
!
!   output argument list: see Fortran 90 style document below
!
! attributes:
!   language: Fortran 90 and/or above
!   machine:
!
!$$$  end subprogram documentation block

! module interface:

  use gsi_obOper, only: obOper
  use m_fedNode , only: fedNode
  implicit none
  public:: fedOper      ! data structure
  public:: diag_fed

  type,extends(obOper):: fedOper
  contains
    procedure,nopass:: mytype
    procedure,nopass:: nodeMold
    procedure:: setup_
    procedure:: intjo1_
    procedure:: stpjo1_
  end type fedOper

!   def diag_fed- namelist logical to compute/write (=true) FED diag files
  logical,save:: diag_fed=.false.

!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  character(len=*),parameter :: myname='gsi_fedOper'
  type(fedNode),save,target:: myNodeMold_

contains
  function mytype(nodetype)
    implicit none
    character(len=:),allocatable:: mytype
    logical,optional, intent(in):: nodetype
    mytype="[fedOper]"
    if(present(nodetype)) then
      if(nodetype) mytype=myNodeMold_%mytype()
    endif
  end function mytype

  function nodeMold()
  !> %nodeMold() returns a mold of its corresponding obsNode
    use m_obsNode, only: obsNode
    implicit none
    class(obsNode),pointer:: nodeMold
    nodeMold => myNodeMold_
  end function nodeMold

  subroutine setup_(self, lunin, mype, is, nobs, init_pass, last_pass)
    use fed_setup, only: setup
    use kinds, only: i_kind
    use gsi_obOper, only: len_obstype
    use gsi_obOper, only: len_isis

    use m_rhs  , only: awork => rhs_awork
    use m_rhs  , only: bwork => rhs_bwork
    use m_rhs  , only: iwork => i_fed

    use obsmod  , only: write_diag
    use jfunc   , only: jiter

    use mpeu_util, only: die

    use obsmod, only: dirname, ianldate

    implicit none
    class(fedOper ), intent(inout):: self
    integer(i_kind), intent(in):: lunin
    integer(i_kind), intent(in):: mype
    integer(i_kind), intent(in):: is
    integer(i_kind), intent(in):: nobs
    logical        , intent(in):: init_pass     ! supporting multi-pass setup()
    logical        , intent(in):: last_pass     ! with incremental backgrounds.

    !----------------------------------------
    character(len=*),parameter:: myname_=myname//"::setup_"

    character(len=len_obstype):: obstype
    character(len=len_isis   ):: isis
    integer(i_kind):: nreal,nchanl,ier,nele
    logical:: diagsave
    integer(i_kind):: lu_diag
    character(128):: diag_file
    character(80):: string

    if(nobs == 0) then

       if( (mype == 0) .and. init_pass ) then
          write(string,600) jiter
600       format('fed_',i2.2)
          diag_file=trim(dirname) // trim(string)
          write(6,*) 'write ianldate to ', diag_file
          open(newunit=lu_diag,file=trim(diag_file),form='unformatted',status='unknown',position='rewind')
          write(lu_diag) ianldate
          close(lu_diag)
       endif

       return

    endif

    read(lunin,iostat=ier) obstype,isis,nreal,nchanl
    if(ier/=0) call die(myname_,'read(obstype,...), iostat =',ier)
    nele = nreal+nchanl

    diagsave  = write_diag(jiter) .and. diag_fed

    call setup(self%obsLL(:), self%odiagLL(:), &
        lunin,mype,bwork,awork(:,iwork),nele,nobs,is,diagsave,init_pass)

  end subroutine setup_

  subroutine intjo1_(self, ibin, rval,sval, qpred,sbias)
    use gsi_bundlemod  , only: gsi_bundle
    use bias_predictors, only: predictors
    use m_obsNode , only: obsNode
    use m_obsLList, only: obsLList_headNode
    use kinds     , only: i_kind, r_quad
    implicit none
    class(fedOper  ),intent(in   ):: self
    integer(i_kind ),intent(in   ):: ibin
    type(gsi_bundle),intent(inout):: rval   ! (ibin)
    type(gsi_bundle),intent(in   ):: sval   ! (ibin)
    real(r_quad    ),target,dimension(:),intent(inout):: qpred  ! (ibin)
    type(predictors),target,             intent(in   ):: sbias

    !----------------------------------------
    character(len=*),parameter:: myname_=myname//"::intjo1_"
    class(obsNode),pointer:: headNode

  end subroutine intjo1_

  subroutine stpjo1_(self, ibin, dval,xval,pbcjo,sges,nstep,dbias,xbias)
    use gsi_bundlemod, only: gsi_bundle
    use bias_predictors, only: predictors
    use m_obsNode , only: obsNode
    use m_obsLList, only: obsLList_headNode
    use kinds, only: r_quad,r_kind,i_kind
    implicit none
    class(fedOper  ),intent(in):: self
    integer(i_kind ),intent(in):: ibin
    type(gsi_bundle),intent(in):: dval
    type(gsi_bundle),intent(in):: xval
    real(r_quad    ),dimension(:),intent(inout):: pbcjo ! (1:4)
    real(r_kind    ),dimension(:),intent(in   ):: sges
    integer(i_kind),intent(in):: nstep

    type(predictors),target, intent(in):: dbias
    type(predictors),target, intent(in):: xbias

    !----------------------------------------
    character(len=*),parameter:: myname_=myname//"::stpjo1_"
    class(obsNode),pointer:: headNode

  end subroutine stpjo1_

end module gsi_fedOper
