C----------------------------------------------------------------------
      subroutine cem_out_fields2(dumpno)
C----------------------------------------------------------------------
c     implicit none
      include 'SIZE'
      include 'TOTAL'
      include 'EMWAVE'
      include 'EXPONE'
      include 'SCHROD'
      include 'DRIFT'
      include 'POISSON'

      integer    fnum, dumpno
      parameter (fnum=111)
      logical    outex, outey, outez, outhx, outhy, outhz
      integer    n, io_option

      character*33 filename
      data         filename /'./vtk/ascii-NN-p000000-t00000.vtk'/
      CHARACTER*1  fnarray(33)
      equivalence  (filename,fnarray)

      integer   icalld
      save      icalld
      data      icalld /0/

      character*1  numrl(0:9)
      data numrl /'0','1','2','3','4','5','6','7','8','9'/

      fnarray(29)= numrl(mod(dumpno,10))
      fnarray(28)= numrl(mod(dumpno,100)/10)
      fnarray(27)= numrl(mod(dumpno,1000)/100)
      fnarray(26)= numrl(mod(dumpno,10000)/1000)
      fnarray(25)= numrl(mod(dumpno,100000)/10000)

      fnarray(22)= numrl(mod(nid,10))
      fnarray(21)= numrl(mod(nid,100)/10)
      fnarray(20)= numrl(mod(nid,1000)/100)
      fnarray(19)= numrl(mod(nid,10000)/1000)
      fnarray(18)= numrl(mod(nid,100000)/10000)
      fnarray(17)= numrl(mod(nid,1000000)/100000)

      n = nx1*ny1*nz1*nelt

c ... VTK FORMAT: ASCII

      open(fnum, file=filename)
      call vtk_dump_header2(fnum)

      call vtk_dump_field2(fnum,'H     ',hx,hy,hz,istep,time)
      call vtk_dump_field2(fnum,'E     ',ex,ey,ez,istep,time)

      call vtk_dump_field2
     $              (fnum,'region',faceif,faceif,faceif,istep,time)!51 region
      call vtk_dump_field2
     $              (fnum,'face  ',faceid,faceid,faceid,istep,time)!52 face line

      if (ifsol) then

         call sub3(errhx, hx, shx, n)
         call sub3(errhy, hy, shy, n)
         call sub3(errhz, hz, shz, n)
         call sub3(errex, ex, sex, n)
         call sub3(errey, ey, sey, n)
         call sub3(errez, ez, sez, n)

       call vtk_dump_field2(fnum,'errH  ',errhx,errhy,errhz,istep,time)
       call vtk_dump_field2(fnum,'errE  ',errex,errey,errez,istep,time)
       call vtk_dump_field2(fnum,'solH  ',shx,shy,shz,istep,time)
       call vtk_dump_field2(fnum,'solE  ',sex,sey,sez,istep,time)

      endif

      close(fnum)

      if(nid.eq.0) call pvtk_xml2(dumpno)

      return
      end

C----------------------------------------------------------------------
      subroutine cem_out_fields(dumpno)
C----------------------------------------------------------------------
      implicit none
      include 'SIZE'
      include 'TOTAL'
      include 'EMWAVE'
      include 'EXPONE'
      include 'SCHROD'
      include 'DRIFT'
      include 'POISSON'

      logical outex, outey, outez, outhx, outhy, outhz
      integer n,dumpno
      integer icalld
      save    icalld
      data    icalld /0/
      integer io_option

      ifxyo=.true.
      if (istep.gt.iostep) ifxyo = .false.  ! dump geom for 1st file only
      ifvo  = .true.
      ifpo  = .false.
      ifto  = .false.

      n = nx1*ny1*nz1*nelt

c$$$      if (nsteps.eq.0) then
c$$$         call outpost(hx,hy,hz,pr,hx,'hxy')
c$$$         call outpost(ex,ey,ez,pr,ey,'exy')
c$$$         return
c$$$      endif
c$$$      if (ifsol) then
c$$$         call outpost(hx,hy,hz,pr,hx,'hxy')
c$$$         call outpost(ex,ey,ez,pr,ey,'exy')
c$$$      else
c$$$         if (ifscat) then
c$$$            call outpost(tothx,tothy,tothz,pr,hx,'h-t')
c$$$            call outpost(totex,totey,totez,pr,ey,'e-t')
c$$$            call outpost(hx,hy,hz,pr,hx,'hxy')
c$$$            call outpost(ex,ey,ez,pr,ey,'exy')
c$$$            call outpost(engyh,engyh,engyh,pr,ey,'enh')
c$$$            call outpost(engye,engye,engye,pr,ex,'ene')
c$$$         else
c$$$            call outpost(hx,hy,hz,pr,hx,'hxy')
c$$$            call outpost(ex,ey,ez,pr,ey,'exy')
c$$$         endif
c$$$      endif

      return
      end
C----------------------------------------------------------------------
      subroutine cem_out
C----------------------------------------------------------------------
#ifdef MPIIO
#ifndef  NO_IO
      implicit none
      include 'SIZE'
      include 'TOTAL'
      include 'EMWAVE'
      include 'SCHROD'
      include 'DRIFT'
      include 'POISSON'
      include 'PML'
      include 'RTIMER'

      common  /outvtk/vtkout1(3*lx1*ly1*lz1*lelt)
     $               ,vtkout2(3*lx1*ly1*lz1*lelt)
     $               ,vtkout3(3*lx1*ly1*lz1*lelt)
     $               ,vtkout4(3*lx1*ly1*lz1*lelt)
      real    vtkout1,vtkout2,vtkout3,vtkout4

      integer iooption,numfiles,irestart,idouble
      save    iooption,numfiles,irestart,idouble
      integer icomptrace,iotrace
      save    icomptrace,iotrace
      integer iparam1,iparam2,iparam3,iparam4,iparam5,iparam6,iparam7

      integer icalld
      save    icalld
      data    icalld/0/
      real*8  dclock,pretime,endtime
      integer i99
      integer nxyzl3

c...  dumpno for restarting case comes from previous step
      if (icalld.eq.0) then
         cpu_t_io= 0.0

         if (nid.eq.0) then
             iparam1=param(81)
             iparam2=param(82)
             iparam3=param(83)      !io-frequency for restart files
             iparam4=0              !restart dumpno
             iparam5=param(85)      !write compute trace                  
             iparam6=param(86)      !write io trace                       
             iparam7=param(87)      !write io trace                       
         else
             iparam1=0
             iparam2=0
             iparam3=0              !io-frequency for restart files
             iparam4=0
             iparam5=0              !write compute trace                  
             iparam6=0              !write io trace                       
             iparam7=0              !write io trace                       
         endif
         if (ifrestart) then
            if (nid.eq.0) then
             iparam4= param(84)+1   !restart dumpno update
            else
             iparam4= 0
            endif
         endif
c...     iglsum is not doing smart bcast'ing, revert back to bcast -- jingfu
         call bcast(iparam1,isize)
         call bcast(iparam2,isize)
         call bcast(iparam3,isize)
         call bcast(iparam4,isize)
         call bcast(iparam5,isize)
         call bcast(iparam6,isize)
         call bcast(iparam7,isize)

         iooption    =iparam1
         numfiles    =iparam2
         irestart    =iparam3
         dumpno      =iparam4
         icomptrace  =iparam5
         iotrace     =iparam6
         idouble     =iparam7

         IFDOUBLE=.true.
         if (idouble.ne.0) IFDOUBLE=.false.
         if (nid.eq.0) write(6,*) 'IFDOUBLE=',IFDOUBLE
         if (nid.eq.0) write(6,*) 'param(81)=',iparam1
         if (nid.eq.0) write(6,*) 'param(82)=',iparam2
         if (nid.eq.0) write(6,*) 'param(83)=',irestart
         if (nid.eq.0) write(6,*) 'dumpno   =',dumpno

         icalld  = 1
         call pass_io_params(iooption,numfiles,ndim,mesh)
      endif

c...  param(85) decide if compute trace should be generated
      if (icomptrace.gt.0) call writecomputetrace(istep,cpu_dtime,cpu_t)

c...  no output/restart files will be generated
      if (iooption.eq.0) return

c...  this produces output for (io-option=iparam) with timing info
      if (iostep.gt.0) then

      if ((mod(istep,iostep).eq.0).or.(istep.eq.nsteps)) then

         if (istep.gt.0) then

#ifdef _OPENACC
!$ACC UPDATE HOST(HN,EN)   ! ACC data copy from GPU--> CPU
#endif
         endif

#if defined SCHROD
         call vtk_nonswap_field( Ur, Ui, Ui,vtkout1)
         call vtk_nonswap_field( Qr(1,1),Qr(1,2),Qr(1,3),vtkout2)
         call vtk_nonswap_field( Qi(1,1),Qi(1,2),Qi(1,3),vtkout3)
         call vtk_nonswap_field( sUr,sQr(1,1),sQi(1,1),vtkout4)
#elif defined DRIFT
         nxyzl3 = nx1*ny1*nz1*nelt*3
         call sub3(wJ,cnj,cpj,nxyzl3)
         call vtk_nonswap_field( cN, cP, potent,vtkout1)
         call vtk_nonswap_field(wJ(1,1),wJ(1,2),wJ(1,3),vtkout2)
         call vtk_nonswap_field(cnj(1,1),cnj(1,2),cnj(1,3),vtkout3)
         call vtk_nonswap_field(cpj(1,1),cpj(1,2),cpj(1,3),vtkout4)
#elif defined MAXWELL
         call vtk_nonswap_field(EN(1,1),EN(1,2),EN(1,3),vtkout1)
         call vtk_nonswap_field(HN(1,1),HN(1,2),HN(1,3),vtkout2)
         call vtk_nonswap_field(sEN(1,1),sEN(1,2),sEN(1,3),vtkout3)
         call vtk_nonswap_field(sHN(1,1),sHN(1,2),sHN(1,3),vtkout4)
#else
#error "Invalid application"
#endif

         pretime = dclock()
         call starttiming
         call checkpoint_write(iooption,dumpno)

c...     maybe need a thread_join function to ensure the last io step finished
         call endtiming
         endtime = dclock()-pretime
         cpu_t_io= cpu_t_io+endtime

         call printio(iooption,istep)

c...  produce restart files
         if (irestart.gt.0) then !io-frequency for restart files >= nonzero

          if (mod(istep,irestart*iostep).eq.0) then

#ifdef NO_MPI
           write(6,*) 'non-mpi run: no restart file produced'
#else
           swaptime=dclock()

#if defined SCHROD
           call vtk_swap_field( Ur, Ui, Ui,vtkout1)
           call vtk_swap_field( Qr(1,1),Qr(1,2),Qr(1,3),vtkout2)
           call vtk_swap_field( Qi(1,1),Qi(1,2),Qi(1,3),vtkout3)
           call vtk_swap_field( sUr,sQr(1,1),sQi(1,1),vtkout4)
#elif defined DRIFT
           call vtk_swap_field( cN, cP, potent,vtkout1)
#elif defined MAXWELL
           call vtk_swap_field(EN(1,1),EN(1,2),EN(1,3),vtkout1)
           call vtk_swap_field(HN(1,1),HN(1,2),HN(1,3),vtkout2)
           call vtk_swap_field(sEN(1,1),sEN(1,2),sEN(1,3),vtkout3)
           call vtk_swap_field(sHN(1,1),sHN(1,2),sHN(1,3),vtkout4)
#else
#error "Invalid application"
#endif

           swaptime=dclock()-swaptime
           swaptime=swaptime/4.0
           i99=99

          !For threading, restart frequency should be zero on BG/P: fixme -- misun/jing 3/23/2012 
          !To be tested the same case on XK6: not likely to cause the same situation.                      
           if (nid.eq.0) write(6,3) dumpno,irestart*iostep,swaptime
           call checkpoint_write(i99,dumpno)
#endif

          endif
         endif
    3    format(' ---> write restart files at dumpno=',i10,
     $          ', irestart*iostep=',i10,', swaptime=',e11.4,'\n')
         dumpno = dumpno + 1

      endif
      endif
#endif
#endif
c
      return
      end

C----------------------------------------------------------------------
      subroutine cem_out_fields6(dumpno)
#ifdef MPIIO
C----------------------------------------------------------------------
c...  this works OK with param(81)=6,-6,5,8:
c...  this produces a single file using MPI collective write function
c...  Jing Fu 2010-07-08
      implicit none
      include 'SIZE'
      include 'TOTAL'
      include 'EMWAVE'
      include 'SCHROD'
      include 'DRIFT'
      include 'POISSON'

      integer n,dumpno
      integer maxnelt,numgroups,numfields,maxnumnodes
      save    maxnelt,numgroups,numfields,maxnumnodes

      integer icalld
      save    icalld
      data    icalld /0/

      common  ncell,ncellsize,ncelltype
      integer ncell,ncellsize,ncelltype

      common /c_rvtk/ vtkxyz(3*lx1*ly1*lz1*lelt)
      real            vtkxyz
      common /c_ivtk/ fpcnt (8*lx1*ly1*lz1*lelt)
      integer         fpcnt
      common /outvtk/ vtkout1(3*lx1*ly1*lz1*lelt)
     $               ,vtkout2(3*lx1*ly1*lz1*lelt)
     $               ,vtkout3(3*lx1*ly1*lz1*lelt)
     $               ,vtkout4(3*lx1*ly1*lz1*lelt)
      real    vtkout1,vtkout2,vtkout3,vtkout4
      integer iglmax,io_option,inumfields

      if (icalld.eq.0) then
          maxnelt = iglmax(nelt,1)
          call bcast(maxnelt,isize)
          maxnumnodes = nx1*ny1*nz1*maxnelt ! max # nodes per processor

          if (nid.eq.0) then
              numfields   = param(80)           ! this number has to be exact
              numgroups   = param(82)           ! param(82) = # groups
          endif
          call bcast(numfields,isize)
          call bcast(numgroups,isize)

          if (numgroups.gt.np) then
              if (nid.eq.0) write(6,*) 'numgroups > np, set para(82)'
              call exitt(1)
          endif

          call vtk_dump_header_nonswap()!save nodes and cells
          icalld=1
      endif


c ... VTK FORMAT BINARY
      call initrbio    (numgroups,numfields,maxnumnodes) !rbio_nekcem.c
      call openfile6   (dumpno,nid)
      call writeheader6()
      call writenodes6 (vtkxyz,npts)

      if  (ldim.eq.3) then
          call write3dcells6(fpcnt,nelt,ncell,npts)
      else
          call write2dcells6(fpcnt,nelt,ncell,npts)
      endif

c...  number of fields are four:
#if defined SCHROD
      call writefield6(11,vtkout1,npts)
      call writefield6(12,vtkout2,npts)
      call writefield6(13,vtkout3,npts)
      call writefield6(14,vtkout4,npts)
#elif defined DRIFT
      call writefield6(31,vtkout1,npts)
      call writefield6(32,vtkout2,npts)
      call writefield6(33,vtkout3,npts)
      call writefield6(34,vtkout4,npts)
#elif defined MAXWELL
      call writefield6(1,vtkout1,npts)
      call writefield6(2,vtkout2,npts)
      call writefield6(3,vtkout3,npts)
      call writefield6(4,vtkout4,npts)
#else
#error "Invalid application"
#endif

      inumfields=4

      if (inumfields.ne.numfields) then
          if (nid.eq.0) write(6,*) 'ERR: param(80) should be set as 4'
          call exitt(1)
      endif

      call closefile6  ()

c     call pvtk_xml(dumpno)
c     if(param(81).eq.8) then
c       if(nid.eq.0) call pvtk_nmm(dumpno)
c     elseif(param(81).eq.18) then
c       if(nid.eq.0) call pvtk_nmm(dumpno)
c     elseif(param(81).eq.5) then
c       if(nid.eq.0) call pvtk_nm(dumpno)
c     endif

#endif
      return
      end

C----------------------------------------------------------------------
      subroutine cem_restart_out(dumpno)
C----------------------------------------------------------------------
#ifdef MPIIO
c...  this works OK with param(81)=4:
c...  this produces a single file using MPI collective write function
c...  Jing Fu 2010-06-28
      implicit none
      include 'SIZE'
      include 'TOTAL'
      include 'EMWAVE'
      include 'SCHROD'
      include 'DRIFT'
      include 'POISSON'

      integer icalld
      save    icalld
      data    icalld /0/
      integer i,n,dumpno,idump

      common  ncell,ncellsize,ncelltype
      integer ncell,ncellsize,ncelltype
      common  /s_rvtk/ vtkxyz_s(3*lx1*ly1*lz1*lelt)
      real             vtkxyz_s
      common  /s_ivtk/ fpcnt_s (8*lx1*ly1*lz1*lelt)
      integer          fpcnt_s
      common  /outvtk/ vtkout1(3*lx1*ly1*lz1*lelt)
     $               , vtkout2(3*lx1*ly1*lz1*lelt)
     $               , vtkout3(3*lx1*ly1*lz1*lelt)
     $               , vtkout4(3*lx1*ly1*lz1*lelt)
      real    vtkout1,vtkout2,vtkout3,vtkout4

      if (icalld.eq.0) then
         call vtk_dump_header_swap()     !save nodes and cells
         icalld=1
      endif

      call openfile_restart (dumpno,nid) !vtkbin.c

c...  calling c-routines
      call writeheader4(istep,dumpno,nx1,np,time,dt)
      call writenodes4 (vtkxyz_s,npts)
      call writecells4 (fpcnt_s,nelt,ncell,npts)

#if defined SCHROD
      if (ifdouble) then
         call writefield4_double(11,vtkout1,npts)
         call writefield4_double(12,vtkout2,npts)
         call writefield4_double(13,vtkout3,npts)
         call writefield4_double(14,vtkout4,npts)
      else
         call writefield4(11,vtkout1,npts)
         call writefield4(12,vtkout2,npts)
         call writefield4(13,vtkout3,npts)
         call writefield4(14,vtkout4,npts)
      endif
#elif defined DRIFT
      if (ifdouble) then
         call writefield4_double(31,vtkout1,npts)
c        call writefield4_double(32,vtkout2,npts)
c        call writefield4_double(33,vtkout3,npts)
c        call writefield4_double(34,vtkout4,npts)
      else
         call writefield4(31,vtkout1,npts)
c        call writefield4(32,vtkout2,npts)
c        call writefield4(33,vtkout3,npts)
c        call writefield4(34,vtkout4,npts)
      endif
#elif defined MAXWELL
      if (ifdouble) then
         call writefield4_double(1,vtkout1,npts)
         call writefield4_double(2,vtkout2,npts)
         call writefield4_double(3,vtkout3,npts)
         call writefield4_double(4,vtkout4,npts)
      else
         call writefield4(1,vtkout1,npts)
         call writefield4(2,vtkout2,npts)
         call writefield4(3,vtkout3,npts)
         call writefield4(4,vtkout4,npts)
      endif
#else
#error "Invalid application"
#endif

      call closefile_restart ()

c     if ((nid.eq.0).and.(mod(istep,iostep).eq.0)) then
c       write(6,*) ' restart-file-write completed  ::::'
c     endif
#endif
      return
      end
C----------------------------------------------------------------------
      subroutine cem_out_fields4(dumpno)
C----------------------------------------------------------------------
c...  this works OK with param(81)=4:
c...  this produces a single file using MPI collective write function
c...  Jing Fu 2010-06-28
#ifdef MPIIO
      implicit none
      include 'SIZE'
      include 'TOTAL'
      include 'EMWAVE'
      include 'EXPONE'
      include 'SCHROD'
      include 'DRIFT'
      include 'POISSON'

      integer icalld
      save    icalld
      data    icalld /0/
      integer n,dumpno,idump

      common  ncell,ncellsize,ncelltype
      integer ncell,ncellsize,ncelltype

      common /c_rvtk/ vtkxyz (3*lx1*ly1*lz1*lelt)
      real            vtkxyz
      common /c_ivtk/ fpcnt  (8*lx1*ly1*lz1*lelt)
      integer         fpcnt
      common /outvtk/ vtkout1(3*lx1*ly1*lz1*lelt)
     $               ,vtkout2(3*lx1*ly1*lz1*lelt)
     $               ,vtkout3(3*lx1*ly1*lz1*lelt)
     $               ,vtkout4(3*lx1*ly1*lz1*lelt)
      real    vtkout1,vtkout2,vtkout3,vtkout4
      integer io_option

      if (icalld.eq.0) then
          call vtk_dump_header_nonswap() !save nodes and cells
          icalld=1
      endif

c...  calling c-routines
      call openfile4   (dumpno,nid)   ! vtkbin.c
      call writeheader4(istep,dumpno,nx1,np,time,dt)
      call writenodes4 (vtkxyz,npts)
      call writecells4 (fpcnt,nelt,ncell,npts)

#if defined SCHROD
      call writefield4(11,vtkout1,npts)
      call writefield4(12,vtkout2,npts)
      call writefield4(13,vtkout3,npts)
      call writefield4(14,vtkout4,npts)
#elif defined DRIFT
      call writefield4(31,vtkout1,npts)
      call writefield4(32,vtkout2,npts)
      call writefield4(33,vtkout3,npts)
      call writefield4(34,vtkout4,npts)
#elif defined MAXWELL
      call writefield4(1,vtkout1,npts)
      call writefield4(2,vtkout2,npts)
      call writefield4(3,vtkout3,npts)
      call writefield4(4,vtkout4,npts)
#else
#error "Invalid application"
#endif

      call closefile4()
#endif
      return
      end
C----------------------------------------------------------------------
      subroutine cem_out_fields3(dumpno)
C----------------------------------------------------------------------
#ifdef MPIIO
      implicit none
      include 'SIZE'
      include 'TOTAL'
      include 'EMWAVE'
      include 'EXPONE'
      include 'PML'
      include 'SCHROD'
      include 'DRIFT'
      include 'POISSON'

      integer icalld
      save    icalld
      data    icalld /0/
      integer n,dumpno,idump

      common  ncell,ncellsize,ncelltype
      integer ncell,ncellsize,ncelltype

      common /c_rvtk/ vtkxyz(3*lx1*ly1*lz1*lelt)
      real            vtkxyz
      common /c_ivtk/ fpcnt (8*lx1*ly1*lz1*lelt)
      integer         fpcnt
      common /outvtk/ vtkout1(3*lx1*ly1*lz1*lelt)
     $               ,vtkout2(3*lx1*ly1*lz1*lelt)
     $               ,vtkout3(3*lx1*ly1*lz1*lelt)
     $               ,vtkout4(3*lx1*ly1*lz1*lelt)

      real    vtkout1,vtkout2,vtkout3,vtkout4
      integer io_option

      if (icalld.eq.0) then
          call vtk_dump_header_nonswap() !save nodes and cells
          icalld=1
      endif

c...  calling c-routines
      call openfile   (dumpno,nid)     ! vtkbin.c
      call writeheader()
      call writenodes (vtkxyz,npts)
      if (ldim.eq.3) then
          call write3dcells(fpcnt,nelt,ncell,npts)
      else
          call write2dcells(fpcnt,nelt,ncell,npts)
      endif

#if defined SCHROD
      call writefield (11,vtkout1,npts)
      call writefield (12,vtkout2,npts)
      call writefield (13,vtkout3,npts)
      call writefield (14,vtkout4,npts)
#elif defined DRIFT
      call writefield (31,vtkout1,npts)
      call writefield (32,vtkout2,npts)
      call writefield (33,vtkout3,npts)
      call writefield (34,vtkout4,npts)
#elif defined MAXWELL
      call writefield (1,vtkout1,npts)
      call writefield (2,vtkout2,npts)
      call writefield (3,vtkout3,npts)
      call writefield (4,vtkout4,npts)
#else
#error "Invalid application"
#endif

      call closefile()  ! vtkbin.c

      if(nid.eq.0) call pvtk_xml3(dumpno)

#endif
      return
      end
C----------------------------------------------------------------------
      subroutine restart_swap
c-----------------------------------------------------------------------
      implicit none
#ifdef MPIIO
#ifndef  NO_IO
      include 'SIZE'
      include 'TOTAL'
      include 'EMWAVE'
      include 'SCHROD'
      include 'DRIFT'
      include 'POISSON'

      common  /RSTTMP/  xmr1(lx1,ly1,lz1,lelt)
     $                , ymr1(lx1,ly1,lz1,lelt)
     $                , zmr1(lx1,ly1,lz1,lelt)
     $                , exr (lx1,ly1,lz1,lelt)
     $                , eyr (lx1,ly1,lz1,lelt)
     $                , ezr (lx1,ly1,lz1,lelt)
     $                , hxr (lx1,ly1,lz1,lelt)
     $                , hyr (lx1,ly1,lz1,lelt)
     $                , hzr (lx1,ly1,lz1,lelt)
      real              xmr1,ymr1,zmr1,exr,eyr,ezr,hxr,hyr,hzr
      common  /c_rvtk/ vtkxyz(3*lx1*ly1*lz1*lelt)
      real             vtkxyz
      common  /c_ivtk/ fpcnt (8*lx1*ly1*lz1*lelt)
      integer          fpcnt

      !write in float --> read in double: doesn't work
      !write in float --> read in float : recover up to 7-8 digits
      !write in double--> read in double: recover up to 16 digits

      integer n,dumpno,idump,idummy
      integer iooption,numfiles,idouble
      real*8  dclock,t0
      real    glsum,restart_time,dtvtk

      integer nxyz3,nn1,nn2
      integer i

      integer icalld
      save    icalld
      data    icalld/0/

      nxyz3= nxyz*3  !

      t0= dclock()

      if (nid.eq.0) then
          iooption    = param(81)
          numfiles    = param(82)
          irstdumpno  = param(84)
          idouble     = param(87)
      else
          iooption    = 0
          numfiles    = 0
          irstdumpno  = 0
          idouble     = 0
      endif

      call bcast(iooption  ,isize)
      call bcast(numfiles  ,isize)
      call bcast(irstdumpno,isize)
      call bcast(idouble   ,isize)

      IFDOUBLE=.true.                    ! zero: double
      if (idouble.ne.0) IFDOUBLE=.false. ! nonzero: float
      if (nid.eq.0) write(6,*) 'IFDOUBLE=',IFDOUBLE
      if (nid.eq.0) write(6,*) 'restart format param(87)=',idouble
      if (nid.eq.0) write(6,*) 'restart param(84)=',irstdumpno

      t0= dclock()
      call pass_io_params  (iooption,numfiles,ndim,mesh)

      call openfile_restart(irstdumpno, nid)
      call readheader4     (irststep,idump,nn1,nn2,restart_time,dtvtk)

      if (nid.eq.0) then
          time = time + restart_time
      else
          time = 0.0
      endif
      time = glsum(time,1)
      if (nid.eq.0) write(6,*) 'restart at time=time+rst_time',time

      !call printchecks  (idump)
      call readnodes4   (vtkxyz,npts) ! dummy reading but necessary
      call swap_real_backward(vtkxyz,nxyz3)
      call save2vectors (xmr1,ymr1,zmr1,vtkxyz,npts)

      if (ldim.eq.3) then
           call read3dcells4(idummy,idummy,idummy,npts)  !no return
      else
           call read2dcells4(idummy,idummy,idummy,npts)  !no return
      endif

#if defined SCHROD
      if (ifdouble) then
         call readfield4_double  (idummy,vtkxyz,npts)
         call swap_real_backward (vtkxyz,nxyz3)
         call save2vectors       (ur,ui,ui,vtkxyz,npts)
         call readfield4_double  (idummy,vtkxyz,npts)
         call swap_real_backward (vtkxyz,nxyz3)
         call save2vectors       (qr(1,1),qr(1,2),qr(1,3),vtkxyz,npts)
         call readfield4_double  (idummy,vtkxyz,npts)
         call swap_real_backward (vtkxyz,nxyz3)
         call save2vectors       (qi(1,1),qi(1,2),qi(1,3),vtkxyz,npts)
      else
         call readfield4         (idummy,vtkxyz,npts)
         call swap_real_backward (vtkxyz,nxyz3)
         call save2vectors       (ur,ui,ui,vtkxyz,npts)
         call readfield4         (idummy,vtkxyz,npts)
         call swap_real_backward (vtkxyz,nxyz3)
         call save2vectors       (qr(1,1),qr(1,2),qr(1,3),vtkxyz,npts)
         call readfield4         (idummy,vtkxyz,npts)
         call swap_real_backward (vtkxyz,nxyz3)
         call save2vectors       (qi(1,1),qi(1,2),qi(1,3),vtkxyz,npts)
      endif
#elif defined DRIFT
      if (ifdouble) then
         call readfield4_double  (idummy,vtkxyz,npts)
         call swap_real_backward (vtkxyz,nxyz3)
         call save2vectors       (cN,cP,potent,vtkxyz,npts)
c        call readfield4_double  (idummy,vtkxyz,npts)
c        call swap_real_backward (vtkxyz,nxyz3)
c        call save2vectors       (scN,scP,spotent,vtkxyz,npts)
      else
         call readfield4         (idummy,vtkxyz,npts)
         call swap_real_backward (vtkxyz,nxyz3)
         call save2vectors       (cN,cP,potent,vtkxyz,npts)
c        call readfield4         (idummy,vtkxyz,npts)
c        call swap_real_backward (vtkxyz,nxyz3)
c        call save2vectors       (scN,scP,spotent,vtkxyz,npts)
      endif
#elif defined MAXWELL
      if (ifdouble) then
         call readfield4_double   (idummy,vtkxyz,npts)
         call swap_real_backward  (vtkxyz,nxyz3)
         call save2vectors        (en(1,1),en(1,2),en(1,3),vtkxyz,npts)
         call readfield4_double   (idummy,vtkxyz,npts)
         call swap_real_backward  (vtkxyz,nxyz3)
         call save2vectors        (hn(1,1),hn(1,2),hn(1,3),vtkxyz,npts)
      else
         call readfield4          (idummy,vtkxyz,npts)
         call swap_real_backward  (vtkxyz,nxyz3)
         call save2vectors        (en(1,1),en(1,2),en(1,3),vtkxyz,npts)
         call save2vectors        (hn(1,1),hn(1,2),hn(1,3),vtkxyz,npts)
         call swap_real_backward  (vtkxyz,nxyz3)
         call save2vectors        (hn(1,1),hn(1,2),hn(1,3),vtkxyz,npts)
      endif
#else
#error "Invalid application"
#endif

      call closefile_restart
#endif
#endif
      return
      end
c-----------------------------------------------------------------------
      subroutine save2vectors (ux1,uy1,uz1,vtkxyz,n)
      implicit none
      include 'SIZE'
      include 'TOTAL'
      include 'EMWAVE'

      integer i,k,n
      real    ux1(lx1,ly1,lz1,lelt)
      real    uy1(lx1,ly1,lz1,lelt)
      real    uz1(lx1,ly1,lz1,lelt)
      real    vtkxyz(3*lx1*ly1*lz1*lelt)

      k = 1
      do i = 1,n
         ux1(i,1,1,1)=vtkxyz(k  )
         uy1(i,1,1,1)=vtkxyz(k+1)
         uz1(i,1,1,1)=vtkxyz(k+2)
         k = k+3
      enddo

      return
      end
c-----------------------------------------------------------------------
      subroutine printchecks(idump)
c-----------------------------------------------------------------------
      implicit none
      include 'SIZE'
      include 'TOTAL'
      include 'EMWAVE'
      integer     idump

      irstdumpno =idump
      istep      =irststep

      if (nid.eq.0) write(6,*) 'restart timestep=',irststep,
     $ ', restart dumpno=',irstdumpno,', restart time=', time,'istep=',
     $    istep, 'nid',nid

      return
      end
c-----------------------------------------------------------------------
