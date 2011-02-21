module laplace_hankel_solutions
  implicit none

  private
  public :: lap_hank_soln

contains

  function lap_hank_soln(a,rD,np,nz,w,frm,s,lap) result(fp)
    use constants, only : DP, EP, MAXEXP
    use types, only : well, formation, invLaplace, solution
    use time, only : lapTime
    use utility, only : operator(.X.)  ! outer product operator

    implicit none
    
    real(EP), intent(in) :: a
    real(DP), intent(in) :: rD
    integer, intent(in) :: np,nz
    type(invLaplace), intent(in) :: lap
    type(solution), intent(in) :: s
    type(well), intent(in) :: w
    type(formation), intent(in) :: frm
    complex(EP), dimension(np,nz) :: fp

    integer :: nz1
    real(DP), allocatable :: zd1(:)
    complex(EP), allocatable :: eta(:), xi(:), g(:,:,:), f(:,:), udp(:,:)

    intrinsic :: bessel_j0

    select case(s%model)
    case(0)
       ! Theis solution (fully penetrating, confined)
       fp(1:np,1:nz) = theis(a,lap%p,nz)

    case(1)
       ! Hantush solution (confined, partially penetrating)
    case(2)
       ! Boulton model
    case(3)
       ! Neuman 1972 model (fully penetrating, unconfined)
       allocate(eta(np),xi(np))

       eta(1:np) = sqrt(lap%p(:) + a**2)/frm%kappa
       xi(1:np) = eta(:)*frm%alphaD/lap%p(:)

       ! for large arguments switch to approximation
       where(spread(abs(eta),2,nz) < MAXEXP)
          fp(1:np,1:nz) = theis(a,lap%p,nz)* &
               & (1.0_EP - cosh(eta .X. s%zD)/ &
               & spread(cosh(eta(:)) + xi(:)*sinh(eta(:)),2,nz))
       elsewhere
          fp(1:np,1:nz) = theis(a,lap%p,nz)* &
               & (1.0_EP - exp(eta .X. (s%zD-1.0))/&
               & spread((1.0_EP + xi(:)),2,nz))
       end where

       deallocate(eta,xi)
    case(4)
       ! Neuman 1974 model (partially penetrating, unconfined)
       ! implemented using multiple layers
       nz1 = nz+1
       allocate(eta(np),xi(np),g(2,np,nz1),f(3,np),zd1(nz1),udp(np,nz1))
       zd1 = [s%zD,1.0_DP]

       eta(1:np) = sqrt(lap%p(:) + a**2)/frm%kappa
       xi(1:np) = eta(:)*frm%alphaD/lap%p(:)

       g(1,1:np,1:nz1) = cosh(eta(:).x.(1.0-w%dD-zD1))

       f(1,1:np) = sinh(eta(:)*w%dD)
       f(2,1:np) = sinh(eta(:)*(1.0 - w%lD))
       f(3,1:np) = exp(-eta(:)*(1.0 - w%lD)) - &
            & (f(1,:) + exp(-eta(:))*f(2,:))/sinh(eta(:))

       g(2,1:np,1:nz1) = (spread(f(1,:),2,nz1)*cosh(eta .X. zD1) + &
                        & spread(f(2,:),2,nz1)*cosh(eta .X. (1.0-zD1)))/&
                        &  spread(sinh(eta),2,nz1)

       where(spread(s%zLay,1,np) == 1)
          ! below well screen (0 <= zD <= 1-lD)
          udp(1:np,1:nz1) =  spread(f(3,:),2,nz1)*cosh(eta .X. zd1) 
       elsewhere
          where(spread(s%zLay,1,np) == 2)
             ! next to well screen (1-lD < zD < 1-dD)
             udp(1:np,1:nz1) = 1.0_EP - g(2,:,:)
          elsewhere
             ! above well screen (1-lD <= zD <= 1)
             udp(1:np,1:nz) = g(1,:,:) - g(2,:,:)
          end where          
       end where

       udp(1:np,1:nz1) = udp(:,:)*theis(a,lap%p,nz1)/w%bD

       where(spread(abs(eta),2,nz) < MAXEXP)
          fp(1:np,1:nz) = udp(:,1:nz) - spread(udp(:,nz1),2,nz)* &
               & cosh(eta .X. s%zD)/spread(cosh(eta(:)) + xi(:)*sinh(eta(:)),2,nz)
       elsewhere
          fp(1:np,1:nz) = udp(:,1:nz) - spread(udp(:,nz1),2,nz)* &
               & exp(eta .X. (s%zD-1.0))/spread((1.0_EP + xi(:)),2,nz)
       end where

       deallocate(eta,xi,g,f,zd1)

    case(5)
       ! Mishra/Neuman 2011 model
    case(6)
       ! Malama 2011

       

    end select

    ! solution always evaluated in test well
    fp(1:np,1:nz) = a*bessel_j0(a*rD)*fp(:,:)*spread(lapTime(lap),2,nz)

  end function lap_hank_soln
  
  function theis(a,p,nz) result(udf)
    use constants, only : EP
    real(EP), intent(in) :: a
    complex(EP), dimension(:), intent(in) :: p
    integer, intent(in) :: nz
    complex(EP), dimension(size(p),nz) :: udf

    udf(:,:) = spread(2.0_EP/(p(:) + a**2),dim=2,ncopies=nz)

  end function theis

end module laplace_hankel_solutions




