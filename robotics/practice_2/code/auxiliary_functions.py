import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Ellipse

def angle_wrap(a):
    if a > np.pi:
        return a-2*np.pi
    elif a < -np.pi:
        return a + 2*np.pi
    else:
        return a

# def differential_model(x,u,dT):
# #This function takes pose x and transform it according to the motion u=[v,w]
# #applying the differential drive model. 
# # Dt: time increment
# # y: Transformed pose (in world reference)
#     if(u[1]== 0): #linear motion w=0. Only motion in x
#         #%dx = u(1)*dT; dy = 0; d_thetha = 0;
#         y[0,0] = x[0] + u[0] * dT * np.cos(x[2])[0]
#         y[1,0] = x[1] + u[0] * dT * np.sin(x[2])[0]
#         y[2,0] = x[2]
#     else: #Non-linear motion w=!0
#         R=u(1)/u(2); #v/w=r is the curvature radius
#         y[0,0] = x[0] - R*sin(x[2] + R * np.sin(x[2] + u[1] * dT)[0]
#         y[1,0] = x[1] + R*cos(x[2] - R * np.cos(x[2] + u[1] * dT)[0]
#         y[2,0] = x[2] + u[1] * dT
#     return y


def draw_robot(Xr, col, a):
    p = 0.02
    l1 = (a[1] - a[0]) * p
    l2 = (a[3] - a[2]) * p
    P = np.array([[-1, 1, 0, -1], [-1, -1, 3, -1]])
    theta = Xr[2] - np.pi/2
    c = np.cos(theta)[0]
    s = np.sin(theta)[0]
    rot_mat = np.array([[c, -s], [s, c]])
    P = np.matmul(rot_mat, P)
    P[0] = P[0] * l1 + Xr[0]
    P[1] = P[1] * l2 + Xr[1]
    plt.plot(P[0,:],P[1,:], col, linewidth=0.5)
    plt.plot(Xr[0], Xr[1], '+' + col)

def get_ellipse(mean, covariance, n_sigma):
    covariance = covariance[0:2, 0:2]
    mean = mean[0:2]
    if (not any(np.diag(covariance) == 0)):
        eigen_values, eigen_vectors = np.linalg.eig(covariance)
        order = eigen_values.argsort()[::-1]
        eigen_values, eigen_vectors = eigen_values[order], eigen_vectors[:,order]
        x, y = eigen_vectors[:,0][0], eigen_vectors[:,0][1]
        theta = np.degrees(np.arctan2(y,x))
        width, height = 2 * n_sigma * np.sqrt(eigen_values)
        return Ellipse(xy=mean, width=width, height=height, angle=theta, facecolor='none', edgecolor='b')

def j1(x1, x2):
    s1 = np.sin(x1[2])[0]
    c1 = np.cos(x1[2])[0]

    return [[1, 0, -x2[0] * s1 - x2[1] * c1], [0, 1, x2[0] * c1 - x2[1] * s1], [0, 0, 1]]

def j2(x1, x2):
    s1 = np.sin(x1[2])[0]
    c1 = np.cos(x1[2])[0]

    return [[c1, -s1, 0], [s1, c1, 0], [0, 0, 1]]

def jab(tab):
    if len(tab) != 3:
        raise Exception('tab is not a transformation')
    s = np.sin(tab[2])
    c = np.cos(tab[2])
    return [[c, -s, tab[1]], [s, c, -tab[0]], [0, 0, 1]]

def tcomp(tab, tbc):
    if len(tab) != 3:
        raise Exception('tab is not a transformation')

    if len(tbc) != 3:
        raise Exception('tab is not a transformation')

    ang = tab[2] + tbc[2]

    ang = angle_wrap(ang)

    s = np.sin(tab[2])[0]
    c = np.cos(tab[2])[0]
    
    xy = tab[:2] + np.matmul(np.array([[c, -s], [s, c]]),tbc[:2])
    return np.array([xy[0], xy[1], ang])

def tinv1(tab):
    s = np.sin(tab[2])[0]
    c = np.cos(tab[2])[0]
    return np.array([-tab[0] * c - tab[1] * s, tab[0] * s - tab[1] * c, -tab[2]])

def add_noise(pose):
    mu = np.array([pose[0][0], pose[1][0], pose[2][0]])
    sigma = np.array([[.04, 0, 0], [0, .04, 0], [0, 0, .01]])
    new_pose = np.random.multivariate_normal(mu, sigma, 1)[0]
    return np.array([[y] for y in new_pose])

def get_ut(pose, prev):
    ang_1 = np.arctan2(pose[1] - prev[1], pose[0] - prev[0]) - prev[2]
    dist = np.sqrt((pose[0] - prev[0])**2 + (pose[1] - prev[1])**2)
    ang_2 = pose[2] - prev[2] - ang_1
    return ang_1, dist, ang_2