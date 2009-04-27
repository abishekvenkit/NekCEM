C-----------------------------------------------------------------------
C
      subroutine set_rsb(nelin)
C
      return
      end
C     
C-----------------------------------------------------------------------
C
      subroutine reset_rsb()
C
c     call end_rsb()
C
      return
      end

C
C-----------------------------------------------------------------------
C
      function irsb()
C
      integer c_rsb
C
c     irsb = c_rsb()
C
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine rsb()
C
      integer c_rsb
C
c     ierr = c_rsb()
C
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine set_level()
C
c     call c_set_level()
C
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine set_seed()
C
c     call c_set_seed()
C
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine set_tolerance()
C
c     call c_set_tolerance()
C
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine set_max_repeats()
C
c     call c_set_max_repeats()
C
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine set_max_lanczos()
C
c     call c_set_max_lanczos()
C
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine prs_rsb_defaults()
C
c     call c_prs_defaults()
C
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine rsb_drawel(i)
C
C
      integer I
C
      include 'basics.inc'
      include 'basicsp.inc'
C
      integer color(1)
C
      equivalence (color,w)
C
c     call hmt_drawel_color(I,color(I))
C
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine proc_map(draw_flag,nelin)
C
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine sep_map(draw_flag,nelin)
C  
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine sep_proc_map(draw_flag,nelin)
C
      return
      end
C
c-----------------------------------------------------------------------
c
      subroutine cdrmesh_color()
c
c     Redraw preprocessor mesh with color given by integer array ic(1:nel)
c
      return
      end
C
c-----------------------------------------------------------------------
c
      subroutine drmesh_color(nelin)
c
c     Redraw preprocessor mesh with color given by integer array ic(1:nel)
c
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine drmesh_color_nln(nelin)
c
c     Redraw preprocessor mesh with color given by integer array ic(1:nel)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine compute_adj(ia,ja,vals,x_centroid,y_centroid
     $     ,z_centroid,n,vertex,nv,nelin)
c
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine rank(A,IND,N)
C
C     Use Heap Sort (p 233 Num. Rec.), 5/26/93 pff.
C
      integer ind(1)
      real      a(1)
C
      if (n.le.1) return
      DO 10 J=1,N
         IND(j)=j
   10 continue
C
      if (n.eq.1) return
      L=n/2+1
      ir=n
  100 CONTINUE
         IF (l.gt.1) THEN
            l=l-1
            indx=ind(l)
            q=a(indx)
         ELSE
            indx=ind(ir)
            q=a(indx)
            ind(ir)=ind(1)
            ir=ir-1
            if (ir.eq.1) then
               ind(1)=indx
               return
            endif
         ENDIF
         i=l
         j=l+l
  200    CONTINUE
         IF (J.le.IR) THEN
            IF (J.lt.IR) THEN
               IF ( A(IND(j)).lt.A(IND(j+1)) ) j=j+1
            ENDIF
            IF (q.lt.A(IND(j))) THEN
               IND(I)=IND(J)
               I=J
               J=J+J
            ELSE
               J=IR+1
            ENDIF
         GOTO 200
         ENDIF
         IND(I)=INDX
      GOTO 100
      END
C
C-----------------------------------------------------------------------
C
      subroutine irank(a,ind,n)
C
C     Use Heap Sort (p 233 Num. Rec.), 5/26/93 pff.
C
      integer a(1),ind(1),q
C
      if (n.le.1) return
      do 10 j=1,n
         ind(j)=j
   10 continue
C
      if (n.eq.1) return
      L=n/2+1
      ir=n
  100 continue
         IF (l.gt.1) THEN
            l=l-1
            indx=ind(l)
            q=a(indx)
         ELSE
            indx=ind(ir)
            q=a(indx)
            ind(ir)=ind(1)
            ir=ir-1
            if (ir.eq.1) then
               ind(1)=indx
               return
            endif
         ENDIF
         i=l
         j=l+l
  200    CONTINUE
         IF (J.le.IR) THEN
            IF (J.lt.IR) THEN
               IF ( a(ind(j)).lt.a(ind(j+1)) ) j=j+1
            ENDIF
            IF (q.lt.a(ind(j))) THEN
               ind(i)=ind(j)
               I=J
               J=J+J
            ELSE
               J=IR+1
            ENDIF
         GOTO 200
         ENDIF
         IND(I)=INDX
      GOTO 100
      end
C
C-----------------------------------------------------------------------
C
      subroutine hmt_spy_csrmat(ia,ja,vals,n,name9)
      integer ia(1),ja(1)
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine spy_csrmat(ia,ja,n,name9)
      integer ia(1),ja(1)
c
      character*9 name9
      character*1 s(100)
c
      write(6,1) name9,n
    1 format(/,'CSR Mat:',a9,3x,'n =',i3,/)
c
      n100 = min(n,80)
      do i=1,n
         call blank(s,100)
         n1 = ia(i)
         n2 = ia(i+1)-1
         do jj=n1,n2
            j = ja  (jj)
            if (j.le.n100) write(s(j),5)
         enddo
         write(6,100) (s(k),k=1,n100)
      enddo
    5 format('X')
  100 format(100a1)
c
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine cfill(a,b,n)
      real  a(1)
      do i = 1, n
         a(i) = b
      enddo
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine lfalse(a,n)
      logical  a(1)
      do i = 1, n
         a(i) = .false.
      enddo
      return
      end
C-----------------------------------------------------------------------
      subroutine period_coinc(vertex,start_pt,nv)
c
c     Adjust adjacency arrays and vertex to acct for
c     periodic bcs.
c
      include 'basics.inc'
      include 'basicsp.inc'
c
      integer n,nv
      integer vertex(1),start_pt(1)
c
      logical ifcons
c
      integer vlist(4,2)
      integer v1,v2
C
      kfld = 2
      if (ifflow) kfld=1
C
      nc       = 2**ndim
      nfaces   = 2*ndim
      ncf      = 2**(ndim-1)
c
c     March over all elements, looking for periodic face.
c     Also, check for consistency of P-P bcs.
c
      do ie=1,nel
         do iface = 1,nfaces
            if (cbc(iface,ie,kfld).eq.'P  ') then
               je = bc(1,iface,ie,kfld)
               jf = bc(2,iface,ie,kfld)
c
               ifcons = .true.
               if (cbc(jf,je,kfld).ne.'P  '  ) ifcons = .false.
               if ( bc(1,jf,je,kfld).ne.ie   ) ifcons = .false.
               if ( bc(2,jf,je,kfld).ne.iface) ifcons = .false.
               if (.not.ifcons) then
                  call blank(line,70)
                  write(line,1)
                  call prs(line)
                  write(line,2) ie,iface
                  call prs(line)
                  write(line,2) je,jf
                  call prs(line)
    1             format('WARNING: inconsistent periodic BCs.$')
    2             format('Reset el/face2:',i6,i3,' to "p"$')
               endif
c
c              Find pairings of vertices based upon face info & geom.
c
               call find_match(vlist,iface,ie,jf,je)
c
               do i=1,ncf
                  iv1   = vlist(i,1)
                  iv2   = vlist(i,2)
                  v1    = vertex(iv1)
                  v2    = vertex(iv2)
c
              if (v2.gt.v1) 
     $        write(6,11) ie,iface,je,jf,' Replace vertex'
     $        ,iv2,v2,' with ',iv1,v1
c
              if (v1.gt.v2) 
     $        write(6,11) ie,iface,je,jf,' Replace vertex'
     $        ,iv1,v1,' with ',iv2,v2 
  11          format(2(i6,i3),a15,2i10,a6,2i10)
c
c  
c                 Replace larger of 2 vertices.  If same, do nothing.
                  if (v2.gt.v1) call reset_v(vertex,v1,v2,nv)
                  if (v1.gt.v2) call reset_v(vertex,v2,v1,nv)
c
c
               enddo
            endif
         enddo
      enddo
c
      return
      end
C-----------------------------------------------------------------------
      subroutine find_match(vlist,iface,ie,jf,je)
c
c     Return list of corresponding vertices when (iface,ie) is
c     "periodic" with (jf,je).
c
      include 'basics.inc'
      include 'basicsp.inc'
c
      integer vlist(4,2)
c
      real xl(4,2)
      real yl(4,2)
      real zl(4,2)
c
c     order3 is an array which gives a cyclic permutation of vertices in 
c     counter-clockwise order when looking at a face from *outside* the cube.
c     Using pre-nek ordering, which is miserably non-symmetric...
      integer order3(4,6)
      save    order3
      data    order3  / 1, 2, 6, 5
     $                , 2, 3, 7, 6
     $                , 3, 4, 8, 7
     $                , 4, 1, 5, 8
     $                , 1, 4, 3, 2
     $                , 5, 6, 7, 8 /
c
c     Pairing of face (jf,je) to (iface,ie) is done by considering
c     4 rotations of (jf,je) and taking that which minimizes the
c     L2 measure of the separation of the vertices.
c
      nc  = 2**ndim
      ncf = 2**(ndim-1)
c
c     Load (iface,ie) in reverse order
c
      do ic = 1,ncf
         xl(ic,1)    = x(ie,order3(ncf+1-ic,iface))
         yl(ic,1)    = y(ie,order3(ncf+1-ic,iface))
         zl(ic,1)    = z(ie,order3(ncf+1-ic,iface))
         vlist(ic,1) =      order3(ncf+1-ic,iface) + nc*(ie-1)
      enddo
c
      dmin = 1.e22
      jrmn = 0
      do jrot = 0,ncf-1
         do jc=1,ncf
            jcr         = mod1(jc+jrot,ncf)
            xl(jc,2)    = x(je,order3(jcr,jf))
            yl(jc,2)    = y(je,order3(jcr,jf))
            zl(jc,2)    = z(je,order3(jcr,jf))
         enddo
         if (ndim.eq.2) call rzero(zl,8)
         d = 0.
         do ic=1,ncf                         !major error found 11/19/01 pff
            d = d + (xl(ic,1)-xl(ic,2))**2
     $            + (yl(ic,1)-yl(ic,2))**2
     $            + (zl(ic,1)-zl(ic,2))**2
         enddo
         if (d.lt.dmin) then
            dmin = d
            jrmn = jrot
         endif
      enddo
c
c     OK... distance minimizing rotation now found.  Choose this
c     as list
c
      do jc = 1,ncf
         jcr         = mod1(jc+jrmn,ncf)
         vlist(jc,2) = order3(jcr,jf) + nc*(je-1)
      enddo
c     write(6,1) jrmn,'rot1',(vlist(k,1),k=1,4),ie,iface
c     write(6,2) 'rot2',(vlist(k,2),k=1,4),je,jf,dmin
c   1 format(i1,a4,2x,6i7)
c   2 format(1x,a4,2x,6i7,1pe12.4)
c
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine reset_v(vertex,v1,v2,nv)
c
      integer vertex(1),v1,v2
c
c     Update vertex list, replacing v2 ref's w/ v1 refs.
c
      do i=1,nv
         if (vertex(i).eq.v2) vertex(i) = v1
      enddo
c
      return
      end
C
C-----------------------------------------------------------------------
C
      subroutine out_csrmat(acsr,ia,ja,n,name)
      real    acsr(1)
      integer ia(1),ja(1)
c
      character*9 name
      character*5 s(33)
c
      nnz = ia(n+1)-ia(1)
      write(6,*) 'outcs: ',name,n,nnz
      write(6,9) (acsr(k),k=1,nnz)
      write(6,8) (ja(k),k=1,nnz)
    8 format(10i10)
    9 format(1p10e10.2)
c
      write(6,1) name,n
    1 format(/,'CSR Mat:',a9,3x,'n =',i3,/)
c
      n33 = min(n,26)
      do i=1,n
         call blank(s,132)
         n1 = ia(i)
         n2 = ia(i+1)-1
         do jj=n1,n2
            j = ja  (jj)
            a = acsr(jj)
            if (a.ne.0..and.j.le.n33) write(s(j),5) a
         enddo
         write(6,33) (s(k),k=1,n33)
      enddo
    5 format(f5.2)
   33 format(33a5)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine period_check(ifld)
c
c     Adjust adjacency arrays and vertex to acct for
c     periodic bcs.
c
      include 'basics.inc'
      include 'basicsp.inc'
c
      nc       = 2**ndim
      nfaces   = 2*ndim
      ncf      = 2**(ndim-1)
c
c     March over all elements, looking for periodic face.
c     Also, check for consistency of P-P bcs.
c
      do ie=1,nel
         do iface = 1,nfaces
            if (cbc(iface,ie,ifld).eq.'P  ') then
               je = bc(1,iface,ie,ifld)
               jf = bc(2,iface,ie,ifld)
c
               icons = 0
               if (cbc(jf,je,ifld).ne.'P  '  ) icons = 1
               if ( bc(1,jf,je,ifld).ne.ie   ) icons = 2
               if ( bc(2,jf,je,ifld).ne.iface) icons = 3
               if (icons.ne.0) then
                  call blank(line,70)
                  write(line,1) icons,cbc(jf,je,ifld)
                  call prs(line)
                  write(line,2) ie,iface,ifld
                  call prs(line)
                  write(line,2) je,jf,ifld
                  call prs(line)
    1             format('WARNING: inconsistent per. BCs:',i2,1x,a3,'$')
    2             format('Reset el/face1:',i6,2i3,' to "p"$')
                  cbc(iface,ie,ifld) = 'p  '
                  call rzero(bc(1,iface,ie,ifld),5)
c
               endif
c
            endif
         enddo
      enddo
c
      return
      end
C-----------------------------------------------------------------------
      subroutine period_bc_check(if_any_per)
c
c     Adjust adjacency arrays and vertex to acct for
c     periodic bcs.
c
      include 'basics.inc'
      include 'basicsp.inc'
c
      logical if_any_per
C
      nc       = 2**ndim
      nfaces   = 2*ndim
      ncf      = 2**(ndim-1)
c
c     March over all elements, looking for periodic face.
c     Also, check for consistency of P-P bcs.
c
      ifld0=2
      ifld1=1
      if (ifflow) ifld0=1
      if (ifheat) ifld1=2+npscal
c
      if_any_per = .false.
      do ifld = ifld0,ifld1
      do ie=1,nel
         do iface = 1,nfaces
            if (cbc(iface,ie,ifld).eq.'P  ') if_any_per = .true.
         enddo
      enddo
      enddo
c
      return
      end
c-----------------------------------------------------------------------
      subroutine out_csr_matl(ia,ja,vals,n)
      integer ia(1),ja(1)
      real*8 vals(1)
c
      open(unit=39,file='csr.dat',status='unknown')
      do i=1,n
         j0=ia(i  )
         j1=ia(i+1)-1
         do j=j0,j1
            write(39,39) i,ja(j),vals(j)
         enddo
      enddo
   39 format(2i10,1p1e19.9)
      close(unit=39)
c
      return
      end
c-----------------------------------------------------------------------