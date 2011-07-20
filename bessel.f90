module complex_bessel

  private
  public :: cjy

contains

  SUBROUTINE cjy(v,z,cbjv,cbyv)

    ! simplified and vectorized version of Zhang and Jin's code
    !       ===================================================
    !       Purpose: Compute Bessel functions Jv(z) and Yv(z)
    !                and their derivatives with a complex
    !                argument and a large order
    !       Input:   v --- Order of Jv(z) and Yv(z)
    !                z --- Complex argument
    !       Output:  CBJV --- Jv(z)
    !                CBYV --- Yv(z)
    !       ===================================================
    use constants, only : EP,INVPIEP,TWOPIEP,PIOV2EP,E
    implicit none

    REAL(EP), INTENT(IN)  :: v
    COMPLEX(EP), dimension(:), INTENT(IN)   :: z
    COMPLEX(EP), dimension(size(z)), INTENT(OUT)  :: cbjv
    COMPLEX(EP), dimension(size(z)), INTENT(OUT)  :: cbyv

    integer, parameter :: KM = 12
    integer, dimension(KM) :: ii

    real(EP), dimension(91), parameter :: &
         & a = [1.00000000000000000000000000000000000_EP, & 
        & 0.125000000000000000000000000000000000_EP, & 
        & -0.208333333333333333333333333333333341_EP, & 
        & 0.0703125000000000000000000000000000000_EP, & 
        & -0.401041666666666666666666666666666683_EP, & 
        & 0.334201388888888888888888888888888894_EP, & 
        & 0.0732421875000000000000000000000000000_EP, & 
        & -0.891210937500000000000000000000000019_EP, & 
        & 1.84646267361111111111111111111111115_EP, & 
        & -1.02581259645061728395061728395061744_EP, & 
        & 0.112152099609375000000000000000000000_EP, & 
        & -2.36408691406250000000000000000000023_EP, & 
        & 8.78912353515625000000000000000000000_EP, & 
        & -11.2070026162229938271604938271604949_EP, & 
        & 4.66958442342624742798353909465020581_EP, & 
        & 0.227108001708984375000000000000000000_EP, & 
        & -7.36879435947963169642857142857142895_EP, & 
        & 42.5349987453884548611111111111111188_EP, & 
        & -91.8182415432400173611111111111111139_EP, & 
        & 84.6362176746007346322016460905349880_EP, & 
        & -28.2120725582002448774005486968449940_EP, & 
        & 0.572501420974731445312500000000000000_EP, & 
        & -26.4914304869515555245535714285714303_EP, & 
        & 218.190511744211590479290674603174653_EP, & 
        & -699.579627376132541232638888888888970_EP, & 
        & 1059.99045252799987792968750000000000_EP, & 
        & -765.252468141181642299489883401920485_EP, & 
        & 212.570130039217122860969412056089015_EP, & 
        & 1.72772750258445739746093750000000000_EP, & 
        & -108.090919788394655500139508928571443_EP, & 
        & 1200.90291321635246276855468750000027_EP, & 
        & -5305.64697861340310838487413194444593_EP, & 
        & 11655.3933368645332477710865162037032_EP, & 
        & -13586.5500064341374385504075038580258_EP, & 
        & 8061.72218173730938450226495222717585_EP, & 
        & -1919.45766231840699631006308386361335_EP, & 
        & 6.07404200127348303794860839843750000_EP, & 
        & -493.915304773088012422834123883928656_EP, & 
        & 7109.51430248936372143881661551339400_EP, & 
        & -41192.6549688975512981414794921875116_EP, & 
        & 122200.464983017459787704326488353593_EP, & 
        & -203400.177280415534278165819877132624_EP, & 
        & 192547.001232531532359057820219398369_EP, & 
        & -96980.5983886375134885659373122090632_EP, & 
        & 20204.2913309661486434512369400435532_EP, & 
        & 24.3805296995560638606548309326171906_EP, & 
        & -2499.83048181120962412519888444380370_EP, & 
        & 45218.7689813627262732812336512974421_EP, & 
        & -331645.172484563577831501052493140906_EP, & 
        & 1268365.27332162478162596623102823909_EP, & 
        & -2813563.22658653411070786835561890978_EP, & 
        & 3763271.29765640399640210562227630261_EP, & 
        & -2998015.91853810675009134620305442043_EP, & 
        & 1311763.61466297720067607155833232793_EP, & 
        & -242919.187900551333458531770061542151_EP, & 
        & 110.017140269246738171204924583435071_EP, & 
        & -13886.0897537170405319722538644617284_EP, & 
        & 308186.404612662398480390784277102097_EP, & 
        & -2785618.12808645468895944456259409650_EP, & 
        & 13288767.1664218183294374116316989638_EP, & 
        & -37567176.6607633513081631979640619223_EP, & 
        & 66344512.2747290266647987984543283892_EP, & 
        & -74105148.2115326577483356209644147043_EP, & 
        & 50952602.4926646422063818219804991871_EP, & 
        & -19706819.1184322269268233898462426119_EP, & 
        & 3284469.85307203782113723164104043477_EP, & 
        & 551.335896122020585607970133423805335_EP, & 
        & -84005.4336030240852886782812566815808_EP, & 
        & 2243768.17792244942923073778023981351_EP, & 
        & -24474062.7257387284678130081560158670_EP, & 
        & 142062907.797533095185653278517916273_EP, & 
        & -495889784.275030309254636245374258466_EP, & 
        & 1106842816.82301446825966666909624588_EP, & 
        & -1621080552.10833707524817588263676894_EP, & 
        & 1553596899.57058005615812104438799628_EP, & 
        & -939462359.681578402546244300920389172_EP, & 
        & 325573074.185765749020228086418133103_EP, & 
        & -49329253.6645099619727618312754747148_EP, & 
        & 3038.09051092238426861058542272076090_EP, & 
        & -549842.327572288687134901932937295149_EP, & 
        & 17395107.5539781645381043963142367452_EP, & 
        & -225105661.889415277804071426963053034_EP, & 
        & 1559279864.87925751334964620474195193_EP, & 
        & -6563293792.61928433203501685097471321_EP, & 
        & 17954213731.1556000801522058538280378_EP, & 
        & -33026599749.8007231400909926757785454_EP, & 
        & 41280185579.7539739551314710270974340_EP, & 
        & -34632043388.1587779229024133355955142_EP, & 
        & 18688207509.2958249223659193027916268_EP, & 
        & -5866481492.05184722761070078443583040_EP, & 
        & 814789096.118312114945930664504976467_EP]

    complex(EP), dimension(size(z),KM) :: cf
    integer :: i,k,l0,lf,nz
    complex(EP), dimension(size(z)) :: cws,ceta,ct,ct2,csj,csy
    real(EP) :: vr

    intrinsic :: gamma

    forall (i=1:KM) ii(i) = i
    nz = size(z)
          
    cws(1:nz) = SQRT(1.0_EP - (z(:)/v)**2)
    ceta(1:nz) = cws(:) + LOG((z(:)/v)/(1.0_EP + cws(:)))
    ct(1:nz) = 1.0_EP/cws(:)
    ct2(1:nz) = ct(:)**2
    DO k = 1,KM
       l0 = k*(k+1)/2 + 1
       lf = l0 + k
       cf(1:nz,k) = a(lf)
       DO i = lf-1,l0,-1
          cf(1:nz,k) = cf(:,k)*ct2(:) + spread(a(i),1,nz)
       END DO
       cf(1:nz,k) = cf(:,k)*ct(:)**k
    END DO
    vr = 1.0_EP/v
    
    csj(1:nz) = 1.0_EP + sum(cf(:,:)*spread(vr**ii(:),1,nz),dim=2)       
    csy(1:nz) = 1.0_EP + sum(cf(:,:)*spread((-vr)**ii(:),1,nz),dim=2)

    ! -|aimag(z)| is scaling term (which cancels in M-N2010 case)
    cbjv(1:nz) =  SQRT(ct(:)/(TWOPIEP*v))*EXP(v*ceta(:)-abs(aimag(z)))*csj(:)
    cbyv(1:nz) = -SQRT(ct(:)/(PIOV2EP*v))*EXP(-v*ceta(:)-abs(aimag(z)))*csy(:)
  END SUBROUTINE cjy

end module complex_bessel
