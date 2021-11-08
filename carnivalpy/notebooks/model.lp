\Problem name: CARNIVAL-PyMIP

Minimize
OBJROW: 0.20000 nU_I2 + 0.20000 nD_I2 + 0.20000 nU_P2 + 0.20000 nD_P2 + 0.20000 nU_P1 + 0.20000 nD_P1 + 0.20000 nU_I1 + 0.20000 nD_I1 + 0.20000 nU_T + 0.20000 nD_T
 + aD_T
Subject To
constr(0):  nU_I2 - nD_I2 - nX_I2 + nAc_I2 = -0
constr(1):  nU_P2 - nD_P2 - nX_P2 + nAc_P2 = -0
constr(2):  nU_P1 - nD_P1 - nX_P1 + nAc_P1 = -0
constr(3):  nU_I1 - nD_I1 - nX_I1 + nAc_I1 = -0
constr(4):  nU_T - nD_T - nX_T + nAc_T = -0
constr(5):  eU_I1_P1 + eD_I1_P1 <= 1
constr(6):  eU_I2_P1 + eD_I2_P1 <= 1
constr(7):  eU_I2_P2 + eD_I2_P2 <= 1
constr(8):  eU_P1_T + eD_P1_T <= 1
constr(9):  nX_T - aD_T <= 1
constr(10):  nX_T + aD_T >= 1
constr(11):  - nX_I1 + eU_I1_P1 >= -0
constr(12):  nX_I1 + eD_I1_P1 >= -0
constr(13):  - nX_I1 + eU_I1_P1 - eD_I1_P1 <= -0
constr(14):  nX_I1 - eU_I1_P1 + eD_I1_P1 <= -0
constr(15):  - nDs_P1 + nDs_I1 + 101 eU_I1_P1 <= 100
constr(16):  - nDs_P1 + nDs_I1 + 101 eD_I1_P1 <= 100
constr(17):  - nX_I2 + eU_I2_P1 >= -0
constr(18):  nX_I2 + eD_I2_P1 >= -0
constr(19):  - nX_I2 + eU_I2_P1 - eD_I2_P1 <= -0
constr(20):  nX_I2 - eU_I2_P1 + eD_I2_P1 <= -0
constr(21):  nDs_I2 - nDs_P1 + 101 eU_I2_P1 <= 100
constr(22):  nDs_I2 - nDs_P1 + 101 eD_I2_P1 <= 100
constr(23):  nX_I2 + eU_I2_P2 >= -0
constr(24):  - nX_I2 + eD_I2_P2 >= -0
constr(25):  nX_I2 + eU_I2_P2 - eD_I2_P2 <= -0
constr(26):  - nX_I2 - eU_I2_P2 + eD_I2_P2 <= -0
constr(27):  nDs_I2 - nDs_P2 + 101 eU_I2_P2 <= 100
constr(28):  nDs_I2 - nDs_P2 + 101 eD_I2_P2 <= 100
constr(29):  - nX_P1 + eU_P1_T >= -0
constr(30):  nX_P1 + eD_P1_T >= -0
constr(31):  - nX_P1 + eU_P1_T - eD_P1_T <= -0
constr(32):  nX_P1 - eU_P1_T + eD_P1_T <= -0
constr(33):  nDs_P1 - nDs_T + 101 eU_P1_T <= 100
constr(34):  nDs_P1 - nDs_T + 101 eD_P1_T <= 100
constr(35):  - nU_P1 + eU_I1_P1 + eU_I2_P1 >= -0
constr(36):  - nD_P1 + eD_I1_P1 + eD_I2_P1 >= -0
constr(37):  nU_P2 - eU_I2_P2 <= -0
constr(38):  nD_P2 - eD_I2_P2 <= -0
constr(39):  nU_T - eU_P1_T <= -0
constr(40):  nD_T - eD_P1_T <= -0
constr(41):  nU_I1 <= -0
constr(42):  nD_I1 <= -0
constr(43):  nX_I1 = 1
constr(44):  nX_I1 - nAc_I1 = -0
constr(45):  nU_I2 <= -0
constr(46):  nD_I2 <= -0
constr(47):  nX_I2 = 1
constr(48):  nX_I2 - nAc_I2 = -0
constr(49):  nAc_P1 = -0
constr(50):  nAc_P2 = -0
constr(51):  nAc_T = -0
Bounds
 0 <= nU_I2 <= 1
 0 <= nD_I2 <= 1
 -1 <= nX_I2 <= 1
 -1 <= nAc_I2 <= 1
 0 <= nDs_I2 <= 100
 0 <= nU_P2 <= 1
 0 <= nD_P2 <= 1
 -1 <= nX_P2 <= 1
 -1 <= nAc_P2 <= 1
 0 <= nDs_P2 <= 100
 0 <= nU_P1 <= 1
 0 <= nD_P1 <= 1
 -1 <= nX_P1 <= 1
 -1 <= nAc_P1 <= 1
 0 <= nDs_P1 <= 100
 0 <= nU_I1 <= 1
 0 <= nD_I1 <= 1
 -1 <= nX_I1 <= 1
 -1 <= nAc_I1 <= 1
 0 <= nDs_I1 <= 100
 0 <= nU_T <= 1
 0 <= nD_T <= 1
 -1 <= nX_T <= 1
 -1 <= nAc_T <= 1
 0 <= nDs_T <= 100
 0 <= aD_T <= 2
 0 <= eU_I1_P1 <= 1
 0 <= eD_I1_P1 <= 1
 0 <= eU_I2_P1 <= 1
 0 <= eD_I2_P1 <= 1
 0 <= eU_I2_P2 <= 1
 0 <= eD_I2_P2 <= 1
 0 <= eU_P1_T <= 1
 0 <= eD_P1_T <= 1
Integers
nU_I2 nD_I2 nX_I2 nAc_I2 nDs_I2 nU_P2 nD_P2 nX_P2 nAc_P2 nDs_P2 
nU_P1 nD_P1 nX_P1 nAc_P1 nDs_P1 nU_I1 nD_I1 nX_I1 nAc_I1 nDs_I1 
nU_T nD_T nX_T nAc_T nDs_T aD_T eU_I1_P1 eD_I1_P1 eU_I2_P1 eD_I2_P1 
eU_I2_P2 eD_I2_P2 eU_P1_T eD_P1_T 
End
