import auxiliary_functions as af
import numpy as np
import matplotlib.pyplot as plt
from functools import reduce

# Map/landmarks related
nLandmarks = 2
mapSize = 140 # Size of the environment (in m.)
Map = mapSize * np.random.uniform(low=0, high=1, size=(2, nLandmarks)) - mapSize / 2 # Uniformly distributed lanmarks in the map

# Sensor/odometry related
var_d = 0.5**2   # Variance (noise) of the range measurement
R = np.zeros(shape=(nLandmarks, nLandmarks))    # Covariance of the observation of the landmarks
z = np.zeros(shape=(nLandmarks, 1)) # Initially all the observations equal to zero
U = np.diag([9, 20, np.pi/180])**2 # Covariance of the odometry noise

# Robot pose related
xTrue = np.zeros(shape=(3,1))   # True position, to be selected by the user
xEst = np.zeros(shape=(3,1))    # Position estmiated by the LSE method
xOdom = np.zeros(shape=(3,1))   # Position given by odometry (in this case xTrue affected by the noise)

# Initial graphics
fig = plt.figure(1)
ax = fig.add_subplot(111, aspect='equal')
plt.grid(axis='both')
plt.plot(Map[0,:], Map[1,:], 'sm', lw=1, label='LandMarks', mfc='none', mew=2)
plt.xlabel('x (m)')
plt.ylabel('y (m)')

# Get the true position of the robot (ask the user)
print('Please, click on the Figure where the robot is located:')
_xTrue = np.array(plt.ginput()[0])
_xTrue.shape = (2,1)
xTrue[0:2] = _xTrue
plt.plot(xTrue[0], xTrue[1], 'ob', mfc='none', ms=12, label='True position')

# Set an initial guess: Where the robot believes it is (from odometry)
xOdom = xTrue + np.matmul(np.sqrt(U), np.random.randn(3,1))
plt.plot(xOdom[0], xOdom[1], '+r', ms=12, label='Odo estimation (initial guess)')
print(af.euclid_distance(xOdom, xTrue))

observations = []
# Get the observations to all the landmarks (data given by our sensor)
for kk in range(nLandmarks):
    # Take an observation to each landmark, i.e.: compute distance to
    # each one (RANGE sensor) affected by gaussian noise
    _distance_kk = af.euclid_distance(xTrue, af.get_pose(Map[:, kk]))[0]
    _distance_kk += np.random.randn() * var_d
    observations.append(_distance_kk)
print(observations)
z = observations

# Pose estimation using Gauss-Newton for LS optimization

# Some parameters for the Gauss-Newton optimization loop
nIterations = 10   # Sets the maximum number of iterations
tolerance = .001    # Minimum error needed for stopping the loop (convergence)
iteration = 0

# Initialization of useful variables
incr = np.ones(shape=(1,2))             # Delta
jH = np.zeros(shape=(nLandmarks, 2))    # Jacobian of the observation function of all the landmarks

xEst = xOdom    # Initial estimation is the odometry position (usually noisy)

while np.linalg.norm(incr) > tolerance and iteration < nIterations:
    plt.plot(xEst[0], xEst[1], '+r', ms=(1 + np.floor((iteration * 15)/nIterations)))

    # 1) Compute distance to each landmark from xEst
    est_observations = []   # Predicted observations
    for kk in range(nLandmarks):
        _distance_kk = af.euclid_distance(xEst, af.get_pose(Map[:, kk]))[0]
        est_observations.append(_distance_kk)

    # error = difference between real observations and predicted ones
    e = np.array(observations) - np.array(est_observations)
    residual = np.sqrt(np.matmul(e.T, e))

    # 2) Compute the Jacobians with respect (x, y)
    # The jH is evaluated at out current guest (xEst) -> z_p
    for kk in range(nLandmarks):
        jH[kk,0] = -1/(est_observations[kk]) * (Map[0, kk] - xEst[0])
        jH[kk,1] = -1/(est_observations[kk]) * (Map[1, kk] - xEst[1])

    # The observation variances R grow with the root of the distance
    R = np.diag(var_d * np.sqrt(z))

    # 3) Solve the equation --> compute incr
    _R_inv = np.linalg.inv(R)
    _d1 = np.linalg.inv(reduce(np.matmul, [jH.T, _R_inv, jH]))
    delta = reduce(np.matmul, [_d1, jH.T, _R_inv, e])
    incr = delta

    # Update position estimation
    plt.plot([xEst[0], xEst[0] + incr[0]], [xEst[1], xEst[1] + incr[1]], 'r')
    incr.shape = (2,1)
    xEst[0:2] = xEst[0:2] + incr
    print(  'Iteration number ' + str(iteration+1) + 
            ' residual: ' + str(residual) + ' [m] increment: ' 
            + str(np.linalg.norm(incr)) + ' [m]')
    fig.canvas.draw()
    iteration += 1
    input('Press Enter to continue...')

# The last estimation is plot in green
plt.plot(xEst[0], xEst[1], 'g*')
plt.legend()
fig.canvas.draw()
input("Press any key to exit")
