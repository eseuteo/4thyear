import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Ellipse
from random import randint, random
from functools import reduce

def get_bearing(a, b):
    return np.arctan2(a[1] - b[1], a[0] - b[0])

def CreateMap(NumLandmarks, Size):
    ans = 2 * Size * np.random.uniform(low=0, high=1, size=(2, NumLandmarks))
    return ans - Size

def getRandomObservationFromPose(x, Map, Q, mode = 'single'):
    if mode == 'single':
        lm_index = randint(0, len(Map.T) - 1)
        ans = getRangeAndBearing(x, Map[:, lm_index], Q), lm_index
    else:
        obsx = []
        obsy = []
        lm = []
        for i in range(len(Map.T)):
            lm_index = randint(0, len(Map.T) - 1)
            if (random() < .9): # Measurement of 80% of landmarks
                obsx.append(getRangeAndBearing(x, Map[:, i], Q)[0][0])
                obsy.append(getRangeAndBearing(x, Map[:, i], Q)[1][0])
                lm.append(i)
        ans = [obsx, obsy], lm
    return ans

def getRangeAndBearing(x, landmark, Q):
    range = euclid_distance(x, get_pose(landmark))[0]
    bearing = get_bearing(landmark, x)
    ans = np.matmul(Q, [[range], bearing])
    return ans

def getObsJac(xPred, Landmark, Map, mode = 'single'):
    if mode == 'single':
        d = euclid_distance(xPred, get_pose(Landmark))
        dx = Landmark[0] - xPred[0]
        dy = Landmark[1] - xPred[1]
        return build_h_jac(dx, dy, d)
    else:
        ans = []
        for lm in Landmark.T[:,]:
            _lm = get_pose([lm[0], lm[1]])
            d = euclid_distance(xPred, _lm)
            dx = _lm[0] - xPred[0]
            dy = _lm[1] - xPred[1]
            print(ans == [])
            if ans == []:
                ans = build_h_jac(dx, dy, d)
            else:
                ans = np.vstack((ans, build_h_jac(dx, dy, d)))
        print(len(ans))
        if ans == []:
            ans = np.array([])
        return ans

def build_h_jac(dx, dy, d):
    return np.array([
        [(-(dx)/d)[0], (-(dy)/d)[0], 0],
        [((dy)/d ** 2)[0], (-(dx)/d ** 2)[0], -1]])

def getLandmarksInsideFOV(x, Map, fov, max_range):
    v_map_x = []
    v_map_y = []
    for landmark in Map.T:
        if is_visible(x, fov, max_range, landmark):
            v_map_x.append(landmark[0])
            v_map_y.append(landmark[1])
    ans = np.array([v_map_x, v_map_y])
    return ans

def is_visible(x, b, r, lm):
    ans = False
    d = euclid_distance(x, lm)
    lmb = get_bearing(lm, x) - x[2][0]
    ans = d <= r and lmb >= -b/2 and lmb <= b/2
    return ans

def drawFOV(x, fov, max_range, c = ''):
    if c is '':
        c = 'b'
    
    alpha = fov/2
    angles = np.arange(-alpha, alpha, .01)
    nAngles = angles.shape[0]
    arc_points = np.zeros(shape=(2, nAngles))

    for i in range(0,nAngles):
        arc_points[0, i] = max_range * np.cos(angles[i])
        arc_points[1, i] = max_range * np.sin(angles[i])

        aux_point = tcomp(x, get_pose([arc_points[0, i], arc_points[1, i], 1]))
        arc_points[:,i] = aux_point[0:2].reshape(2)
        
    _x0 = np.append(x[0], arc_points[0, :])
    _x0 = np.append(_x0, x[0])

    _x1 = np.append(x[1], arc_points[1, :])
    _x1 = np.append(_x1, x[1])       
        
    return plt.plot(_x0, _x1, c)

def EKFLocalization():
    Size = 50
    NumLandmarks = 10
    Map = CreateMap(NumLandmarks, Size)
    
    # mode = 'one_landmark'
    # mode = 'one_landmark_in_fov'
    mode = 'landmarks_in_fov'

    # Sensor characterization
    SigmaR = 1      # SD of the range
    SigmaB = .7     # SD of the bearing
    Q = np.diag([SigmaR ** 2, SigmaB ** 2]) # Cov matrix
    fov = np.pi / 2     # FOV = 2 * alpha
    max_range = Size    # Maximum sensor measurament range

    # Robot base characterization
    SigmaX = .8     # SD in the X axis
    SigmaY = .8     # SD in the Y axis
    SigmaTheta = .1 # Bearing SD
    R = np.diag([SigmaX ** 2, SigmaY ** 2, SigmaTheta ** 2]) # Cov matrix

    # Initialization of poses
    x = get_pose([- Size + Size / 3, - Size + Size / 3, np.pi / 2])     # Ideal robot pose
    xTrue = get_pose([- Size + Size / 3, - Size + Size / 3, np.pi / 2]) # Real robot pose
    xEst = get_pose([- Size + Size / 3, - Size + Size / 3, np.pi / 2])  # Estimated robot pose by EKF
    sEst = np.zeros(shape=[3,3]) # Uncertainty of estimated robot pose

    axis = np.array([- Size - 5, Size + 5, - Size - 5, Size + 5])
    fig = plt.figure(1)
    ax = fig.add_subplot(111, aspect='equal')
    plt.plot(Map[0, :], Map[1, :], 'sc')
    plt.xlim(axis[0:2])
    plt.ylim(axis[2:])
    draw_robot(x, 'r', axis)
    draw_robot(xTrue, 'b', axis)
    draw_robot(xEst, 'g', axis)
    ax.add_artist(get_ellipse(xEst, sEst, 4, 'g'))
    plt.ion()
    plt.show()
    plt.draw()

    nSteps = 20
    turning = 5

    u = get_pose([(2 * Size - 2 * Size / 3) / turning, 0, 0])

    for k in range(nSteps - 2):
        u[2] = 0
        if np.mod(k, turning) == 4:
            u[2] = -np.pi / 2

        x = tcomp(x, u)                                     # New pose w/out noise
        noise = np.matmul(np.sqrt(R), np.random.randn(3))   # Generate noise
        noisy_u = (u.T + noise).T                           # Apply noise to the control action
        xTrue = tcomp(xTrue, noisy_u)                       # New noisy pose (real robot pose)

        # Get sensor observation/s
        if mode == 'one_landmark':
            obs, lm = getRandomObservationFromPose(xTrue, Map, Q)
            landmark = Map[:, lm]
            plt.plot([xTrue[0], landmark[0]], [xTrue[1], landmark[1]], 'm:')
            v_map = Map
        elif mode == 'one_landmark_in_fov':
            v_map = getLandmarksInsideFOV(xTrue, Map, fov, max_range)
            if len(v_map[0]) > 0:
                obs, lm = getRandomObservationFromPose(xTrue, v_map, Q)
                landmark = v_map[:, lm]
                plt.plot([xTrue[0], landmark[0]], [xTrue[1], landmark[1]], 'm:')
        elif mode == 'landmarks_in_fov':
            v_map = getLandmarksInsideFOV(xTrue, Map, fov, max_range)
            if len(v_map[0]) > 0:
                obs, lm = getRandomObservationFromPose(xTrue, v_map, Q, 'multiple')
                for lm_i in lm:
                    landmark = v_map[:, lm_i]
                    plt.plot([xTrue[0], landmark[0]], [xTrue[1], landmark[1]], 'm:')
        
        # EKF Localization
        G = j1(xEst, u)
        J2 = j2(xEst, u)

        # Prediction
        pred_x = tcomp(xEst, u)
        pred_s = reduce(np.matmul, [G, sEst, G.T]) + reduce(np.matmul, [J2, R, J2.T])
        if len(v_map[0]) > 0:
            if mode == 'one_landmark' or mode == 'one_landmark_in_fov':
                lxy = v_map[:, lm]
                # coordenadas x y del lm
                H = getObsJac(pred_x, lxy, v_map)
                # Jacobiana H
                _K_1 = np.matmul(pred_s, H.T)
                _K_2 = np.linalg.inv(reduce(np.matmul, [H, pred_s, H.T]) + Q)
                K = np.matmul(_K_1, _K_2)
                # Matriz K
                zH = obs - getRangeAndBearing(pred_x, lxy, np.identity(2))
                # z - H
                xEst = pred_x + np.matmul(K, zH)
                _sEst1 = np.identity(3) - np.matmul(K, H)
                sEst = np.matmul(_sEst1, pred_s)
            elif mode == 'landmarks_in_fov' and len(lm) > 0:
                lxy = v_map[:, lm]
                H = getObsJac(pred_x, lxy, v_map, 'multiple')
                # New Q
                Q_new = np.identity(2 * len(lm))
                for j in range(2 * len(lm)):
                    if j % 2 == 0:
                        Q_new[j, j] = Q[0, 0]
                    else:
                        Q_new[j, j] = Q[1, 1]
                # Jacobiana H
                _K_1 = np.matmul(pred_s, H.T)
                _K_2 = np.linalg.inv(reduce(np.matmul, [H, pred_s, H.T]) + Q_new)
                K = np.matmul(_K_1, _K_2)
                # Matriz K
                _obs_r = obs[0]
                _obs_b = obs[1]
                zH = []
                for j in range(len(lxy.T)):
                    _zH = np.array([_obs_r[j], _obs_b[j]])
                    _rb = getRangeAndBearing(pred_x, lxy[:, j], np.identity(2))
                    _r = _rb[0][0]
                    _b = _rb[1][0]
                    _zH -= [_r, _b]
                    zH.append(_zH)
                # z - H
                zH = np.array(zH)
                zH.shape = (len(H), 1)
                xEst = pred_x + np.matmul(K, zH)
                _sEst1 = np.identity(3) - np.matmul(K, H)
                sEst = np.matmul(_sEst1, pred_s)       
        else:
            xEst = pred_x
            sEst = pred_s


        # Drawings
        # Plot the FOV of the robot
        if mode == 'one_landmark_in_fov' or mode == 'landmarks_in_fov':
            h, = drawFOV(xTrue, fov, max_range, 'g')

        # ax.add_artist(get_ellipse(med_x, sigmaT, 3, 'g'))
        draw_robot(x, 'r', axis)
        draw_robot(xTrue, 'b', axis)
        draw_robot(xEst, 'g', axis)
        # print(xEst)
        # print(sEst)
        ax.add_artist(get_ellipse(xEst, sEst, 3, 'g'))

        input("press button")
        plt.draw()

        if mode == 'one_landmark_in_fov' or mode == 'landmarks_in_fov':
            h.remove()
            plt.draw()
        


def euclid_distance(a, b):
    return np.sqrt((a[0] - b[0])**2 + (a[1] - b[1])**2)

def get_pose(array):
    ans = array
    if len(ans) == 2:
        ans = np.append(ans, 0)
    ans = np.array(ans)
    ans.shape = (3,1)
    return ans

def angle_wrap(a):
    if a > np.pi:
        return a-2*np.pi
    elif a < -np.pi:
        return a + 2*np.pi
    else:
        return a

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

def get_ellipse(mean, covariance, n_sigma, color):
    covariance = covariance[0:2, 0:2]
    mean = mean[0:2]
    if (not any(np.diag(covariance) == 0)):
        eigen_values, eigen_vectors = np.linalg.eig(covariance)
        order = eigen_values.argsort()[::-1]
        eigen_values, eigen_vectors = eigen_values[order], eigen_vectors[:,order]
        x, y = eigen_vectors[:,0][0], eigen_vectors[:,0][1]
        theta = np.degrees(np.arctan2(y,x))
        width, height = 2 * n_sigma * np.sqrt(eigen_values)
        ans = Ellipse(xy=mean, width=width, height=height, angle=theta, facecolor='none', edgecolor=color)
    else:
        ans = Ellipse(xy=mean, width=0, height=0, angle=0, facecolor='none', edgecolor='none')
    return ans

def j1(x1, x2):
    s1 = np.sin(x1[2])[0]
    c1 = np.cos(x1[2])[0]

    return np.array([   [1, 0, -x2[0][0] * s1 - x2[1][0] * c1], 
                        [0, 1, x2[0][0] * c1 - x2[1][0] * s1], 
                        [0, 0, 1]])

def j2(x1, x2):
    s1 = np.sin(x1[2])[0]
    c1 = np.cos(x1[2])[0]

    return np.array([   [c1, -s1, 0], 
                        [s1, c1, 0], 
                        [0, 0, 1]])

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

def add_noise(pose, sigma=None):
    mu = np.array([pose[0][0], pose[1][0], pose[2][0]])
    if sigma is None:
        sigma = np.array([[.04, 0, 0], [0, .04, 0], [0, 0, .01]])
    new_pose = np.random.multivariate_normal(mu, sigma, 1)[0]
    return np.array([[y] for y in new_pose])

def get_ut(pose, prev):
    ang_1 = np.arctan2(pose[1] - prev[1], pose[0] - prev[0]) - prev[2]
    dist = np.sqrt((pose[0] - prev[0])**2 + (pose[1] - prev[1])**2)
    ang_2 = pose[2] - prev[2] - ang_1
    return ang_1, dist, ang_2