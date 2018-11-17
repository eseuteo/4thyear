import auxiliary_functions as af
import numpy as np
import matplotlib.pyplot as plt

# Map/landmarks related
nLandmarks = 7
mapSize = 140 # Size of the environment (in m.)
Map = mapSize * np.random.uniform(low=0, high=1, size=(2, nLandmarks)) - mapSize / 2 # Uniformly distributed lanmarks in the map

# Sensor/odometry related
var_d = .5**2   # Variance (noise) of the range measurement
R = np.zeros(nLandmarks)    # Covariance of the observation of the landmarks
z = np.zeros(shape=(nLandmarks, 1)) # Initially all the observations equal to zero
U = np.diag([9, 20, np.pi/180])**2 # Covariance of the odometry noise

# Robot pose related
xTrue = np.zeros(shape=(3,1)) # True position
xEst = np.zeros(shape=(3,1))
xOdom = np.zeros(shape=(3,1))

fig = plt.figure(1)
ax = fig.add_subplot(111, aspect='equal')
plt.grid(axis='both')
plt.plot(Map[0,:], Map[1,:], 'sm', lw=1, label='LandMarks')
plt.xlabel('x (m)')
plt.ylabel('y (m)')

print('Please, click on the Figure where the robot is located:')
_xTrue = np.array(plt.ginput()[0])
_xTrue.shape = (2,1)
xTrue[0:2] = _xTrue
plt.plot(xTrue[0], xTrue[1], 'ob', mfc='none', ms=12, label='True position')

xOdom = xTrue + np.matmul(np.sqrt(U), np.random.randn(3,1))
plt.plot(xOdom[0], xOdom[1], '+r', ms=12, label='Odo estimation (initial guess)')
print(af.euclid_distance(xOdom, xTrue))

observations = []
# Get the observations to all the landmarks (data given by our sensor)
for kk in range(nLandmarks):
    # Take an observation to each landmark, i.e.: compute distance to
    # each one (RANGE sensor affected by gaussian noise)
    _distance_kk = af.euclid_distance(xTrue, af.get_pose(Map[:, kk]))[0]
    _distance_kk += np.random.randn() * var_d
    observations.append(_distance_kk)
print(observations)

nIterations = 10
tolerance = .001
iteration = 0

incr = np.ones(shape=(1,2))
jH = np.zeros(shape=(nLandmarks, 2))

xEst = xOdom

# while np.norm(incr) > tolerance and iteration < nIterations:
#     plot(xEst[0], xEst[1], '+r', ms=(1 + np.floor((iteration * 15)/nIterations)))

plt.legend()
plt.show()
