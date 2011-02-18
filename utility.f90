module utility
  implicit none
  private
  public :: ccosh, csinh, logspace, linspace

contains
  pure elemental function ccosh(z) result(f)
    use constants, only : EP
    complex(EP), intent(in) :: z
    complex(EP) :: f
    real(EP) :: x,y
    x = real(z)
    y = aimag(z)
    f = cmplx(cosh(x)*cos(y), sinh(x)*sin(y),EP)
  end function ccosh
  
  pure elemental function csinh(z) result(f)
    use constants, only : EP
    complex(EP), intent(in) :: z
    complex(EP) :: f
    real(EP) :: x,y
    x = real(z)
    y = aimag(z)
    f = cmplx(sinh(x)*cos(y), cosh(x)*sin(y),EP)
  end function csinh
  
  pure function linspace(lo,hi,num) result(v)
    use constants, only : DP
    real(DP), intent(in) :: lo,hi
    integer, intent(in) :: num
    real(DP), dimension(num) :: v
    integer :: i
    real(DP) :: rnum, range, sgn

    rnum = real(num - 1,DP)
    range = abs(hi - lo) 
    sgn = sign(1.0_DP,hi-lo) ! if lo > high, count backwards
    forall (i=0:num-1) v(i+1) = lo + sgn*real(i,DP)*range/rnum
  end function linspace

  pure function logspace(lo,hi,num) result(v)
    use constants, only : DP
    integer, intent(in) :: lo,hi,num
    real(DP), dimension(num) :: v
    v = 10.0_DP**linspace(real(lo,DP),real(hi,DP),num)
  end function logspace

end module utility


