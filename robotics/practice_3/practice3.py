import numpy as np
import auxiliary_functions as af
import matplotlib.pyplot as plt
from functools import reduce

# 
#           Exercise of the ''Robot sensing'' lecture
#              Composition of poses and landmarks

# close all
# clear var
# clc

#  Sufix meaning:
#  _w: world reference frame
#  _r: robot reference frame
#  Other codes:
#  p: in polar coordinates
#  c: in cartesian coordinates
#  e.g. z1p_r represents an observation z1 in polar in the robot reference
#  frame

# -------------------------------------------------------------------------#
#                                4.1.1                                     #
# -------------------------------------------------------------------------#

# Robot
p1_w = af.get_pose([1,2,0.5])           # Robot R1 pose
Qp1_w = np.zeros((3,3), dtype=float)    # Robot pose covariance matrix (uncertainty)
# Landmark
z1p_r = np.array([4,0.7])               # Measurement/observation
z1p_r.shape = (2,1)
W1p_r = np.diag([0.25, 0.04])           # Sensor noise covariance

# 1. Convert polar coordinates to cartesian (in the robot frame)
_z1xc_r = z1p_r[0] * np.cos(z1p_r[1])[0]
_z1yc_r = z1p_r[0] * np.sin(z1p_r[1])[0]
z1c_r = [_z1xc_r, _z1yc_r]

# 2. Obtain the sensor/measurement covariance in cartesian coordinates in
# the frame of the robot (it is given in polar). For that you need the 
# Jacobian built from the expression that converts from polar to cartesian
# coordinates. 
r = z1p_r[0]                            # Useful variables
alpha = z1p_r[1]
c = np.cos(alpha)[0]
s = np.sin(alpha)[0]

J_pc = np.array([   [c, -r * s], 
                    [s, r * c]])        # Build the Jacobian

Wzc_r = reduce(np.matmul, [J_pc, W1p_r, J_pc.T])

# 3. Ok, we are now ready for computing the sensor measurement in the 
# world's coordinate system (mean and covariance).
_zc_r = af.get_pose([z1c_r[0][0], z1c_r[1][0], 1])
z1c_w = af.tcomp(p1_w, _zc_r)            # Compute coordinates of the landmark in the world

J_ap = af.j1(p1_w, _zc_r)[0:2, :]        # Now build the Jacobians 
J_aa = af.j2(p1_w, z1c_w)[0:2, 0:2]

Wzc_w = reduce(np.matmul, [J_ap, Qp1_w, J_ap.T])
Wzc_w += reduce(np.matmul, [J_aa, Wzc_r, J_aa.T]) # Finally, propagate the covariance!

# Draw results
axis = np.array([-1, 10, -1, 10])
fig = plt.figure(1)
ax = fig.add_subplot(111, aspect='equal')
plt.xlim(axis[0:2])
plt.ylim(axis[2:])
plt.grid(axis='both')
plt.plot(z1c_w[0],z1c_w[1],'x')
plt.text(z1c_w[0]+1, z1c_w[1],'Landmark')
ax.add_artist(af.get_ellipse([z1c_w[0][0], z1c_w[1][0]], Wzc_w, 1, 'm'))
af.draw_robot(p1_w, 'b', axis)
plt.text(p1_w[0]+1, p1_w[1], 'R1')

###
# Checking if correct:
# print(z1c_w)
# print(Wzc_w)
###

# Exercise 2

# At first we declare the covariance matrix for the robot pose:
Qp1_w = np.diag([.08, .6, .02]) 

Wzc_w = reduce(np.matmul, [J_ap, Qp1_w, J_ap.T])
Wzc_w += + reduce(np.matmul, [J_aa, Wzc_r, J_aa.T]) # Then, we recalculate the covariance

ax.add_artist(af.get_ellipse(z1c_w, Wzc_w, 1, 'b'))
ax.add_artist(af.get_ellipse(p1_w, Qp1_w, 1, 'b'))

###
# Checking if correct:
# print(Wzc_w)
###

# Exercise 3
p2_w = af.get_pose([6, 4, 2.1])
Qp2_w = np.diag([.2, .09, .03])

af.draw_robot(p2_w, 'g', axis)
ax.add_artist(af.get_ellipse(p2_w, Qp2_w, 1, 'g'))
plt.text(p2_w[0]+1, p2_w[1], 'R2')

# Now the relative pose is obtained in both possible ways:

# First approach: tcomp of p1_w_i and p2_w
c1 = np.cos(p1_w[2])[0]                             # Useful variables
s1 = np.sin(p1_w[2])[0]
_p1_w_ix = -p1_w[0] * c1 - p1_w[1] * s1
_p1_w_iy = p1_w[0] * s1 - p1_w[1] * c1
_p1_w_it = -p1_w[2]

p1_w_i = af.get_pose([_p1_w_ix, _p1_w_iy, _p1_w_it])# We obtain the inverse of the R1's pose
p12_w_a = af.tcomp(p1_w_i, p2_w)                    # Then we do the composition

# Second approach: using the inverse composition of poses
_p12_wx = (p2_w[0] - p1_w[0]) * c1 + (p2_w[1] - p1_w[1]) * s1
_p12_wy = -(p2_w[0] - p1_w[0]) * s1 + (p2_w[1] - p1_w[1]) * c1
_p12_wt = p2_w[2] - p1_w[2]
p12_w_b = af.get_pose([_p12_wx, _p12_wy, _p12_wt])

# And the covariance matrix is also obtained in both manners

# First approach covariance matrix
J_p12p1i = af.j1(p1_w_i, p2_w)
J_p12p2_a = af.j2(p1_w_i, p2_w)
J_p1ip1 = np.array([[-c1, -s1, p1_w[0] * s1 - p1_w[1] * c1], 
                    [s1, -c1, p1_w[0] * c1 + p1_w[1] * s1], 
                    [0, 0, -1]])

Qp1_w_i = reduce(np.matmul, [J_p1ip1, Qp1_w, J_p1ip1.T])
Qp12_w_a = reduce(np.matmul, [J_p12p1i, Qp1_w_i, J_p12p1i.T])
Qp12_w_a += reduce(np.matmul, [J_p12p2_a, Qp2_w, J_p12p2_a.T])

# Second approach covariance matrix
J_p12p1 = np.array([[-c1, -s1, -(p2_w[0] - p1_w[0]) * s1 + (p2_w[1] - p1_w[1]) * c1], 
                    [s1, -c1, -(p2_w[0] - p1_w[0]) * c1 - (p2_w[1] - p1_w[1]) * s1],
                    [0, 0, -1]])

Jp12p2_b = af.j2(p1_w, p2_w).T

Qp12_w_b = reduce(np.matmul, [J_p12p1, Qp1_w, J_p12p1.T])
Qp12_w_b += reduce(np.matmul, [Jp12p2_b, Qp2_w, Jp12p2_b.T])

# ###
# # Checking if correct:
# print(p12_w_a)
# print(p12_w_b)
# print(Qp12_w_a)
# print(Qp12_w_b)
# ###

# Exercise 4:
# First we obtain the polar coordinates of the observation of m by R2:
_z2_w_r = np.sqrt((z1c_w[0] - p2_w[0])**2 + (z1c_w[1] - p2_w[1])**2)[0]
_z2_w_a = np.arctan2([z1c_w[1], p2_w[1]],[z1c_w[0], p2_w[0]])[1][0]
z2_w = [_z2_w_r, _z2_w_a]

cat = np.cos(z2_w[1] + p2_w[2])[0] # Useful variables
sat = np.sin(z2_w[1] + p2_w[2])[0]

# Then we create the jacobian and obtain the covariance matrix of the predicted observation
J_pc = np.array([[cat, sat], [-sat/z2_w[0], cat/z2_w[0]]])
W2_p = reduce(np.matmul, [J_pc, Wzc_w, J_pc.T])


# ##
# Checking if correct:
# print(z2_w)
# print(W2_p)
# ##

# Exercise 5:
z2p_r = np.array([4, .3])
z2p_r.shape = (2,1)
W2p_r = W1p_r

# The pdf of the observed mark would be obtained analogously to the first exercise:
# First we obtain the cartesian coordinates
_z2xc_r = z2p_r[0][0] * np.cos(z2p_r[1])[0]
_z2yc_r = z2p_r[0][0] * np.sin(z2p_r[1])[0]
z2c_r = [_z2xc_r, _z2yc_r]

_zc_r = af.get_pose([z2c_r[0], z2c_r[1], 1])
z2_w = af.tcomp(p2_w, _zc_r) # Compute coordinates of the landmark in the world

# Then we obtain the covariance matrix of the landmark in cartesian coordinates
r = z2p_r[0] # Useful variables
alpha = z2p_r[1]
c = np.cos(alpha)[0]
s = np.sin(alpha)[0]

J_pc = np.array([   [c, -r * s], 
                    [s, r * c]]) # Build the Jacobian

Wz2c_r = reduce(np.matmul, [J_pc, W2p_r, J_pc.T])

J_ap = af.j1(p2_w, _zc_r)[0:2, :]
J_aa = af.j2(p2_w, z2_w)[0:2, 0:2]

Wz2c_w = reduce(np.matmul, [J_ap, Qp2_w, J_ap.T])
Wz2c_w +=  reduce(np.matmul, [J_aa, Wz2c_r, J_aa.T])

plt.plot(z2_w[0], z2_w[1], 'xg')
ax.add_artist(af.get_ellipse(z2_w, Wz2c_w, 1, 'g'))

###
# Checking if correct:
print(z2_w)
print(Wz2c_w)
###

# We need to do the product of gaussians (it is equivalent to the weighted mean of them)
# We use the formulae from the third exercise of practice 1

inv_s1 = np.linalg.inv(Wzc_w)
inv_s2 = np.linalg.inv(Wz2c_w)

w_mean = np.matmul(np.linalg.inv(inv_s1 + inv_s2), (np.matmul(inv_s1, z1c_w[0:2]) + np.matmul(inv_s2, z2_w[0:2])))
w_sigma = np.linalg.inv(inv_s1 + inv_s2)

plt.plot(w_mean[0], w_mean[1], 'xr')
ax.add_artist(af.get_ellipse(w_mean, w_sigma, 1, 'r'))

# ##
# Checking if correct:
print(w_mean)
print(w_sigma)
# ##

plt.title('Robot sensing practice')
plt.xlabel('x')
plt.ylabel('y')
# plt.show()