
module types
  use constants, only : DP
  implicit none

  public

  type :: invLaplace
     ! Inverse Laplace Transform parameters

     ! abcissa of convergence, LT tolerance
     real(DP) :: alpha = -999., tol = -999.

     ! number of Fourier series terms
     integer :: M = -999

     ! length of solution vector (2*M+1)
     integer :: np = -999

  end type invLaplace

  type :: invHankel
     ! inverse Hankel transform parameters

     ! zeros of J0 Bessel function
     real(DP), allocatable :: j0z(:) ! locations of zeros of J0 bessel fnc
     integer :: splitrange = -999, zerorange = -999
     integer, allocatable :: sv(:) ! split index  vector

     ! min/max j0 split between infinite/fininte integrals
     integer, dimension(2) :: j0s = [-999, -999] 

  end type invHankel

  type :: GaussLobatto
     ! parameters specific to GL quadrature

     integer :: nacc = -999, err -999

     ! abcissa and weights
     real(EP), allocatable :: x(:), w(:)

     ! order of integration
     integer :: ord = -999

  end type GaussLobatto
  
  type :: TanhSinh
     ! parameters specific to tanh-sinh quadrature

     integer :: k = -999, N = -999, nst = -999
     real(EP), allocatable :: w(:), a(:), hh(:)
     integer, allocatable :: kk(:), NN(:), ii(:)
     
     ! error in polynomial extrapolation
     complex(EP) :: polerr = (-999., -999.)

  end type TanhSinh

  type :: well
     ! parameters related to well/completion
     real(DP) :: l = -999. ! aquifer top to screen/packer top dist.
     real(DP) :: d = -999. ! aquifer top to screen/packer bottom dist.
     real(DP) :: rw = -999., rc = -999. ! well / casing radii

     ! dimensionless parameters
     real(DP) :: lD = -999.  ! dimensionless l
     real(DP) :: dD = -999.  ! dimensionless d
     real(DP) :: bD = -999.  ! dimensionless screen length
     real(DP) :: rDw = -999. ! dimensionless rw

  end type well

  type :: formation
     ! parameters related to formation/aquifer
          
     real(DP) :: b = -999.  ! aquifer thickness
     real(DP) :: Kr = -999. ! radial hydraulic conductivity
     real(DP) :: kappa  = -999.  ! Kz/Kr ratio
     real(DP) :: Ss = -999. ! specific storage
     real(DP) :: Sy = -999. ! specific yield
     real(DP) :: gamma = -999.  ! dimensionless skin (1=no skin)
     real(DP) :: usL = -999. ! thickness of unsaturated zone
     real(DP) :: usalpha = -999. ! unzaturated zone sorbtive number

     ! computed aquifer parameters
     real(DP) :: sigma = -999.  ! Sy/(Ss*b)
     real(DP) :: alphaD = -999. ! kappa/sigma

  end type formation

  type(time) :: solution
     ! parameters related to numerical solution

     real(DP) :: Lc = -999.  ! characteristic length
     real(DP) :: Tc = -999.  ! characteristic time

     ! which unconfined model to use?
     integer :: model = -999
     ! 1 = Boulton 195?
     ! 2 = Neuman 1974 
     ! 3 = Moench 199?
     ! 4 = Mishra/Neuman 2011
     ! 5 = Malama 2011

     logical :: quiet = .false.  ! output debugging to stdout?
     logical :: dimless = .false.  ! output dimensionless solution?

     ! either the number of times to be computed,
     ! or the number of times read from file
     integer :: nt = -999  

     ! vector of times to compute solution at
     real(DP), allocatable :: t(:), tD(:)

     integer, parameter :: NUMCHAR = 128
     character(NUMCHAR) :: outfilename, infilename, timefilename

     character(7) :: rfmt = 'ES14.07'

     ! time behavior / parameters 
     ! 1 = step on,              tpar(1)  = on time
     ! 2 = finite pulse,         tpar(1:2) = on/off time
     ! 3 = instan. pulse         tpar(1) = pulse time
     ! 4 = stairs,               tpar(1) = time step (increasing Q by integer multiples 
     !                                     @ integer multiples tpar(1)); tpar(2) =off time.
     ! 5 = + only square wave,   tpar(1) = 1/2 period of wave; tpar(2) = start time
     ! 6 = cosine(tpar(1)*t),    tpar(1) = frequency multiplier; tpar(2) = start time
     ! 7 = + only tri wave,      tpar(1) = 1/4 period of wave; tpar(2) = start time
     ! 8 = +/- square wave,      tpar(1) = 1/2 period of wave; tpar(2) = start time
     ! n<0 = arbitrary piecewise constant rate, comprised of n steps from tpar(1) to tfinal
     !                tpar(1:n) = starting times of each step
     !                tpar(n+1) = final time of last step
     !                tpar(n+2:2*n+1) = strength at each of n steps 
     ! (is multiplied by constant strength too -- you probably want to set that to unity)
     character(80), dimension(9) :: timeDescrip = &
          & ['step on; tpar(1) = on time',&
          &  'finite pulse; tpar(1:2) = on/off time',&
          &  'infinitessimal pulse; tpar(1) = pulse location',&
          &  'stairs; tpar(1) = time step (Q increase by integer multiples); tpar(2) = off time',&
          &  'rectified square wave; tpar(1) = 1/2 period of wave; tpar(2) = start time',&
          &  'cos(omega*t); tpar(1) = omega; tpar(2) = start time',&
          &  'rectified triangular wave; tpar(1) = 1/4 period of wave; tpar(2) = start time',&
          &  'rectified square wave; tpar(1) = 1/2 period of wave; tpar(2) = start time',&
          &  'piecewise constant rate (n steps); tpar(1:n)=ti; tpar(n+1)=tfinal; tpar(n+2:)=Q']

     ! type of time behavior  (see above)
     integer :: timeType = -999

     ! parameters related to different time behaviors (on, off, etc)
     real(DP), allocatable :: timePar(:)


  end type solution

end module types

