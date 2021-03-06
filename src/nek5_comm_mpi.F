c----------------------------------------------------------------------
      subroutine iniproc
      include 'SIZE'
      include 'PARALLEL'
      include 'mpif.h'

      common /nekmpi/ nid_,np_,nekcomm,nekgroup,nekreal

      logical flag
      integer required, provided, ierr
      integer flag_gs_init

      call mpi_initialized(mpi_is_initialized, ierr) !  Initialize MPI
      if ( mpi_is_initialized .eq. 0 ) then
c        call MPI_INIT_THREAD(MPI_THREAD_MULTIPLE, provided, ierr)
         call mpi_init (ierr)
      endif

c     ! create communicator
      call init_nek_comm2
      np  = np_
      nid = nid_

      if (nid.eq.0) call printHeader

c     if (nid.eq.0) write(6,10) MPI_THREAD_MULTIPLE,provided
  10   format(' MPI_thread safety check: required=',i5,', provided=',i5)
      ! check upper tag size limit
      call mpi_attr_get(MPI_COMM_WORLD,MPI_TAG_UB,nval,flag,ierr)

      if (nval.lt.(10000+max(lp,lelg))) then
         if(nid.eq.0) write(6,*) 'ABORT: MPI_TAG_UB too small!'
         call exitt(1)
      endif

      IF (NP.GT.LP) THEN
         WRITE(6,*)
     $   'ERROR: Code compiled for a max of',LP,' processors.'
         WRITE(6,*)
     $   'Recompile with LP =',NP,' or run with fewer processors.'
         WRITE(6,*)
     $   'Aborting in routine INIPROC.'
         call exitt(1)
      endif
      ! set word size for REAL
      wdsize = 4
      eps    = 1.0e-12
      oneeps = 1.0+eps

      if (oneeps.ne.1.0) then
         wdsize=8
      else
         if(nid.eq.0)
     &     write(6,*) 'ABORT: single precision mode not supported!'
         call exitt(1)
      endif
      nekreal = mpi_real
      if (wdsize.eq.8) nekreal = mpi_double_precision

      ifdblas = .false.
      if (wdsize.eq.8) ifdblas = .true.

      ! set word size for INTEGER
      ! HARDCODED since there is no secure way to detect an int overflow
      isize = 4

      ! set word size for LOGICAL
      lsize = 4

      ! set word size for CHARACTER
      csize = 1
c
      PID = 0
      NULLPID=0
      NODE0=0
      NODE= NID+1

      if (nid.eq.0) then
         write(6,*) 'Number of processors:',np
         WRITE(6,*) 'REAL    wdsize      :',WDSIZE
         WRITE(6,*) 'INTEGER wdsize      :',ISIZE
      endif
      call crystal_setup(cr_h,nekcomm,np)  ! set cr handle to new instance

      return
      end
c-----------------------------------------------------------------------
      subroutine create_comm(icomm)
      include 'mpif.h'

c     mpi_comm_world: communicator (handle)
c     itmp: subset of the group of  mpi_comm_world (handle)
c     icomm: new communicator (handle)
      call mpi_comm_group (mpi_comm_world,itmp,ierr)
      call mpi_comm_create (mpi_comm_world,itmp,icomm,ierr)
      call mpi_group_free (itmp,ierr)

      return
      end
c-----------------------------------------------------------------------
      subroutine init_nek_comm2
      include 'mpif.h'
      common /nekmpi/ nid_,np_,nekcomm,nekgroup,nekreal
C
      call create_comm(nekcomm) ! set up nekton specific communicator
c
      nid_  = mynode()
      np_   = numnodes()
c
      return
      end
c-----------------------------------------------------------------------
      subroutine init_nek_comm(nido,npo,wdsize)
      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
      integer wdsize
C
      call nek_comm            ! set up nekton specific communicator
c
      nid  = mynode()
      np   = numnodes()
      nido = nid
      npo  = np
c
      wdsize=4
      eps=1.0e-12
      oneeps = 1.0+eps
      if (oneeps.ne.1.0) wdsize=8
      nekreal = mpi_real
      if (wdsize.eq.8) nekreal = mpi_double_precision
c
      return
      end
c-----------------------------------------------------------------------
      subroutine gop( x, w, op, n)
c
c     Global vector commutative operation using spanning tree.
c
      INCLUDE 'CTIMER'
c
      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
c
      real x(n), w(n)
      character*3 op
c
      if (icalld.eq.0) then
        tgop =0.0d0
        ngop =0
        icalld=1
      endif
      ngop = ngop + 1
      etime1=dclock()
c
      if (op.eq.'+  ') then
c        call mpi_allreduce_(x,w,n,nekreal,mpi_sum ,nekcomm,ierr)
         call mpi_allreduce (x,w,n,nekreal,mpi_sum ,nekcomm,ierr)
      elseif (op.EQ.'M  ') then
c        call mpi_allreduce_(x,w,n,nekreal,mpi_max ,nekcomm,ierr)
         call mpi_allreduce (x,w,n,nekreal,mpi_max ,nekcomm,ierr)
      elseif (op.EQ.'m  ') then
c        call mpi_allreduce_(x,w,n,nekreal,mpi_min ,nekcomm,ierr)
         call mpi_allreduce (x,w,n,nekreal,mpi_min ,nekcomm,ierr)
      elseif (op.EQ.'*  ') then
c        call mpi_allreduce_(x,w,n,nekreal,mpi_prod,nekcomm,ierr)
         call mpi_allreduce (x,w,n,nekreal,mpi_prod,nekcomm,ierr)
      else
         write(6,*) nid,' OP ',op,' not supported.  ABORT in GOP.'
         call exitt(1)
      endif
c
      call copy(x,w,n)
c
      tgop =tgop +(dclock()-etime1)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine igop(x,w,op,n)
c-----------------------------------------------------------------------
c     Global vector commutative operation using spanning tree.
      implicit none
      include 'mpif.h'

      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
      integer nid,np,nekcomm,nekgroup,nekreal

      integer x(n),w(n)
      integer n
      character*3 op

      integer ierr

      if (op.eq.'+  ') then
        call mpi_allreduce(x,w,n,mpi_integer,mpi_sum,nekcomm,ierr)
      elseif (op.eq.'M  ') then
        call mpi_allreduce(x,w,n,mpi_integer,mpi_max,nekcomm,ierr)
      elseif (op.eq.'m  ') then
        call mpi_allreduce(x,w,n,mpi_integer,mpi_min,nekcomm,ierr)
      elseif (op.eq.'*  ') then
        call mpi_allreduce(x,w,n,mpi_integer,mpi_prod,nekcomm,ierr)
      else
         write(6,*) nid,' OP ',op,' not supported. ABORT in GOP.'
        call exitt(1)
      endif

      call icopy(x,w,n)

      return
      end
c-----------------------------------------------------------------------
      subroutine csend(mtype,buf,len,jnid,jpid)
      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
      real   buf(1)
c     call mpi_send_(buf,len,mpi_byte,jnid,mtype,nekcomm,ierr)
      call mpi_send (buf,len,mpi_byte,jnid,mtype,nekcomm,ierr)
      return
      END
c-----------------------------------------------------------------------
      subroutine crecv(   mtype, buf ,lenm )
      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
      integer status(mpi_status_size)
C
      real   buf(1)
      len = lenm
      jnid = mpi_any_source

      call mpi_recv (buf,len,mpi_byte
     $            ,jnid,mtype,nekcomm,status,ierr)
c
      if (len.gt.lenm)
     $    write(6,*) nid,'long message in mpi_crecv:',len,lenm
c
      return
      END
c-----------------------------------------------------------------------
      integer function numnodes()
      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
c     call mpi_comm_size_(nekcomm, numnodes , ierr)
      call mpi_comm_size (nekcomm, numnodes , ierr)
      return
      end
c-----------------------------------------------------------------------
      integer function mynode()
      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
      integer myid
c     call mpi_comm_rank_(nekcomm, myid, ierr)
      call mpi_comm_rank (nekcomm, myid, ierr)
      mynode = myid
      return
      end
c-----------------------------------------------------------------------
      real*8 function dclock()
      include 'mpif.h'
c
      real   etime,q(2)
      save q
      data q /0.,0./
c
c     dclock=mpi_wtime_()
      dclock=mpi_wtime ()
c     dclock=etime(q)    ! for alpha
c
      return
      end
c-----------------------------------------------------------------------
      SUBROUTINE LBCAST(IFIF)
C
C  Broadcast logical variable to all processors.
C
      INCLUDE 'SIZE'
      INCLUDE 'PARALLEL'
      INCLUDE 'mpif.h'

      LOGICAL IFIF
C
      IF (NP.EQ.1) RETURN
C
      ITEM=0
      IF (IFIF) ITEM=1
      call bcast(item,isize)
      IFIF=.FALSE.
      IF (ITEM.EQ.1) IFIF=.TRUE.
      RETURN
      END

c-----------------------------------------------------------------------
      subroutine bcast(buf,len)
c-----------------------------------------------------------------------
      include 'mpif.h'

      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
      real buf(len)

      call mpi_bcast(buf,len,mpi_byte,0,nekcomm,ierr)
      return
      end
c-----------------------------------------------------------------------
      subroutine nek_comm
      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
c     call mpi_comm_group_(mpi_comm_world,nekgroup,ierr)
c     call mpi_comm_create_(mpi_comm_world,nekgroup,nekcomm,ierr)
c     call mpi_group_free_(nekgroup,ierr)
      call mpi_comm_group (mpi_comm_world,nekgroup,ierr)
      call mpi_comm_create (mpi_comm_world,nekgroup,nekcomm,ierr)
      call mpi_group_free (nekgroup,ierr)
      return
      end
c-----------------------------------------------------------------------
      function isend(msgtag,x,len,jnid,jpid)
c
c     Note: len in bytes
c
      integer x(len)
C
      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
C
c     call mpi_isend_(x,len,mpi_byte,jnid,msgtag
c    $       ,nekcomm,imsg,ierr)
      call mpi_isend (x,len,mpi_byte,jnid,msgtag
     $       ,nekcomm,imsg,ierr)
      isend = imsg
c     write(6,*) nid,' isend:',imsg,msgtag,len,jnid,(x(k),k=1,len/4)
c
      return
      end
c-----------------------------------------------------------------------
      function irecv(msgtag,x,len)
c
c     Note: len in bytes
c
      integer x(len)
C
      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
C
c     call mpi_irecv_(x,len,mpi_byte,mpi_any_source,msgtag
c    $       ,nekcomm,imsg,ierr)
      call mpi_irecv (x,len,mpi_byte,mpi_any_source,msgtag
     $       ,nekcomm,imsg,ierr)
      irecv = imsg
c     write(6,*) nid,' irecv:',imsg,msgtag,len
c
      return
      end
c-----------------------------------------------------------------------
      subroutine msgwait(imsg)
c
      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
      integer status(mpi_status_size)
c
c     write(6,*) nid,' msgwait:',imsg
c
c     call mpi_wait_(imsg,status,ierr)
      call mpi_wait (imsg,status,ierr)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine close_unit(io)
      close (unit=io)
      return
      end
c-----------------------------------------------------------------------
      subroutine exitti(stringi,idata,irc)
      character*1 stringi(132)
      character*1 stringo(132)
      character*11 s11
      include 'SIZE'
      include 'TOTAL'
      include 'CTIMER'

      call blank(stringo,132)
      call chcopy(stringo,stringi,132)
      len = indx1(stringo,'$',1)
      write(s11,11) idata
   11 format(1x,i10)
      call chcopy(stringo(len),s11,11)

      if (nid.eq.0) write(6,1) (stringo(k),k=1,len+10)
    1 format('EXIT: ',132a1)

      call exitt(irc)

      return
      end
c-----------------------------------------------------------------------
      subroutine exitt(rc)
c-----------------------------------------------------------------------
      implicit none
      include 'SIZE'
      include 'TOTAL'
      include 'CTIMER'
      include 'mpif.h'

      integer rc

      integer ierr,tmp(1),irc
      integer iglmax
      real tstop,dnekclock
      real papi_flops,papi_mflops,dtmp1,dtmp2,dgp

c     Make the return code the maximum of the return codes
      tmp(1) = rc
      irc = iglmax(tmp,1)

c     Communicate unhappiness to the other session
      call nekgsync

#ifdef PAPI
      call nek_flops(papi_flops,papi_mflops)
#endif

      tstop = dnekclock()
      ttotal = tstop-etimes
      nxyz = nx1*ny1*nz1

      if (nid.eq.0) then
         dtmp1 = 0
         dtmp2 = 0
         if(istep.gt.0) then
            dgp = nvtot
            dgp = max(dgp,1.0)
            dtmp1 = np*ttime/(dgp*max(istep,1))
            dtmp2 = ttime/max(istep,1)
         endif
         write(6,*) ' '
         write(6,'(A)') 'call exitt: dying ...'
         write(6,*) ' '
      endif

      call flush_io
      call mpi_finalize(ierr)
      call exit(irc)

      return
      end
c-----------------------------------------------------------------------
      subroutine printHeader

      INCLUDE 'HEADER'

      return
      end
c-----------------------------------------------------------------------
      integer function igl_running_sum(in)
      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal
      integer status(mpi_status_size)
      integer x,w,r

      x = in  ! running sum
      w = in  ! working buff
      r = 0   ! recv buff

      call mpi_scan(x,r,1,mpi_integer,mpi_sum,nekcomm,ierr)
      igl_running_sum = r

      return
      end
c-----------------------------------------------------------------------
      subroutine nekgsync()

      include 'mpif.h'
      common /nekmpi/ nid,np,nekcomm,nekgroup,nekreal

      call mpi_barrier(nekcomm,ierr)

      return
      end

c-----------------------------------------------------------------------
      real*8 function dnekclock()
      include 'mpif.h'
c
      dnekclock=mpi_wtime()
c
      return
      end
c-----------------------------------------------------------------------
      real*8 function dnekclock_sync()
      include 'mpif.h'
c
      call nekgsync()
      dnekclock_sync=mpi_wtime()
c
      return
      end

c-----------------------------------------------------------------------
      subroutine nek_flops(flops,mflops)
      real*4 rtime,ptime,mflops
      integer*8 flops

      call getflops_papi(flops,mflops)

      return
      end

c-----------------------------------------------------------------------
      subroutine getflops_papi(flops,mflops)
#ifdef PAPI
      include 'f77papi.h'
      real*4 rtime,ptime,mflops
      integer*8 flops

      call papif_flops(rtime,ptime,flops,mflops,ierr)
      if(ierr.gt.0) then
        flops = -1
        mflops = -1
      endif
#endif

      return
      end
c-----------------------------------------------------------------------
